-- Quick Menus System - New HELIX API
-- Provides simple "quick menus" for input and confirmation dialogs

QuickMenus = {}
QuickMenus.__index = QuickMenus
QuickMenus.UI = nil
QuickMenus.UIReady = false
QuickMenus.current = nil
QuickMenus.pendingDialogs = {}
QuickMenus.destroyTimer = nil

-- Initialize the quick menus UI
function QuickMenus.Init()
    if QuickMenus.UI then return end
    
    if QuickMenus.destroyTimer then
        Timer.ClearTimeout(QuickMenus.destroyTimer)
        QuickMenus.destroyTimer = nil
    end
    
    local uiPath = "Client/ui/quick-menus/index.html"
    QuickMenus.UI = WebUI("QuickMenusUI", uiPath, true)
    QuickMenus.UIReady = false

    Timer.SetTimeout(function()
        if QuickMenus.UI then
            QuickMenus.UI:RegisterEventHandler("OnInputConfirmed", function(data)
                if data and data.value then
                    QuickMenus.OnInputConfirmed(data.value)
                end
            end)

            QuickMenus.UI:RegisterEventHandler("OnInputCanceled", function(data)
                QuickMenus.OnInputCanceled()
            end)

            QuickMenus.UI:RegisterEventHandler("OnConfirmYes", function(data)
                QuickMenus.OnConfirmYes()
            end)

            QuickMenus.UI:RegisterEventHandler("OnConfirmNo", function(data)
                QuickMenus.OnConfirmNo()
            end)
        end
        
        QuickMenus.UIReady = true

        if #QuickMenus.pendingDialogs > 0 then
            local dialog = QuickMenus.pendingDialogs[1]
            table.remove(QuickMenus.pendingDialogs, 1)

            if dialog.type == "input" then
                QuickMenus._ShowInputImmediate(dialog.title, dialog.placeholder)
            elseif dialog.type == "confirm" then
                QuickMenus._ShowConfirmImmediate(dialog.title, dialog.message)
            end
        end
    end, 500)
end

-- Constructor
function QuickMenus.new()
    local self = setmetatable({}, QuickMenus)
    QuickMenus.current = self

    -- Initialize UI if not already done
    if not QuickMenus.UI then
        QuickMenus.Init()
    end

    return self
end

-- Internal: Show input immediately (when UI is ready)
function QuickMenus._ShowInputImmediate(title, placeholder)
    if QuickMenus.UI then
        local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
        if controller then
            controller.bShowMouseCursor = true
            controller.bEnableClickEvents = true
        end
        
        Timer.SetTimeout(function()
            if QuickMenus.UI then
                QuickMenus.UI:CallFunction("showInputMenu", title, placeholder or "")
            end
        end, 100)
    end
end

-- Show an input menu
function QuickMenus:ShowInput(title, placeholder, callback, callback_cancel)
    self.input_callback = callback
    self.input_cancel_callback = callback_cancel

    if QuickMenus.UIReady then
        QuickMenus._ShowInputImmediate(title, placeholder)
    else
        -- Queue the dialog
        table.insert(QuickMenus.pendingDialogs, {
            type = "input",
            title = title,
            placeholder = placeholder
        })
    end
end

-- Internal: Show confirm immediately (when UI is ready)
function QuickMenus._ShowConfirmImmediate(title, message)
    if QuickMenus.UI then
        local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
        if controller then
            controller.bShowMouseCursor = true
            controller.bEnableClickEvents = true
            controller:SetIgnoreLookInput(true)
            controller:SetIgnoreMoveInput(true)
        end
        
        Timer.SetTimeout(function()
            if QuickMenus.UI then
                QuickMenus.UI:CallFunction("showConfirmMenu", title, message)
            end
        end, 100)
    end
end

-- Show a confirmation menu
function QuickMenus:ShowConfirm(title, message, callback_yes, callback_no)
    self.confirm_yes_callback = callback_yes
    self.confirm_no_callback = callback_no

    if QuickMenus.UIReady then
        QuickMenus._ShowConfirmImmediate(title, message)
    else
        -- Queue the dialog
        table.insert(QuickMenus.pendingDialogs, {
            type = "confirm",
            title = title,
            message = message
        })
    end
end

-- Close input menu
function QuickMenus:CloseInput()
    if QuickMenus.UI then
        QuickMenus.UI:CallFunction("hideInputMenu")
    end

    local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
    if controller then
        controller.bShowMouseCursor = false
        controller.bEnableClickEvents = false
        controller:SetIgnoreLookInput(false)
        controller:SetIgnoreMoveInput(false)
    end
    
    QuickMenus._ScheduleDestroy()
end

-- Close confirm menu
function QuickMenus:CloseConfirm()
    if QuickMenus.UI then
        QuickMenus.UI:CallFunction("hideConfirmMenu")
    end

    local controller = UE.UGameplayStatics.GetPlayerController(HWorld, 0)
    if controller then
        controller.bShowMouseCursor = false
        controller.bEnableClickEvents = false
        controller:SetIgnoreLookInput(false)
        controller:SetIgnoreMoveInput(false)
    end
    
    QuickMenus._ScheduleDestroy()
end

-- Handle input confirmation
function QuickMenus.OnInputConfirmed(value)
    if QuickMenus.current and QuickMenus.current.input_callback then
        QuickMenus.current.input_callback(value)
    end
end

-- Handle input cancel
function QuickMenus.OnInputCanceled()
    if QuickMenus.current and QuickMenus.current.input_cancel_callback then
        QuickMenus.current.input_cancel_callback()
    end
end

-- Handle confirm yes
function QuickMenus.OnConfirmYes()
    if QuickMenus.current and QuickMenus.current.confirm_yes_callback then
        QuickMenus.current.confirm_yes_callback()
    end
    if QuickMenus.current then
        QuickMenus.current:CloseConfirm()
    end
end

-- Handle confirm no
function QuickMenus.OnConfirmNo()
    if QuickMenus.current and QuickMenus.current.confirm_no_callback then
        QuickMenus.current.confirm_no_callback()
    end
    if QuickMenus.current then
        QuickMenus.current:CloseConfirm()
    end
end

function QuickMenus._ScheduleDestroy()
    if QuickMenus.destroyTimer then
        Timer.ClearTimeout(QuickMenus.destroyTimer)
    end
    
    QuickMenus.destroyTimer = Timer.SetTimeout(function()
        if QuickMenus.UI then
            QuickMenus.UI:Destroy()
            QuickMenus.UI = nil
            QuickMenus.UIReady = false
        end
        QuickMenus.destroyTimer = nil
    end, 1000)
end

-- Destroy the quick menus system
function QuickMenus.Destroy()
    if QuickMenus.destroyTimer then
        Timer.ClearTimeout(QuickMenus.destroyTimer)
        QuickMenus.destroyTimer = nil
    end
    
    if QuickMenus.UI then
        QuickMenus.UI:Destroy()
        QuickMenus.UI = nil
    end
    QuickMenus.UIReady = false
    QuickMenus.current = nil
    QuickMenus.pendingDialogs = {}
end

-- Global reference
_G.QuickMenus = QuickMenus
