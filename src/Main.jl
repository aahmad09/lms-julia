# Main.jl
include("Database.jl")
include("Operations.jl")

using .Database, .Operations

function display_menu()
    println("\nLibrary Management System")
    println("Choose an action:")
    println("[1] Add Book")
    println("[2] Add User")
    println("[3] Checkout Book")
    println("[4] Return Book")
    println("[5] List Books")
    println("[6] List Users")
    println("[7] List Checkouts")
    println("[8] Search Books")
    println("[9] Generate Reports")
    println("[10] Manage Reservations")
    println("[11] Add Reservation")
    println("[12] Renew Checkout")
    println("[13] Exit")
end

function main()
    db = init_db("library.db")
    while true
        display_menu()
        choice = readline()

        if choice == "1"
            println("Enter book title:")
            title = readline()
            println("Enter author:")
            author = readline()
            println("Enter ISBN:")
            isbn = readline()
            println("Enter number of copies:")
            copies = parse(Int, readline())
            add_book(db, title, author, isbn, copies)
        elseif choice == "2"
            println("Enter user name:")
            name = readline()
            println("Enter user email:")
            email = readline()
            println("Enter password:")
            password = readline()
            println("Enter role (user/admin):")
            role = readline()
            add_user(db, name, email, password, role)
        elseif choice == "3"
            println("Enter user ID:")
            user_id = parse(Int, readline())
            println("Enter book ID:")
            book_id = parse(Int, readline())
            checkout_book(db, user_id, book_id)
        elseif choice == "4"
            println("Enter checkout ID:")
            checkout_id = parse(Int, readline())
            return_book(db, checkout_id)
        elseif choice == "5"
            display_books(db)
        elseif choice == "6"
            display_users(db)
        elseif choice == "7"
            display_checkouts(db)
        elseif choice == "8"
            list_valid_columns(db, "Books")  # Display valid columns before asking for input
            println("How many criteria do you want to give?")
            num_criteria = parse(Int, readline())  # First, read how many criteria
            println("Enter search criteria in this format on a seperate line (field:value):")
            criteria = Dict([split(readline(), ":") for _ in 1:num_criteria])  # Then read each criteria
            search_books(db, criteria)
        elseif choice == "9"
            generate_reports(db)
        elseif choice == "10"
            manage_reservations(db)
        elseif choice == "11"
            println("Enter user ID:")
            user_id = parse(Int, readline())
            println("Enter book ID:")
            book_id = parse(Int, readline())
            add_reservation(db, user_id, book_id)
        elseif choice == "12"
            println("Enter checkout ID to renew:")
            checkout_id = parse(Int, readline())
            renew_checkout(db, checkout_id)
        elseif choice == "13"
            println("Exiting...")
            break
        else
            println("Invalid option. Please try again.")
        end
    end
end

main()
