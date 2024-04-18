module Database

using SQLite

export init_db

function init_db(db_path::String)
    db = SQLite.DB(db_path)
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS Books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        isbn TEXT UNIQUE,
        available_copies INTEGER DEFAULT 0
    );""")
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL
    );""")
    SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS Checkouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        book_id INTEGER,
        checkout_date DATE,
        due_date DATE,
        return_date DATE,
        FOREIGN KEY(user_id) REFERENCES Users(id),
        FOREIGN KEY(book_id) REFERENCES Books(id)
    );""")
    return db
end

end
