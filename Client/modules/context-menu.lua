-- Define the ContextMenu class
local ContextMenu = {}
ContextMenu.__index = ContextMenu
ContextMenu.currentInstance = nil

-- Create a new WebUI instance for the context menu
ContextMenu.UI = WebUI("ContextMenu", "file:///ui/context-menu/index.html")

-- Constructor to create a new ContextMenu instance
function ContextMenu.new()
    local self = setmetatable({}, ContextMenu)
    self.items = {}                    -- Stores menu items
    ContextMenu.currentInstance = self -- Keeps track of current instance

    return self
end

-- Add a button to the menu
function ContextMenu:addButton(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "button",
        text = text,
        callback = callback
    })
end

-- Add a checkbox to the menu
function ContextMenu:addCheckbox(id, label, checked, callback)
    checked = checked or false
    table.insert(self.items, {
        id = id,
        type = "checkbox",
        label = label,
        checked = checked,
        callback = callback
    })
end

-- Add a dropdown to the menu (with nested dropdown support)
function ContextMenu:addDropdown(id, label, options, callback)
    local dropdownOptions = {}
    for _, item in ipairs(options) do
        local newItem = {
            type     = item.type,
            id       = item.id,
            label    = item.label,
            callback = item.callback
        }
        if item.type == "dropdown" and item.options then
            newItem.options = item.options
        end
        table.insert(dropdownOptions, newItem)
    end

    table.insert(self.items, {
        id       = id,
        label    = label,
        type     = "dropdown",
        options  = dropdownOptions,
        callback = callback
    })
end

-- Add a range slider to the menu
function ContextMenu:addRange(id, label, min, max, value, callback)
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

-- Add a text input field to the menu
function ContextMenu:addTextInput(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "text-input",
        label = text,
        callback = callback
    })
end

-- Add a password input
function ContextMenu:addPassword(id, label, placeholder, callback)
    placeholder = placeholder or ""
    table.insert(self.items, {
        id = id,
        type = "password",
        label = label,
        placeholder = placeholder,
        callback = callback
    })
end

-- Add a radio group
function ContextMenu:addRadio(id, label, radioOptions, callback)
    -- radioOptions = { { value = "cash", text = "Cash", checked = true }, ... }
    table.insert(self.items, {
        id = id,
        type = "radio",
        label = label,
        options = radioOptions,
        callback = callback
    })
end

-- Add a number input
function ContextMenu:addNumber(id, label, defaultValue, callback)
    defaultValue = defaultValue or 0
    table.insert(self.items, {
        id = id,
        type = "number",
        label = label,
        value = defaultValue,
        callback = callback
    })
end

-- Add a select (dropdown) input
function ContextMenu:addSelect(id, label, selectOptions, callback)
    -- selectOptions = { { value = "none", text = "None", selected = true }, ... }
    table.insert(self.items, {
        id = id,
        type = "select",
        label = label,
        options = selectOptions,
        callback = callback
    })
end

-- Get current menu items
function ContextMenu:getItems()
    return self.items
end

-- Send notification to WebUI
function ContextMenu:SendNotification(title, text, time, position, color)
    self.UI:CallEvent("ShowNotification", {
        title = title,
        message = text,
        duration = time,
        pos = position,
        color = color
    })
end

-- Open the context menu
function ContextMenu:Open(input, mouse)
    local items = self:getItems()
    self.UI:CallEvent("buildContextMenu", items)
    self.UI:BringToFront()
    Input.SetInputEnabled(input)
    Input.SetMouseEnabled(mouse)
end

-- Set menu information
function ContextMenu:setMenuInfo(title, description)
    self.UI:CallEvent("setMenuInfo", title, description)
end

-- Set menu header
function ContextMenu:SetHeader(title)
    self.Header = title
    self.UI:CallEvent("setHeader", title)
end

-- Close the context menu
function ContextMenu:Close()
    self.UI:CallEvent("closeContextMenu")
    Input.SetInputEnabled(true)
    Input.SetMouseEnabled(false)
end

-- Execute callback for a specific menu item
function ContextMenu:executeCallback(id, params)
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

-- Subscribe to CloseMenu event from WebUI
ContextMenu.UI:Subscribe("CloseMenu", function()
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:Close()
    end
end)

-- Subscribe to ExecuteCallback event from WebUI
ContextMenu.UI:Subscribe("ExecuteCallback", function(id, params)
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:executeCallback(id, params)
    end
end)

-- Subscribe to KeyUp event to close menu
Input.Subscribe("KeyUp", function(keyName)
    if keyName == "BackSpace" and ContextMenu.currentInstance then
        ContextMenu.currentInstance:Close()
    end
end)

-- Example usage of context menu
Chat.Subscribe("PlayerSubmit", function(message, player)
    if message == "/menu" then
        local myMenu = ContextMenu.new()

        -- Botón simple
        myMenu:addButton("button-id", "Button - Function", function()
            Chat.AddMessage("Pressed addbutton")
        end)

        -- Checkbox simple
        myMenu:addCheckbox("checkbox-id", "Checkbox", true, function()
            Chat.AddMessage("Pressed a checkbox")
        end)

        -- Dropdown directo
        myMenu:addDropdown("set-user", "Change Map", {
            {
                id = "opt1",
                label = "Option 1",
                type = "checkbox",
                checked = false,
                callback = function()
                    Chat.AddMessage('Selected: Option 1')
                end
            },
            {
                id = "opt2",
                label = "Option 2",
                type = "checkbox",
                checked = false,
                callback = function()
                    Chat.AddMessage('Selected: Option 2')
                end
            }
        })

        -- Dropdown con text-input
        myMenu:addDropdown("dropdown-id", "Set Player money", {
            {
                id = "1",
                label = "Bank",
                type = "text-input",
                callback = function(val)
                    Chat.AddMessage('Entered bank amount: ' .. val)
                end
            },
            {
                id = "2",
                label = "Cash",
                type = "text-input",
                callback = function(val)
                    Chat.AddMessage('Entered cash amount: ' .. val)
                end
            }
        })

        -- Range / slider
        myMenu:addRange("quantity", "Quantity", 0, 100, 50, function(value)
            Chat.AddMessage('Range value: ' .. value)
        end)

        -- Text input normal
        myMenu:addTextInput("text-input", "Text input", function(text)
            Chat.AddMessage('Text input: ' .. text)
        end)

        -- Password input
        myMenu:addPassword("pwd-1", "Password Input", "Enter Password", function(value)
            Chat.AddMessage("Password entered: " .. value)
        end)

        -- Radio group
        myMenu:addRadio("radio-1", "Payment Method", {
            { value = "bill", text = "Bill", checked = false },
            { value = "cash", text = "Cash", checked = true },
            { value = "bank", text = "Bank", checked = false },
        }, function(selectedValue)
            Chat.AddMessage("Radio selected: " .. selectedValue)
        end)

        -- Number input
        myMenu:addNumber("number-1", "Number Input", 42, function(val)
            Chat.AddMessage("Number input: " .. val)
        end)

        -- Select input
        myMenu:addSelect("select-1", "Select Something", {
            { value = "none", text = "None", selected = true },
            { value = "one", text = "Option One" },
            { value = "two", text = "Option Two" },
        }, function(selected)
            Chat.AddMessage("Selected from dropdown: " .. selected)
        end)

        myMenu:Open(false, true)
    end
end)


-- Export the ContextMenu class
Package.Export("ContextMenu", ContextMenu)
