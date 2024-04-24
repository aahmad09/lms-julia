module Database

using SQLite

function init_db(db_path::String="library.db")
    db = SQLite.DB(db_path)

    # Create Books table with an added column for total copies
    SQLite.execute(
        db,
        """
CREATE TABLE IF NOT EXISTS Books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    isbn TEXT UNIQUE,
    available_copies INTEGER DEFAULT 0,
    total_copies INTEGER DEFAULT 0
);
"""
    )

    # Create Users table
    SQLite.execute(
        db,
        """
CREATE TABLE IF NOT EXISTS Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user'
);
"""
    )

    # Create Checkouts table
    SQLite.execute(
        db,
        """
CREATE TABLE IF NOT EXISTS Checkouts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    book_id INTEGER,
    checkout_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY(user_id) REFERENCES Users(id),
    FOREIGN KEY(book_id) REFERENCES Books(id)
);
"""
    )

    # Create Reservations table
    SQLite.execute(
        db,
        """
CREATE TABLE IF NOT EXISTS Reservations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    book_id INTEGER,
    reservation_date DATE,
    status TEXT DEFAULT 'active',
    FOREIGN KEY(user_id) REFERENCES Users(id),
    FOREIGN KEY(book_id) REFERENCES Books(id)
);
"""
    )

    # Create Transactions table
    SQLite.execute(
        db,
        """
CREATE TABLE IF NOT EXISTS Transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    book_id INTEGER,
    transaction_type TEXT,
    transaction_date DATE,
    FOREIGN KEY(user_id) REFERENCES Users(id),
    FOREIGN KEY(book_id) REFERENCES Books(id)
);
"""
    )

    return db
end

export init_db

end
