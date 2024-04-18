module Operations

using SQLite

export add_user, add_book, checkout_book, return_book

function add_user(db::SQLite.DB, name::String, email::String)
    SQLite.execute(db, "INSERT INTO Users (name, email) VALUES (?, ?)", (name, email))
end

function add_book(db::SQLite.DB, title::String, author::String, isbn::String, available_copies::Int)
    SQLite.execute(db, "INSERT INTO Books (title, author, isbn, available_copies) VALUES (?, ?, ?, ?)", (title, author, isbn, available_copies))
end

function checkout_book(db::SQLite.DB, user_id::Int, book_id::Int)
    available = SQLite.execute(db, "SELECT available_copies FROM Books WHERE id = ?", (book_id,)) |> first |> first
    if available > 0
        SQLite.execute(db, "INSERT INTO Checkouts (user_id, book_id, checkout_date, due_date) VALUES (?, ?, date('now'), date('now', '+14 days'))", (user_id, book_id))
        SQLite.execute(db, "UPDATE Books SET available_copies = available_copies - 1 WHERE id = ?", (book_id,))
    else
        println("This book is currently unavailable.")
    end
end

function return_book(db::SQLite.DB, checkout_id::Int)
    book_id = SQLite.execute(db, "SELECT book_id FROM Checkouts WHERE id = ?", (checkout_id,)) |> first |> first
    SQLite.execute(db, "UPDATE Books SET available_copies = available_copies + 1 WHERE id = ?", (book_id,))
    SQLite.execute(db, "UPDATE Checkouts SET return_date = date('now') WHERE id = ?", (checkout_id,))
end

end
