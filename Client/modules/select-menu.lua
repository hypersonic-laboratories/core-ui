-- Define the SelectMenu class
SelectMenu = {}
SelectMenu.__index = SelectMenu
SelectMenu.currentInstance = nil -- Static reference to the current instance

-- Create a new WebUI instance for the select menu
SelectMenu.UI = WebUI("SelectMenu", "file:///ui/select-menu/index.html")

-- Constructor for creating a new SelectMenu instance
function SelectMenu.new()
    local self = setmetatable({}, SelectMenu)
    self.options = {}                 -- Stores menu options
    SelectMenu.currentInstance = self -- Keeps track of the current instance
    return self
end

-- Adds an option to the select menu
function SelectMenu:addOption(id, text, image, description, callback)
    -- Inserts a new option with the given ID, text, image, description, and callback
    table.insert(self.options, {
        id = id,
        text = text,
        image = image,
        description = description,
        callback = callback
    })
end

-- Opens the select menu
function SelectMenu:Open()
    -- Sends the current options to the WebUI and configures input settings
    if SelectMenu.currentInstance then
        SelectMenu.UI:CallEvent("OpenOptionsMenu", self.options)
        SelectMenu.UI:BringToFront()
        Input.SetInputEnabled(false)
        Input.SetMouseEnabled(true)
    end
end

-- Closes the select menu
function SelectMenu:Close()
    -- Calls the WebUI event to close the select menu
    if SelectMenu.currentInstance then
        SelectMenu.UI:CallEvent("closeSelectMenu")
        Input.SetInputEnabled(true)
        Input.SetMouseEnabled(false)
    end
end

-- Executes a callback for a specific menu option
function SelectMenu:executeOptionCallback(id)
    -- Iterates through the options to find the one with the matching ID and executes its callback
    for _, option in ipairs(self.options) do
        if option.id == id and option.callback then
            option.callback()
            return
        end
    end
end

-- Subscribes to the ExecuteOptionCallback event from the WebUI
SelectMenu.UI:Subscribe("ExecuteOptionCallback", function(id)
    -- Executes the callback for the option with the specified ID
    if SelectMenu.currentInstance then
        SelectMenu.currentInstance:executeOptionCallback(id)
    end
end)

-- Chat command handling for testing select menu
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

-- Subscribes to the KeyUp event to close the select menu
Input.Subscribe("KeyUp", function(keyName)
    if keyName == "BackSpace" then
        -- Closes the select menu when the BackSpace key is pressed
        if SelectMenu.currentInstance then
            SelectMenu.currentInstance:Close()
        end
    end
end)

-- Subscribes to a custom event to close the select menu
Events.Subscribe("CloseSelectMenu", function()
    -- Closes the select menu
    SelectMenu:Close()
end)
