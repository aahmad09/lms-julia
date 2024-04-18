module Operations

using SQLite, DataFrames, PrettyTables

export add_user, add_book, checkout_book, return_book, display_books, display_users, display_checkouts

function add_user(db::SQLite.DB, name::String, email::String)
    SQLite.execute(db, "INSERT INTO Users (name, email) VALUES (?, ?)", (name, email))
end

function add_book(db::SQLite.DB, title::String, author::String, isbn::String, available_copies::Int)
    SQLite.execute(db, "INSERT INTO Books (title, author, isbn, available_copies) VALUES (?, ?, ?, ?)", (title, author, isbn, available_copies))
end

function checkout_book(db::SQLite.DB, user_id::Int, book_id::Int)
    available = SQLite.execute(db, "SELECT available_copies FROM Books WHERE id = ?", (book_id,)) |> DataFrame
    if available.available_copies[1] > 0
        SQLite.execute(db, "INSERT INTO Checkouts (user_id, book_id, checkout_date, due_date) VALUES (?, ?, date('now'), date('now', '+14 days'))", (user_id, book_id))
        SQLite.execute(db, "UPDATE Books SET available_copies = available_copies - 1 WHERE id = ?", (book_id,))
    else
        println("This book is currently unavailable.")
    end
end

function return_book(db::SQLite.DB, checkout_id::Int)
    book_id = SQLite.execute(db, "SELECT book_id FROM Checkouts WHERE id = ?", (checkout_id,)) |> DataFrame
    SQLite.execute(db, "UPDATE Books SET available_copies = available_copies + 1 WHERE id = ?", (book_id.book_id[1],))
    SQLite.execute(db, "UPDATE Checkouts SET return_date = date('now') WHERE id = ?", (checkout_id,))
end

function display_books(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Books;")
    df = DataFrame(result)
    pretty_table(df, title="Books List")
end

function display_users(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Users;")
    df = DataFrame(result)
    pretty_table(df, title="Users List")
end

function display_checkouts(db::SQLite.DB)
    result = DBInterface.execute(db, "SELECT * FROM Checkouts;")
    df = DataFrame(result)
    pretty_table(df, title="Checkouts List")
end

end
