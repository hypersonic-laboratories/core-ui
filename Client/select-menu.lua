-- Select Menu System - New HELIX API
-- Provides a voting/selection menu with images and descriptions

SelectMenu = {}
SelectMenu.__index = SelectMenu
SelectMenu.UI = nil
SelectMenu.UIReady = false
SelectMenu.currentInstance = nil
SelectMenu.pendingOpen = nil
SelectMenu.destroyTimer = nil

-- Initialize the select menu UI
function SelectMenu.Init()
    if SelectMenu.UI then return end
    
    if SelectMenu.destroyTimer then
        Timer.ClearTimeout(SelectMenu.destroyTimer)
        SelectMenu.destroyTimer = nil
    end
    
    local uiPath = "Client/ui/select-menu/index.html"
    SelectMenu.UI = WebUI("SelectMenuUI", uiPath, true)
    SelectMenu.UIReady = false
    
    Timer.SetTimeout(function()
        if SelectMenu.UI then
            SelectMenu.UI:RegisterEventHandler("OnOptionSelected", function(data)
                if data and data.optionId then
                    SelectMenu.OnOptionSelected(data.optionId)
                end
            end)
            
            SelectMenu.UI:RegisterEventHandler("OnBackspace", function(data)
                SelectMenu.OnBackspace()
            end)
        end
        
        SelectMenu.UIReady = true
        
        if SelectMenu.pendingOpen then
            SelectMenu._OpenImmediate(SelectMenu.pendingOpen.options, 
                SelectMenu.pendingOpen.title, 
                SelectMenu.pendingOpen.playersCount)
            SelectMenu.pendingOpen = nil
        end
    end, 500)
end

-- Constructor
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

-- Internal: Send options to UI (with workaround for HELIX JSON bug)
function SelectMenu._SendOptionsToUI(options)
    if not SelectMenu.UI then return end
    
    -- Clear previous options
    SelectMenu.UI:CallFunction("clearOptions")
    
    -- Send each option individually to bypass JSON bug
    for i, option in ipairs(options) do
        -- Send basic option data
        SelectMenu.UI:CallFunction("addOption", 
            option.id,
            option.name,
            option.image,
            option.description
        )
        
        -- Send info items separately if they exist
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
    
    -- Build the menu after all options are sent
    SelectMenu.UI:CallFunction("buildMenu")
end

-- Internal: Open immediately (when UI is ready)
function SelectMenu._OpenImmediate(options, title, playersCount)
    if SelectMenu.UI then
        local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
        if controller then
            controller.bShowMouseCursor = true
            controller.bEnableClickEvents = true
        end
        
        Timer.SetTimeout(function()
            if SelectMenu.UI then
                SelectMenu.UI:CallFunction("setMenuTitle", title)
                SelectMenu.UI:CallFunction("setPlayersCount", tostring(playersCount))
                
                SelectMenu._SendOptionsToUI(options)
                
                SelectMenu.UI:CallFunction("showMenu")
            end
        end, 100)
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

-- Close the menu
function SelectMenu:Close()
    if SelectMenu.UI then
        SelectMenu.UI:CallFunction("hideMenu")
    end
    
    local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
    if controller then
        controller.bShowMouseCursor = false
        controller.bEnableClickEvents = false
    end
    
    SelectMenu._ScheduleDestroy()
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

function SelectMenu._ScheduleDestroy()
    if SelectMenu.destroyTimer then
        Timer.ClearTimeout(SelectMenu.destroyTimer)
    end
    
    SelectMenu.destroyTimer = Timer.SetTimeout(function()
        if SelectMenu.UI then
            SelectMenu.UI:Destroy()
            SelectMenu.UI = nil
            SelectMenu.UIReady = false
        end
        SelectMenu.destroyTimer = nil
    end, 1000)
end

-- Destroy the select menu system
function SelectMenu.Destroy()
    if SelectMenu.destroyTimer then
        Timer.ClearTimeout(SelectMenu.destroyTimer)
        SelectMenu.destroyTimer = nil
    end
    
    if SelectMenu.UI then
        SelectMenu.UI:Destroy()
        SelectMenu.UI = nil
    end
    SelectMenu.UIReady = false
    SelectMenu.currentInstance = nil
    SelectMenu.pendingOpen = nil
end

-- Global reference
_G.SelectMenu = SelectMenu