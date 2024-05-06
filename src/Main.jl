# Main.jl
include("Database.jl")
include("Operations.jl")

using .Database, .Operations
using Mousetrap

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


function assist()
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
using .Operations
main() do app::Application #have to overrride main to do gui stuff
   
    db = init_db("library.db")
    window = Window(app)
    set_title!(window, "LMS")
    set_size_request!(window, Vector2f(480,480))
    box = Box(ORIENTATION_VERTICAL) #bro i can just make a v box
    set_margin!(box,10)
    set_child!(window, Label("Hello World!!!"))
    # create a signal handler
    #=
    titles = ["Add Book", "Add User", "Checkout Book", "Checkout User"]
    funcs = [println(1), println(2), println(3)]#[add_book, add_user, checkout_book]
    for (label, func)  in zip(titles, funcs)
        =#
        #im just gonna do it by hand...
    ABbutton = Button()
    set_child!(ABbutton, Label("Add Book"))
    push_front!(box, ABbutton)
    #set_child!(window,box)
    connect_signal_clicked!(ABbutton) do self::Button
        println(1)
        hide!(box)
        titleinfo = Label("Enter title of Book")
        title = Entry()
        set_text!(title, "")
        authorinfo = Label("Enter book Author")
        author = Entry()
        set_text!(author, "")
        isbninfo = Label("Enter book ISBN:")
        isbn = Entry()
        set_text!(isbn, "")
        numinfo = Label("Enter number ")
        numCopies = SpinButton(0,999,1)
        set_value!(numCopies,1)
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(titleinfo, title, authorinfo,author, isbninfo,isbn,numCopies, Sbutton, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            add_book(db, get_text(title), get_text(author), get_text(isbn), trunc(Int,get_value(numCopies)))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
        
    end
    #on_clicked(self::Button) = println(1)
    # connect signal handler to the signal
    #connect_signal_clicked!(on_clicked, ABbutton)
    AUbutton = Button()
    set_child!(AUbutton, Label("Add User"))
    push_front!(box, AUbutton)
    #set_child!(window,box)
    #on_clicked(self::Button) = println(2)
    connect_signal_clicked!(AUbutton) do self::Button
        println(1)
        hide!(box)
        userinfo = Label("Enter username:")
        user = Entry()
        set_text!(user, "")
        emailinfo = Label("Enter email:")
        email = Entry()
        set_text!(email, "")
        pwordinfo = Label("Enter password:")
        pword = Entry()
        set_text_visible!(pword, false)
        set_text!(pword, "")
        pword2info = Label("Enter password again:")
        pword2 = Entry()
        set_text_visible!(pword2,false)
        set_text!(pword2, "")
        admin = ToggleButton()
        togglebox = hbox(Label("Check if Admin"),admin)

        numinfo = Label("Enter number ")
        numCopies = SpinButton(0,999,1)
        set_value!(numCopies,1)
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(userinfo, user, emailinfo, email, pwordinfo,pword,pword2info, pword2, togglebox, Sbutton, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(user), get_text(email), get_text(pword2),get_is_active(admin))
            if get_is_active(admin)
                add_user(db, get_text(user), get_text(email), "admin")
            else
                add_user(db, get_text(user), get_text(email), "user")
            end
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)


        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
        
        
    end
   
    CBbutton = Button()
    set_child!(CBbutton, Label("Checkout Book"))
    push_front!(box, CBbutton)
    set_child!(window,box)
    connect_signal_clicked!(CBbutton) do self::Button
        hide!(box)
        users = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        userrows = display_users(db)
        println(userrows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(userrows)
            #println(methodswith(row))
            push_back!(users, Label(string(values(row))))
        end
        books = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        bookrows = display_books(db)
        println(bookrows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(bookrows)
            #println(methodswith(row))
            push_back!(books, Label(string(values(row))))
        end
        bothlists = hbox(users,books)
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Checkout"))
        addbox = vbox(Label("Select options from both columns."),bothlists, Sbutton,Cbutton)
        connect_signal_clicked!(Sbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
            #println( users[get_selection(get_selection_model(users)), :])
            println(get_selection(get_selection_model(users)))
            
            println( userrows[get_selection(get_selection_model(users))[1],:][1],bookrows[get_selection(get_selection_model(books))[1], :][1])
            checkout_book(db, userrows[get_selection(get_selection_model(users))[1],:][1],bookrows[get_selection(get_selection_model(books))[1], :][1])
        end
        connect_signal_clicked!(Cbutton) do self::Button
            #println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    RBbutton = Button()
    set_child!(RBbutton, Label("Return Book"))
    push_front!(box, RBbutton)
    connect_signal_clicked!(RBbutton) do self::Button
        hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = display_checkouts(db)
        println(rows)
        push_back!(list_view, Label("Enter id of book to return"))
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        num = Entry()
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(list_view, hbox(Label("Enter ID of return"),num, Sbutton),Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            #println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            return_book(db, trunc(Int,get_value(Entry)))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    LBbutton = Button()
    set_child!(LBbutton, Label("List Book(s)"))
    push_front!(box, LBbutton)
    connect_signal_clicked!(LBbutton) do self::Button
        hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = display_books(db)
        #println(names(rows))
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(list_view, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    LUbutton = Button()
    set_child!(LUbutton, Label("List User(s)"))
    push_front!(box, LUbutton)
    connect_signal_clicked!(LUbutton) do self::Button
        hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = display_users(db)
        println(rows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(list_view, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    LCbutton = Button()
    set_child!(LCbutton, Label("List Checkout(s)"))
    push_front!(box, LCbutton)
    connect_signal_clicked!(LCbutton) do self::Button
        hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = display_checkouts(db)
        println(rows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(list_view, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            #println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    SBbutton = Button()
    set_child!(SBbutton, Label("Search Book(s)"))
    #push_front!(box, SBbutton)
    connect_signal_clicked!(SBbutton) do self::Button
        println(8)
        #dummied out
    end
    GRbutton = Button()
    set_child!(GRbutton, Label("Generate Report(s)"))
    push_front!(box, GRbutton)
    set_child!(window,box)
    connect_signal_clicked!(GRbutton) do self::Button
        hide!(box)
        note = Notebook()
        #list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        reps = generate_reports(db)
        for rep in zip(reps, [ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE),ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE),ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)], ["Most Popular Books","Frequently Late","User Activity"])
            for row in eachrow(rep[1])
                push_back!(rep[2], Label(string(values(row))))
            end
            push_back!(note,rep[2], Label(rep[3]))
        end
        


        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(note, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    MRbutton = Button()
    set_child!(MRbutton, Label("Manage Reservations"))
    push_front!(box, MRbutton)
    set_child!(window,box)
    connect_signal_clicked!(MRbutton) do self::Button
        hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = manage_reservations(db)
        println(rows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Submit"))
        addbox = vbox(list_view, Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
    end
    ARbutton = Button()
    set_child!(ARbutton, Label("Add Reservation"))
    push_front!(box, ARbutton)
    set_child!(window,box)
    connect_signal_clicked!(ARbutton) do self::Button
        hide!(box)
        users = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        userrows = display_users(db)
        println(userrows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(userrows)
            #println(methodswith(row))
            push_back!(users, Label(string(values(row))))
        end
        books = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        bookrows = display_books(db)
        println(bookrows)
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(bookrows)
            #println(methodswith(row))
            push_back!(books, Label(string(values(row))))
        end
        bothlists = hbox(users,books)
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        Sbutton = Button()
        set_child!(Sbutton, Label("Reserve"))
        addbox = vbox(Label("Select options from both columns to reserve."),bothlists, Sbutton,Cbutton)
        connect_signal_clicked!(Sbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
            #println( users[get_selection(get_selection_model(users)), :])
            #println(get_selection(get_selection_model(users)))
            
            #println( userrows[get_selection(get_selection_model(users))[1],:][1],bookrows[get_selection(get_selection_model(books))[1], :][1])
            add_reservation(db, userrows[get_selection(get_selection_model(users))[1],:][1],bookrows[get_selection(get_selection_model(books))[1], :][1])
        end
        connect_signal_clicked!(Cbutton) do self::Button
            #println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")
        
    end
    RCbutton = Button()
    set_child!(RCbutton, Label("Renew Checkout"))
    push_front!(box, RCbutton)
    set_child!(window,box)
    connect_signal_clicked!(RCbutton) do self::Button
       
hide!(box)
        list_view = ListView(ORIENTATION_VERTICAL, SELECTION_MODE_SINGLE)
        rows = display_checkouts(db)
        println(rows)
        push_back!(list_view, Label("Enter id of checkout to renew"))
        #push_back!(list_view, Label(string(rows)))
        for row in eachrow(rows)
            #println(methodswith(row))
            push_back!(list_view, Label(string(values(row))))
        end
        Cbutton = Button()
        set_child!(Cbutton, Label("Cancel"))
        num = Entry()
        Sbutton = Button()
        set_child!(Sbutton, Label("Renew"))
        addbox = vbox(list_view, hbox(Label("Enter ID."),num, Sbutton),Cbutton)
        connect_signal_clicked!(Cbutton) do self::Button
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        connect_signal_clicked!(Sbutton) do self::Button
            #println(get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            #add_book(db, get_text(title), get_text(author), get_text(isbn), get_value(numCopies))
            renew_checkout(db, parse(Int64,get_text(num)))
            hide!(addbox)
            set_is_visible!(box,true)
            set_child!(window, box)
        end
        set_spacing!(addbox, 10)
        set_child!(window, addbox)
        present!(window)
        #set_is_visible!(box, false)
        println("hid")    
    end
    push_front!(box, Label("Welcome to Julia Library Management System!"))


    present!(window)
    display_menu()
    #assist()
end
