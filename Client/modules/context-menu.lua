-- Define the ContextMenu class
ContextMenu = {}
ContextMenu.__index = ContextMenu
ContextMenu.currentInstance = nil

-- Create a new WebUI instance for the context menu
ContextMenu.UI = WebUI("ContextMenu", "file:///ui/context-menu/index.html")

-- Constructor for creating a new ContextMenu instance
function ContextMenu.new()
    local self = setmetatable({}, ContextMenu)
    self.items = {}                    -- Stores menu items
    ContextMenu.currentInstance = self -- Keeps track of the current instance

    return self
end

-- Adds a button to the menu
function ContextMenu:addButton(id, text, callback)
    -- Inserts a new button item with the given ID, text, and callback
    table.insert(self.items, {
        id = id,
        type = "button",
        text = text,
        callback = callback
    })
end

-- Adds a checkbox to the menu
function ContextMenu:addCheckbox(id, label, checked, callback)
    -- Inserts a new checkbox item with the given ID, label, checked state, and callback
    checked = checked or false
    table.insert(self.items, {
        id = id,
        type = "checkbox",
        label = label,
        checked = checked,
        callback = callback
    })
end

-- Adds a dropdown to the menu
function ContextMenu:addDropdown(id, label, options, callback)
    -- Inserts a new dropdown item with the given ID, options, and callback
    local dropdownOptions = {}
    for i, option in ipairs(options) do
        table.insert(dropdownOptions, {
            type = option.type,
            id = option.id,
            label = option.label,
            callback = option.callback
        })
    end
    table.insert(self.items, {
        id = id,
        label = label,
        type = "dropdown",
        options = dropdownOptions,
        callback = callback
    })
end

-- Adds a range input to the menu
function ContextMenu:addRange(id, label, min, max, value, callback)
    -- Inserts a new range item with the given ID, label, min, max values, and callback
    min = min or 0
    max = max or 100
    value = value or min
    table.insert(self.items, {
        id = id,
        type = "range",
        label = label,
        min = min,
        max = max,
        value = value,
        callback = callback
    })
end

-- Adds a text input to the menu
function ContextMenu:addTextInput(id, text, callback)
    -- Inserts a new text input item with the given ID, text, and callback
    table.insert(self.items, {
        id = id,
        type = "text-input",
        label = text,
        callback = callback
    })
end

-- Retrieves the current menu items
function ContextMenu:getItems()
    return self.items
end

-- Sends a notification event to the WebUI
function ContextMenu:SendNotification(title, text, time, position, color)
    -- Calls the WebUI event to show a notification with the provided details
    self.UI:CallEvent("ShowNotification",
        { title = title, message = text, duration = time, pos = position, color = color })
end

-- Adds a range input to the menu
function ContextMenu:addRange(id, label, min, max, value, callback)
    -- Inserts a new range item with the given ID, label, min, max values, and callback
    min = min or 0
    max = max or 100
    value = value or min
    table.insert(self.items, {
        id = id,
        type = "range",
        label = label,
        min = min,
        max = max,
        value = value,
        callback = callback
    })
end

-- Adds a text input to the menu
function ContextMenu:addTextInput(id, text, callback)
    -- Inserts a new text input item with the given ID, text, and callback
    table.insert(self.items, {
        id = id,
        type = "text-input",
        label = text,
        callback = callback
    })
end

-- Retrieves the current menu items
function ContextMenu:getItems()
    return self.items
end

-- Sends a notification event to the WebUI
function ContextMenu:SendNotification(title, text, time, position, color)
    -- Calls the WebUI event to show a notification with the provided details
    self.UI:CallEvent("ShowNotification",
        { title = title, message = text, duration = time, pos = position, color = color })
end

-- Opens the menu
function ContextMenu:Open(input, mouse)
    -- Gets the current items, sends them to the WebUI, and configures input settings
    local items = self:getItems()
    self.UI:CallEvent("buildContextMenu", items)
    self.UI:BringToFront()
    Input.SetInputEnabled(input)
    Input.SetMouseEnabled(mouse)
end

function ContextMenu:setMenuInfo(title, description)
    self.UI:CallEvent("setMenuInfo", title, description)
end

function ContextMenu:SetHeader(title)
    self.Header = title

    self.UI:CallEvent("setHeader", title)
end

-- Closes the menu
function ContextMenu:Close()
    -- Calls the WebUI event to close the context menu
    self.UI:CallEvent("closeContextMenu")
    Input.SetInputEnabled(true)
    Input.SetMouseEnabled(false)
end

-- Subscribes to the CloseMenu event from the WebUI
ContextMenu.UI:Subscribe("CloseMenu", function()
    -- Triggers the close function when the CloseMenu event is received
    ContextMenu:Close()
end)

-- Executes a callback for a specific menu item
function ContextMenu:executeCallback(id, params)
    -- Iterates through the items to find the one with the matching ID and executes its callback
    for _, item in ipairs(self.items) do
        if item.id == id and item.callback then
            item.callback(params)
            return
        end

        if item.options then
            for _, option in ipairs(item.options) do
                if option.id == id and option.callback then
                    option.callback(params)
                    return
                end
            end
        end
    end
end

-- Subscribes to the ExecuteCallback event from the WebUI
ContextMenu.UI:Subscribe("ExecuteCallback", function(id, params)
    -- Executes the callback for the item with the specified ID
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:executeCallback(id, params)
    end
end)

-- Subscribes to the KeyUp event to close the menu
Input.Subscribe("KeyUp", function(keyName)
    if keyName == "BackSpace" then
        -- Closes the menu when the BackSpace key is released
        if ContextMenu.currentInstance then
            ContextMenu.currentInstance:Close()
        end
    end
end)

-- Example of how to use the context menu
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "/menu" then
        local myMenu = ContextMenu.new()
        myMenu:addButton("button-id", "Buton - Function", function()
            Chat.AddMessage("I pressed addbutton")
        end)
        myMenu:addCheckbox("checkbox-id", "Checkbox", true, function()
            Chat.AddMessage('I pressed a checbkox')
        end)
        myMenu:addDropdown("set-user", "Change Map",
            {
                {
                    id = "1",
                    label = "Option 1",
                    type = "checkbox",
                    checked = false,
                    callback = function()
                        Chat.AddMessage('Selected option: Option 1')
                    end
                },
                {
                    id = "2",
                    label = "Option 2",
                    type = "checkbox",
                    checked = false,
                    callback = function()
                        Chat.AddMessage('Selected option: Option 2')
                    end
                }
            }
        )

        myMenu:addDropdown("dropdown-id", "Set Player money",
            {
                {
                    id = "1",
                    label = "Bank",
                    type = "text-input",
                    callback = function()
                        Chat.AddMessage('Selected option: Bank')
                    end
                },
                {
                    id = "2",
                    label = "Cash",
                    type = "text-input",
                    callback = function()
                        Chat.AddMessage('Selected option: Cash')
                    end
                }
            }
        )
        myMenu:addRange("quantity", "Quantity", 0, 100, 50, function(value)
            Chat.AddMessage('range value: ' .. value)
        end)
        myMenu:addTextInput("text-input", "Text input", function(text)
            Chat.AddMessage('text input: ' .. text)
        end)

        myMenu:Open(false, true) -- Enable input, Enable mouse
    end
end)


Package.Export("ContextMenu", ContextMenu)