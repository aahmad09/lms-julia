using Mousetrap


main() do app::Application
    window = Window(app)
    set_size_request!(window, Vector2f(480,480))
    # create a signal handler
    button = Button()
    box = Box(ORIENTATION_VERTICAL)
    set_child!(button, Label("FUck me"))
    push_front!(box, button)
    set_child!(window,box)
    #set_child!(window, Label("Hello World!!!"))
    on_clicked(self::Button) = push_front!(box,Label("clicked"))
    # connect signal handler to the signal
    connect_signal_clicked!(on_clicked, button)
    present!(window)
    
end

