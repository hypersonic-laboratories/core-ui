Core-UI: Simplifying In-Game UI Creation for HELIX Game Creators
Core-UI is a meticulously crafted package for HELIX Game, designed to empower creators with the ability to effortlessly generate and manage in-game user interfaces. This package amalgamates HTML, CSS, JS, and Lua using the HELIX Game Scripting API, offering a streamlined approach to UI development within the HELIX gaming environment.

            How to use

        Package installation:

1 - Download and extract this repository
2 - Drag and drop core-ui foler to your Pakcages folder
3 - Add core-ui to your Config.toml on [packages] section. 

    Calling core-ui classes from other packages

1 - Add core-ui as a dependency on your Package - Package.toml file
2 - Call `Notification` - `ContextMenu` - `SelectMenu` or `Interaction` classes on your package client side. 


            Examples

-- Example of how to use ContextMenu class 
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "/menu" then
        local myMenu = ContextMenu.new()
        myMenu:addButton("date-user", "Buton - Function", function()
            -- here you execute something
            Chat.AddMessage("I pressed addbutton")
        end)
        myMenu:addCheckbox("give-user", "Checkbox", true, function()
            Chat.AddMessage('i pressed checbkox')
        end)
        myMenu:addDropdown("set-user", { { value = "1", text = "Option 1" }, { value = "2", text = "Option 2" } },
            function(option)
                Chat.AddMessage('selected option: ' .. option)
            end)
        myMenu:addRange("quantity", "Quantity", 0, 100, 50, function(value)
            Chat.AddMessage('range value: ' .. value)
        end)
        myMenu:addTextInput("text-input", "Text input", function(text)
            Chat.AddMessage('text input: ' .. text)
        end)

        myMenu:Open(false, true) -- Enable input, Enable mouse
    end
end)

-- Example of how to use SelectMenu class
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "selectmenu" then
        -- Creates and configures a new select menu with options
        local selectMenu = SelectMenu.new()
        selectMenu:addOption('option1', 'Option 1', -- id, text
            'https://playtoearn.net/blog_images/helix-p2e-metaverse-game-introduces-this-months-exciting-list-of-events-1000x700.jpeg', -- image 
            'This is the description for Option 1', function() -- description, callback
                Chat.AddMessage("Option selected: Option 1") -- here you execute anything u want :)
            end)

        selectMenu:addOption('option2', 'Option 2',
            'https://playtoearn.net/blog_images/helix-p2e-metaverse-game-introduces-this-months-exciting-list-of-events-1000x700.jpeg',
            'This is the description for Option 2', function()
                Chat.AddMessage("Option selected: Option 2")
            end)

        selectMenu:addOption('option3', 'Option 3',
            'https://playtoearn.net/blog_images/helix-p2e-metaverse-game-introduces-this-months-exciting-list-of-events-1000x700.jpeg',
            'This is the description for Option 3', function()
                Chat.AddMessage("Option selected: Option 3")
            end)

        selectMenu:addOption('option4', 'Option 4',
            'https://playtoearn.net/blog_images/helix-p2e-metaverse-game-introduces-this-months-exciting-list-of-events-1000x700.jpeg',
            'This is the description for Option 4', function()
                Chat.AddMessage("Option selected: Option 4")
            end)
        selectMenu:Open() -- Opens the select menu
    end
end)

-- Example of how to use Interaction class
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Command 'int' to show interaction
    if message == "int" then
        local interaction = Interaction.new()

        interaction:show("my-interaction", "Your UI text here", function()
            Chat.AddMessage("Interaction: my-interaction completed!!")
        end)
    end
end)

-- Example of how to use Notification class
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Checks if the received message is 'not'
    if message == 'not' then
        -- Sends a notification when the 'not' message is received
        Notification.Send('Title', 'Content content content', 5, 'center', "#00f300")
        -- Parameters are title, message, duration, position, and color
    end
end)

