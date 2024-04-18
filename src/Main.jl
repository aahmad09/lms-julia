include("Database.jl")
include("Operations.jl")

using .Database, .Operations

function main()
    db = init_db("library.db")

    println("Welcome to the Library Management System!")
    # Example commands to test the functionality
    add_user(db, "Alice", "alice@example.com")
    add_book(db, "Julia Programming 101", "John Doe", "978-1-2345-6789-0", 5)
    checkout_book(db, 1, 1)
    return_book(db, 1)

    println("Thank you for using the Library Management System.")
end

main()
