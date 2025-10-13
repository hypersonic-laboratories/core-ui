-- ContextMenu Class

local ContextMenu = {}
ContextMenu.__index = ContextMenu
ContextMenu.currentInstance = nil
ContextMenu.focusIndex = 1

function ContextMenu.new()
    local self = setmetatable({}, ContextMenu)
    self.items = {}
    self.UI = nil
    ContextMenu.currentInstance = self

    return self
end

function ContextMenu:addButton(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "button",
        text = text,
        callback = callback
    })
end

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

function ContextMenu:addDropdown(id, label, options, callback)
    local dropdownOptions = {}
    for _, item in ipairs(options) do
        local newItem = {}
        for k, v in pairs(item) do
            newItem[k] = v
        end

        if newItem.type == "dropdown" and newItem.options then
            newItem.options = {}
            for _, subItem in ipairs(item.options) do
                local newSubItem = {}
                for k, v in pairs(subItem) do
                    newSubItem[k] = v
                end
                table.insert(newItem.options, newSubItem)
            end
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

function ContextMenu:addTextInput(id, text, callback)
    table.insert(self.items, {
        id = id,
        type = "text-input",
        label = text,
        callback = callback
    })
end

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

function ContextMenu:addRadio(id, label, radioOptions, callback)
    table.insert(self.items, {
        id = id,
        type = "radio",
        label = label,
        options = radioOptions,
        callback = callback
    })
end

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

function ContextMenu:addSelect(id, label, selectOptions, callback)
    table.insert(self.items, {
        id = id,
        type = "select",
        label = label,
        options = selectOptions,
        callback = callback
    })
end

function ContextMenu:addText(id, data)
    local is_list = false
    if type(data) == "table" then
        is_list = true
    end

    table.insert(self.items, {
        id = id,
        type = "text-display",
        data = data,
        is_list = is_list
    })
end

function ContextMenu:addColorPicker(id, label, defaultColor, callback)
    defaultColor = defaultColor or "#ffffff"
    table.insert(self.items, {
        id = id,
        type = "color",
        label = label,
        value = defaultColor,
        callback = callback
    })
end

function ContextMenu:addDatePicker(id, label, defaultDate, callback)
    defaultDate = defaultDate or "2024-01-01"
    table.insert(self.items, {
        id = id,
        type = "date",
        label = label,
        value = defaultDate,
        callback = callback
    })
end

function ContextMenu:addListPicker(id, label, items, callback)
    table.insert(self.items, {
        id = id,
        type = "list-picker",
        label = label,
        list = items,
        callback = callback
    })
end

function ContextMenu:getItems()
    return self.items
end

function ContextMenu:SendNotification(title, text, time, position, color)
    if self.UI then
        self.UI:CallFunction("ShowNotification", {
            title = title,
            message = text,
            duration = time,
            pos = position,
            color = color
        })
    end
end

function ContextMenu:Open(disable_game_input, enable_mouse)
    if self.UI then
        self.UI:Destroy()
        self.UI = nil
    end

    local uiPath = "Client/ui/context-menu/index.html"
    self.UI = WebUI("ContextMenu", uiPath, true)

    ContextMenu.currentInstance = self
    self.isOpen = true


    Timer.SetTimeout(function()
        if self.UI then
            self.UI:RegisterEventHandler('ExecuteCallback', function(data)
                if data and data.id then
                    self:executeCallback(data.id, data.params)
                end
            end)

            self.UI:RegisterEventHandler('CloseMenu', function(data)
                self:Close()
            end)

            local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
            if controller then
                controller.bShowMouseCursor = enable_mouse
                controller.bEnableClickEvents = enable_mouse
                controller:SetIgnoreLookInput(disable_game_input)
                controller:SetIgnoreMoveInput(disable_game_input)
            end

            Timer.SetTimeout(function()
                local items = self:getItems()

                self.UI:CallFunction("clearMenuItems", nil)

                for i, item in ipairs(items) do
                    if item.type == "button" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.text or "", "", "", "", "", "")
                    elseif item.type == "checkbox" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", "", "", "", tostring(item.checked), "")
                    elseif item.type == "range" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", tostring(item.value), tostring(item.min), tostring(item.max), "", "")
                    elseif item.type == "text-input" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", "", "", "", "", "")
                    elseif item.type == "password" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", "", "", "", "", item.placeholder or "")
                    elseif item.type == "number" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", tostring(item.value), "", "", "", "")
                    elseif item.type == "color" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", item.value or "#ffffff", "", "", "", "")
                    elseif item.type == "date" then
                        self.UI:CallFunction("addMenuItem", item.id, item.type, item.label or "", item.value or "2024-01-01", "", "", "", "")
                    elseif item.type == "text-display" then
                        local dataStr = item.data
                        if type(item.data) == "table" then
                            dataStr = table.concat(item.data, ", ")
                        end
                        self.UI:CallFunction("addMenuItem", item.id, item.type, dataStr or "", "", "", "", "", "")
                    elseif item.type == "dropdown" then
                        self.UI:CallFunction("addDropdownItem", item.id, item.label or "")
                        if item.options then
                            for _, opt in ipairs(item.options) do
                                self.UI:CallFunction("addDropdownOption", opt.id, opt.type or "button", opt.text or opt.label or "")
                            end
                        end
                    elseif item.type == "radio" then
                        self.UI:CallFunction("addRadioItem", item.id, item.label or "")
                        if item.options then
                            for _, opt in ipairs(item.options) do
                                self.UI:CallFunction("addRadioOption", opt.value, opt.text or "", tostring(opt.checked))
                            end
                        end
                    elseif item.type == "select" then
                        self.UI:CallFunction("addSelectItem", item.id, item.label or "")
                        if item.options then
                            for _, opt in ipairs(item.options) do
                                self.UI:CallFunction("addSelectOption", opt.value, opt.text or "", tostring(opt.selected))
                            end
                        end
                    end
                end

                self.UI:CallFunction("buildMenuFromPending", nil)

                if self.Header then
                    self.UI:CallFunction("setHeader", self.Header)
                end
                
                if self.MenuTitle or self.MenuDescription then
                    self.UI:CallFunction("setMenuInfo", self.MenuTitle or "", self.MenuDescription or "")
                end

                self.UI:CallFunction("ForceFocusOnUI", {})
            end, 1000)
        end
    end, 500)
end

function ContextMenu:setMenuInfo(title, description)
    self.MenuTitle = title
    self.MenuDescription = description
    
    if self.UI then
        self.UI:CallFunction("setMenuInfo", title or "", description or "")
    end
end

function ContextMenu:SetHeader(title)
    self.Header = title
    if self.UI then
        self.UI:CallFunction("setHeader", title)
    end
end

function ContextMenu:getFlattenedItems()
    local results = {}
    local function traverse(items)
        for _, item in ipairs(items) do
            table.insert(results, item)

            if item.type == "dropdown" and item.expanded and item.options then
                traverse(item.options)
            end
        end
    end
    traverse(self.items)
    return results
end

function ContextMenu:focusNext()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    self.focusIndex = self.focusIndex + 1
    if self.focusIndex > #flattened then
        self.focusIndex = #flattened
    end
    self:focusItem(flattened[self.focusIndex])
end

function ContextMenu:focusPrevious()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    self.focusIndex = self.focusIndex - 1
    if self.focusIndex < 1 then
        self.focusIndex = 1
    end
    self:focusItem(flattened[self.focusIndex])
end

function ContextMenu:expandFocused()
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current or current.type ~= "dropdown" then return end
    current.expanded = true
    self:refreshMenu()
end

function ContextMenu:collapseFocused()
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current or current.type ~= "dropdown" or not current.expanded then return end
    current.expanded = false
    self:refreshMenu()
end

function ContextMenu:focusItem(item)
    if not item or not self.UI then return end
    self.UI:CallFunction("FocusOptionById", item.id)
end

function ContextMenu:refreshMenu()
    if self.UI then
        self.UI:CallFunction("buildContextMenu", self.items)
        local flattened = self:getFlattenedItems()
        if self.focusIndex > #flattened then
            self.focusIndex = #flattened
        end
        if flattened[self.focusIndex] then
            self:focusItem(flattened[self.focusIndex])
        end
    end
end

function ContextMenu:setInitialFocus()
    self.focusIndex = 1
    local flattened = self:getFlattenedItems()
    if #flattened > 0 then
        self:focusItem(flattened[self.focusIndex])
    end
end

function ContextMenu:Close()
    self.isOpen = false
    if self.UI then
        self.UI:CallFunction("closeContextMenu", {})

        local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
        if controller then
            controller.bShowMouseCursor = false
            controller.bEnableClickEvents = false
            controller:SetIgnoreLookInput(false)
            controller:SetIgnoreMoveInput(false)
        end

        Timer.SetTimeout(function()
            if self.UI then
                self.UI:Destroy()
                self.UI = nil
            end
        end, 100)
    end
end

function ContextMenu:executeCallback(id, params)
    for _, item in ipairs(self.items) do
        if item.id == id then
            local is_valid, err_msg = self:validateInput(item, params)
            if not is_valid then
                self:ShowError(err_msg)
                return
            end
            if item.callback then
                item.callback(params)
            end
            return
        end

        if item.options then
            for _, option in ipairs(item.options) do
                if option.id == id then
                    local is_valid, err_msg = self:validateInput(option, params)
                    if not is_valid then
                        self:ShowError(err_msg)
                        return
                    end
                    if option.callback then
                        option.callback(params)
                    end
                    return
                end
            end
        end
    end
end

function ContextMenu:validateInput(item, params)
    if item.type == "text-input" then
        if type(params) ~= "string" or params == "" then
            return false, "Input cannot be empty."
        end
        if #params > 50 then
            return false, "Input is too long."
        end
    end

    if item.type == "number" then
        local val = tonumber(params)
        if not val then
            return false, "Value must be a number."
        end
        if (item.min and val < item.min) or (item.max and val > item.max) then
            return false, "Value is out of the allowed range."
        end
    end

    if item.type == "password" then
        if type(params) ~= "string" or #params < 4 then
            return false, "Password is too short."
        end
        if not string.match(params, "%d") then
            return false, "Password must contain at least one digit."
        end
    end

    if item.type == "checkbox" then
        if type(params) ~= "boolean" then
            return false, "Invalid checkbox state."
        end
    end

    if item.type == "radio" and item.options then
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.value == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid radio selection."
        end
    end

    if item.type == "select" and item.options then
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.value == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid selection."
        end
    end

    if item.type == "dropdown" and item.options then
        local found = false
        for _, opt in ipairs(item.options) do
            if opt.id == params or opt.label == params then
                found = true
                break
            end
        end
        if not found then
            return false, "Invalid dropdown choice."
        end
    end

    if item.type == "range" then
        local val = tonumber(params)
        if not val then
            return false, "Value must be a number."
        end
        if (item.min and val < item.min) or (item.max and val > item.max) then
            return false, "Value is out of range."
        end
    end

    return true
end

function ContextMenu:ShowError(message)
    if Notification and Notification.Send then
        Notification.Send("error", "Invalid Input", message)
    end
end

function ContextMenu:enterOrEdit()
    local flattened = self:getFlattenedItems()
    if #flattened < 1 then return end
    local current = flattened[self.focusIndex]
    if not current then return end

    if current.type == "range" or current.type == "number" or current.type == "text-input" then
        self.editMode = true
    elseif current.type == "dropdown" then
        if not current.expanded then
            current.expanded = true
            self:refreshMenu()
        else
            if self.UI then
                self.UI:CallFunction("SelectFocusedOption", {})
            end
        end
    else
        if self.UI then
            self.UI:CallFunction("SelectFocusedOption", {})
        end
    end
end

function ContextMenu:adjustCurrentOptionValue(keyName)
    local flattened = self:getFlattenedItems()
    local current = flattened[self.focusIndex]
    if not current then return end

    if current.type == "range" or current.type == "number" then
        local step = 1
        if keyName == "ArrowLeft" then
            current.value = math.max(current.min or 0, current.value - step)
        else
            current.value = math.min(current.max or 100, current.value + step)
        end
        if current.callback then
            current.callback(current.value)
        end
        self:refreshMenu()
    end
end

function ContextMenu_CloseMenu()
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:Close()
    end
end

function ContextMenu_ExecuteCallback(id, params)
    if ContextMenu.currentInstance then
        ContextMenu.currentInstance:executeCallback(id, params)
    end
end

_G.ContextMenu = ContextMenu