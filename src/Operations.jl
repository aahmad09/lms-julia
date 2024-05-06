module Operations

using SQLite, DataFrames, PrettyTables, SHA, Random

function add_book(db::SQLite.DB, title::String, author::String, isbn::String, available_copies::Int)
    # When adding a book, both available and total copies should be set to the number of copies added.
    SQLite.execute(db, """
        INSERT INTO Books (title, author, isbn, available_copies) 
        VALUES (?, ?, ?, ?)
    """, (title, author, isbn, available_copies))
    println("Book added successfully: $title")
end


function add_user(db::SQLite.DB, name::String, email::String, password::String, role::String="user")
    hashed_password = SHA.sha256(string(password, randstring(10)))  # Simple hashing with salt
    SQLite.execute(db, "INSERT INTO Users (name, email) VALUES (?, ?)", (name, email))
end

function display_books(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Books;")
    df = DataFrame(result)
    #return df
    x = pretty_table(df, title="Books List")
    return  df #x#pretty_table(df, title="Books List")
end

function return_display_books!(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Books;")
    df = DataFrame(result)
    return df
end

function display_users(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Users;")
    df = DataFrame(result)
    pretty_table(df, title="Users List")
    return df
end

function display_checkouts(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Checkouts;")
    df = DataFrame(result)
    pretty_table(df, title="Checkouts List")
    return df
end

function authenticate_user(db::SQLite.DB, email::String, password::String)
    user = SQLite.execute(db, "SELECT password FROM Users WHERE email = ?", (email,)) |> DataFrame
    return !isempty(user) && SHA.sha256(string(password, user.password[1][21:end])) == user.password[1][1:20]
end

function search_books(db::SQLite.DB, criteria::Dict)
    query = "SELECT * FROM Books WHERE " * join([string(key, " LIKE '%", value, "%'") for (key, value) in criteria], " AND ")
    result = DBInterface.execute(db, query)
    df = DataFrame(result)
    pretty_table(df, title="Search Results")
end



function list_valid_columns(db::SQLite.DB, table_name::String)
    try
        result = DBInterface.execute(db, "PRAGMA table_info($table_name);")
        df = DataFrame(result)
        columns = df[!, :name]  # Corrected column access
        println("Valid columns for '$table_name': ", join(columns, ", "))
    catch e
        println("Error retrieving column names: ", e)
    end
end

function generate_reports(db::SQLite.DB)
    # Most popular books
    popular_books = DBInterface.execute(
        db,
        """
        SELECT b.title, COUNT(c.id) AS checkout_count
        FROM Checkouts c
        JOIN Books b ON c.book_id = b.id
        GROUP BY b.title
        ORDER BY checkout_count DESC
        LIMIT 5
        """
    ) |> DataFrame
    pretty_table(popular_books, title="Most Popular Books")

    # Books that are frequently late
    late_books = DBInterface.execute(
        db,
        """
        SELECT b.title, COUNT(c.id) AS late_count
        FROM Checkouts c
        JOIN Books b ON c.book_id = b.id
        WHERE c.return_date > c.due_date
        GROUP BY b.title
        ORDER BY late_count DESC
        LIMIT 5
        """
    ) |> DataFrame
    pretty_table(late_books, title="Frequently Late Books")

    # User activity reports
    user_activity = DBInterface.execute(
        db,
        """
        SELECT u.name, COUNT(c.id) AS activity_count
        FROM Checkouts c
        JOIN Users u ON c.user_id = u.id
        GROUP BY u.name
        ORDER BY activity_count DESC
        """
    ) |> DataFrame
    pretty_table(user_activity, title="User Activity Report")
    return (popular_books, late_books,user_activity)
end

function checkout_book(db::SQLite.DB, user_id::Int, book_id::Int)
    # Check if there are any active reservations for this book by another user
    reservation_result = DBInterface.execute(db, """
        SELECT user_id FROM Reservations 
        WHERE book_id = ? AND status = 'active' AND user_id != ?;
    """, (book_id, user_id))
    reservations = DataFrame(fetch(reservation_result))

    # If there are active reservations by other users, do not allow checkout
    if !isempty(reservations)
        println("This book is currently reserved by another user.")
        return
    end

    # Fetch available copies from the database
    available_result = DBInterface.execute(db, "SELECT available_copies FROM Books WHERE id = ?", (book_id,))
    available = DataFrame(fetch(available_result))

    # Check if the book is available for checkout
    if available.available_copies[1] > 0
        # If available, perform the checkout
        SQLite.execute(db, "INSERT INTO Checkouts (user_id, book_id, checkout_date, due_date) VALUES (?, ?, date('now'), date('now', '+14 days'))", (user_id, book_id))
        SQLite.execute(db, "UPDATE Books SET available_copies = available_copies - 1 WHERE id = ?", (book_id,))
        println("Checkout completed successfully.")
    else
        println("This book is currently unavailable.")
    end
end


function return_book(db::SQLite.DB, checkout_id::Int)
    result = DBInterface.execute(db, "SELECT book_id FROM Checkouts WHERE id = ?", (checkout_id,))
    book_data = DataFrame(fetch(result))

    if isempty(book_data)
        println("No checkout record found for ID: $checkout_id")
        return
    end

    book_id = book_data[1, :book_id]

    if ismissing(book_id) || book_id <= 0
        println("Invalid book ID retrieved.")
        return
    end

    # Fetch current and total available copies
    book_result = DBInterface.execute(db, "SELECT available_copies FROM Books WHERE id = ?", (book_id,))
    book_info = DataFrame(fetch(book_result))

    if isempty(book_info) #|| book_info.available_copies[1] >= book_info.total_copies[1]
        println("Book copies are already fully stocked or data is missing.")
        return
    end

    # Update the available copies if not already at max
    SQLite.execute(db, "UPDATE Books SET available_copies = available_copies + 1 WHERE id = ?", (book_id,))
    SQLite.execute(db, "UPDATE Checkouts SET return_date = date('now') WHERE id = ?", (checkout_id,))
    println("Book returned successfully.")
end


function manage_reservations(db::SQLite.DB)
    # Assuming Reservations table and necessary fields are added to the database
    reservations = DBInterface.execute(db, "SELECT * FROM Reservations WHERE status = 'active';") |> DataFrame
    pretty_table(reservations, title="Active Reservations")
    return reservations
end

function add_reservation(db::SQLite.DB, user_id::Int, book_id::Int)
    # Execute the query to check if the book is already reserved
    result = DBInterface.execute(db, """
        SELECT COUNT(*) AS count FROM Reservations 
        WHERE book_id = ? AND status = 'active';
    """, (book_id,))

    # Fetch the result and ensure it is in a proper data structure
    active_check_result = DataFrame(fetch(result))  # Convert directly to DataFrame

    # Access the count directly from the DataFrame
    active_check = active_check_result[1, :count]

    # Check if the book is already reserved by another user
    if active_check > 0
        println("This book is already reserved by another user.")
        return
    end

    # Insert the reservation into the database
    SQLite.execute(db, """
        INSERT INTO Reservations (user_id, book_id, reservation_date, status)
        VALUES (?, ?, date('now'), 'active');
    """, (user_id, book_id))
    println("Reservation added successfully.")
end




function renew_checkout(db::SQLite.DB, checkout_id::Int)
    # Execute the query to check for active reservations
    result = DBInterface.execute(db, """
        SELECT COUNT(*) AS count 
        FROM Reservations 
        WHERE book_id IN (SELECT book_id FROM Checkouts WHERE id = ?) 
        AND status = 'active';
    """, (checkout_id,))

    reservation_count = fetch(result)  # Fetch the result

    # Convert result to DataFrame for easier access if not using scalar directly
    reservation_df = DataFrame(reservation_count)

    # Check the count to decide on renewal
    if reservation_df[1, :count] == 0
        # No active reservations, so proceed with the renewal
        SQLite.execute(db, "UPDATE Checkouts SET due_date = date(due_date, '+14 days') WHERE id = ?;", (checkout_id,))
        println("Checkout renewed successfully.")
    else
        println("Unable to renew: Book is reserved by another user.")
    end
end


function track_history(db::SQLite.DB, user_id::Int, book_id::Int, transaction_type::String)
    SQLite.execute(db, "INSERT INTO Transactions (user_id, book_id, transaction_type, transaction_date) VALUES (?, ?, ?, date('now'))", (user_id, book_id, transaction_type))
end

function notify_late_returns(db::SQLite.DB)
    late_returns = DBInterface.execute(db, "SELECT user_id, book_id FROM Checkouts WHERE due_date < date('now') AND return_date IS NULL;") |> DataFrame
    for row in eachrow(late_returns)
        user = SQLite.execute(db, "SELECT name, email FROM Users WHERE id = ?", (row.user_id,)) |> DataFrame
        book = SQLite.execute(db, "SELECT title FROM Books WHERE id = ?", (row.book_id,)) |> DataFrame
        println("Late Return Alert: $(user.name[1]) (Email: $(user.email[1])) - Book: $(book.title[1])")
    end
end

export add_book, add_user, display_books, display_users, display_checkouts, authenticate_user, search_books, list_valid_columns, generate_reports, checkout_book, add_reservation, manage_reservations, return_book, renew_checkout, track_history, notify_late_returns


end
