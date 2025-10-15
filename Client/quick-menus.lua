-- Quick Menus System - New HELIX API
-- Provides simple "quick menus" for input and confirmation dialogs

QuickMenus = {}
QuickMenus.__index = QuickMenus
QuickMenus.UI = nil
QuickMenus.UIReady = false
QuickMenus.isVisible = false
QuickMenus.current = nil
QuickMenus.pendingCalls = {}

function QuickMenus.Init()
    if QuickMenus.UI then return end

    local uiPath = "core-ui/Client/ui/quick-menus/index.html"
    QuickMenus.UI = WebUI("QuickMenusUI", uiPath, 1)

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

        QuickMenus.UI:RegisterEventHandler("Ready", function()
            QuickMenus.UIReady = true

            for _, call in ipairs(QuickMenus.pendingCalls) do
                QuickMenus.UI:CallFunction(call.func, table.unpack(call.args))
            end
            QuickMenus.pendingCalls = {}
        end)
    end
end

function QuickMenus.Show()
    if not QuickMenus.UI or QuickMenus.isVisible then return end
    QuickMenus.UI:SetLayer(5)
    QuickMenus.isVisible = true
end

function QuickMenus.Hide()
    if not QuickMenus.UI or not QuickMenus.isVisible then return end
    QuickMenus.UI:SetLayer(1)
    QuickMenus.isVisible = false
end

function QuickMenus.new()
    local self = setmetatable({}, QuickMenus)
    QuickMenus.current = self

    -- Initialize UI if not already done
    if not QuickMenus.UI then
        QuickMenus.Init()
    end

    return self
end

function QuickMenus._ShowInputImmediate(title, placeholder)
    if QuickMenus.UIReady then
        QuickMenus.UI:CallFunction("showInputMenu", title, placeholder or "")
        QuickMenus.Show()
    else
        table.insert(QuickMenus.pendingCalls, {
            func = "showInputMenu",
            args = {title, placeholder or ""}
        })
    end
end

-- Show an input menu
function QuickMenus:ShowInput(title, placeholder, callback, callback_cancel)
    self.input_callback = callback
    self.input_cancel_callback = callback_cancel

    QuickMenus._ShowInputImmediate(title, placeholder)
end

function QuickMenus._ShowConfirmImmediate(title, message)
    if QuickMenus.UIReady then
        QuickMenus.UI:CallFunction("showConfirmMenu", title, message)
        QuickMenus.Show()
    else
        table.insert(QuickMenus.pendingCalls, {
            func = "showConfirmMenu",
            args = {title, message}
        })
    end
end

-- Show a confirmation menu
function QuickMenus:ShowConfirm(title, message, callback_yes, callback_no)
    self.confirm_yes_callback = callback_yes
    self.confirm_no_callback = callback_no

    QuickMenus._ShowConfirmImmediate(title, message)
end

function QuickMenus:CloseInput()
    if QuickMenus.UI then
        QuickMenus.UI:CallFunction("hideInputMenu")
        QuickMenus.Hide()
    end
end

function QuickMenus:CloseConfirm()
    if QuickMenus.UI then
        QuickMenus.UI:CallFunction("hideConfirmMenu")
        QuickMenus.Hide()
    end
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

function QuickMenus.Destroy()
    if QuickMenus.current then
        QuickMenus.current:CloseInput()
        QuickMenus.current:CloseConfirm()
    end

    if QuickMenus.UI then
        QuickMenus.UI:Destroy()
        QuickMenus.UI = nil
        QuickMenus.UIReady = false
        QuickMenus.isVisible = false
    end

    QuickMenus.current = nil
    QuickMenus.pendingCalls = {}
end

function onShutdown()
    QuickMenus.Destroy()
end

-- Global reference
_G.QuickMenus = QuickMenus
