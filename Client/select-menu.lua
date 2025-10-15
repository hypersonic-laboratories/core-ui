-- Select Menu System - New HELIX API
-- Provides a voting/selection menu with images and descriptions

SelectMenu = {}
SelectMenu.__index = SelectMenu
SelectMenu.UI = nil
SelectMenu.UIReady = false
SelectMenu.isVisible = false
SelectMenu.currentInstance = nil
SelectMenu.pendingOpen = nil

function SelectMenu.Init()
    if SelectMenu.UI then return end
    local uiPath = "core-ui/Client/ui/select-menu/index.html"
    SelectMenu.UI = WebUI("SelectMenuUI", uiPath, 1)

    if SelectMenu.UI then
        SelectMenu.UI:RegisterEventHandler("OnOptionSelected", function(data)
            if data and data.optionId then
                SelectMenu.OnOptionSelected(data.optionId)
            end
        end)

        SelectMenu.UI:RegisterEventHandler("OnBackspace", function(data)
            SelectMenu.OnBackspace()
        end)

        SelectMenu.UI:RegisterEventHandler("Ready", function()
            SelectMenu.UIReady = true

            if SelectMenu.pendingOpen then
                SelectMenu._OpenImmediate(SelectMenu.pendingOpen.options,
                    SelectMenu.pendingOpen.title,
                    SelectMenu.pendingOpen.playersCount)
                SelectMenu.pendingOpen = nil
            end
        end)
    end
end

function SelectMenu.Show()
    if not SelectMenu.UI or SelectMenu.isVisible then return end
    SelectMenu.UI:SetLayer(5)
    SelectMenu.isVisible = true
end

function SelectMenu.Hide()
    if not SelectMenu.UI or not SelectMenu.isVisible then return end
    SelectMenu.UI:SetLayer(1)
    SelectMenu.isVisible = false
end

function SelectMenu.new()
    local self = setmetatable({}, SelectMenu)
    self.options = {} -- Stores the menu options
    self.title = "Select Option"
    SelectMenu.currentInstance = self

    -- Initialize UI if not already done
    if not SelectMenu.UI then
        SelectMenu.Init()
    end

    return self
end

-- Add an option to the menu
function SelectMenu:addOption(id, name, image, description, info, callback)
    table.insert(self.options, {
        id = id,
        name = name,
        image = image,
        description = description,
        info = info,
        callback = callback
    })
end

-- Set the menu title
function SelectMenu:SetTitle(title)
    self.title = title
end

function SelectMenu._SendOptionsToUI(options)
    if not SelectMenu.UI or not SelectMenu.UIReady then return end

    SelectMenu.UI:CallFunction("clearOptions")

    for i, option in ipairs(options) do
        SelectMenu.UI:CallFunction("addOption",
            option.id,
            option.name,
            option.image,
            option.description
        )

        if option.info then
            for j, infoItem in ipairs(option.info) do
                SelectMenu.UI:CallFunction("addOptionInfo",
                    option.id,
                    infoItem.name or "",
                    infoItem.value or "",
                    infoItem.icon or ""
                )
            end
        end
    end

    SelectMenu.UI:CallFunction("buildMenu")
end

function SelectMenu._OpenImmediate(options, title, playersCount)
    if SelectMenu.UI then
        SelectMenu.UI:CallFunction("setMenuTitle", title)
        SelectMenu.UI:CallFunction("setPlayersCount", tostring(playersCount))

        SelectMenu._SendOptionsToUI(options)

        SelectMenu.UI:CallFunction("showMenu")
        SelectMenu.Show()
    end
end

-- Open the menu
function SelectMenu:Open()
    if SelectMenu.currentInstance then
        -- Get player count
        local playersCount = 0 -- Default value, would normally get from game state

        if SelectMenu.UIReady then
            SelectMenu._OpenImmediate(self.options, self.title, playersCount)
        else
            -- Queue the menu to open when UI is ready
            SelectMenu.pendingOpen = {
                options = self.options,
                title = self.title,
                playersCount = playersCount
            }
        end
    end
end

function SelectMenu:Close()
    if SelectMenu.UI then
        SelectMenu.UI:CallFunction("hideMenu")
        SelectMenu.Hide()
    end
end

-- Execute callback for a specific menu item
function SelectMenu:executeCallback(id, params)
    -- Find and execute the callback for the matching ID
    for _, item in ipairs(self.options) do
        if item.id == id and item.callback then
            item.callback(params)
            return
        end
    end
end

-- Handle option selection from JavaScript
function SelectMenu.OnOptionSelected(optionId)
    if SelectMenu.currentInstance then
        SelectMenu.currentInstance:executeCallback(optionId)
    end
end

-- Handle backspace key
function SelectMenu.OnBackspace()
    if SelectMenu.currentInstance then
        SelectMenu.currentInstance:Close()
    end
end

function SelectMenu.Destroy()
    if SelectMenu.currentInstance then
        SelectMenu.currentInstance:Close()
    end

    if SelectMenu.UI then
        SelectMenu.UI:Destroy()
        SelectMenu.UI = nil
        SelectMenu.UIReady = false
        SelectMenu.isVisible = false
    end

    SelectMenu.currentInstance = nil
    SelectMenu.pendingOpen = nil
end

-- Global reference
_G.SelectMenu = SelectMenu

function onShutdown()
    SelectMenu.Destroy()
end
