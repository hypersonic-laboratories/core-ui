exports('core-ui', 'Notification', function(type, title, message, duration)
    return Notification.Send(type, title, message, duration)
end)

local interactionRegistry = {}

exports('core-ui', 'Interaction', function(id, text, key, duration, onCompleteCallback, onCancelCallback)
    local config = {
        text = text,
        key = key,
        duration = duration,
        onComplete = function()
            if onCompleteCallback then
                TriggerCallback(onCompleteCallback, function() end)
            end
        end,
        onCancel = function()
            if onCancelCallback then
                TriggerCallback(onCancelCallback, function() end)
            end
        end
    }
    print("Created Interaction with ID: " .. id)
    interactionRegistry[id] = Interaction.Create(id, config)
    return id
end)

exports('core-ui', 'InteractionRemove', function(id)
    Interaction.Remove(id)
    interactionRegistry[id] = nil
end)

local contextMenuRegistry = {}
local contextMenuCounter = 0

exports('core-ui', 'ContextMenu', function()
    contextMenuCounter = contextMenuCounter + 1
    local id = "ctx_" .. contextMenuCounter
    contextMenuRegistry[id] = ContextMenu.new()
    return id
end)

exports('core-ui', 'ContextMenuHeader', function(id, title)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:SetHeader(title)
    end
end)

exports('core-ui', 'ContextMenuInfo', function(id, title, description)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:setMenuInfo(title, description)
    end
end)

exports('core-ui', 'ContextMenuButton', function(id, btnId, text, callbackName)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:addButton(btnId, text, function()
            if callbackName then
                TriggerCallback(callbackName, function() end)
            end
        end)
    end
end)

exports('core-ui', 'ContextMenuCheckbox', function(id, checkId, label, checked, callbackName)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:addCheckbox(checkId, label, checked, function(value)
            if callbackName then
                TriggerCallback(callbackName, function() end, value)
            end
        end)
    end
end)

exports('core-ui', 'ContextMenuRange', function(id, rangeId, label, min, max, value, callbackName)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:addRange(rangeId, label, min, max, value, function(val)
            if callbackName then
                TriggerCallback(callbackName, function() end, val)
            end
        end)
    end
end)

exports('core-ui', 'ContextMenuOpen', function(id)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:Open()
    end
end)

exports('core-ui', 'ContextMenuClose', function(id)
    if contextMenuRegistry[id] then
        contextMenuRegistry[id]:Close()
        contextMenuRegistry[id] = nil
    end
end)

local quickMenuRegistry = {}
local quickMenuCounter = 0

exports('core-ui', 'QuickMenuInput', function(title, placeholder, onConfirmCallback, onCancelCallback)
    quickMenuCounter = quickMenuCounter + 1
    local id = "qm_" .. quickMenuCounter
    quickMenuRegistry[id] = QuickMenus.new()

    quickMenuRegistry[id]:ShowInput(title, placeholder,
        function(value)
            if onConfirmCallback then
                TriggerCallback(onConfirmCallback, function() end, value)
            end
            quickMenuRegistry[id]:CloseInput()
            quickMenuRegistry[id] = nil
        end,
        function()
            if onCancelCallback then
                TriggerCallback(onCancelCallback, function() end)
            end
            quickMenuRegistry[id]:CloseInput()
            quickMenuRegistry[id] = nil
        end
    )

    return id
end)

exports('core-ui', 'QuickMenuConfirm', function(title, message, onYesCallback, onNoCallback)
    quickMenuCounter = quickMenuCounter + 1
    local id = "qm_" .. quickMenuCounter
    quickMenuRegistry[id] = QuickMenus.new()

    quickMenuRegistry[id]:ShowConfirm(title, message,
        function()
            if onYesCallback then
                TriggerCallback(onYesCallback, function() end)
            end
            quickMenuRegistry[id]:CloseConfirm()
            quickMenuRegistry[id] = nil
        end,
        function()
            if onNoCallback then
                TriggerCallback(onNoCallback, function() end)
            end
            quickMenuRegistry[id]:CloseConfirm()
            quickMenuRegistry[id] = nil
        end
    )

    return id
end)

local selectMenuRegistry = {}
local selectMenuCounter = 0

exports('core-ui', 'SelectMenu', function(title)
    selectMenuCounter = selectMenuCounter + 1
    local id = "sm_" .. selectMenuCounter
    selectMenuRegistry[id] = SelectMenu.new()
    selectMenuRegistry[id]:SetTitle(title)
    return id
end)

exports('core-ui', 'SelectMenuOption', function(id, optId, name, image, description, info, callbackName)
    if selectMenuRegistry[id] then
        selectMenuRegistry[id]:addOption(optId, name, image, description, info, function()
            if callbackName then
                TriggerCallback(callbackName, function() end)
            end
        end)
    end
end)

exports('core-ui', 'SelectMenuOpen', function(id)
    if selectMenuRegistry[id] then
        selectMenuRegistry[id]:Open()
    end
end)

exports('core-ui', 'SelectMenuClose', function(id)
    if selectMenuRegistry[id] then
        selectMenuRegistry[id]:Close()
        selectMenuRegistry[id] = nil
    end
end)
