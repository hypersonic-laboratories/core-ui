Notification = {}
Notification.__index = Notification
Notification.UI = nil
Notification.UIReady = false
Notification.isVisible = false
Notification.activeNotifications = {}
Notification.notificationId = 0

function Notification.Init()
    if Notification.UI then return end

    local uiPath = "core-ui/Client/ui/notification/index.html"
    Notification.UI = WebUI("NotificationUI", uiPath, 1)

    Notification.UI:RegisterEventHandler("Ready", function()
        Notification.UIReady = true
    end)

    Notification.UI:RegisterEventHandler("NotificationClosed", function(id)
        Notification.activeNotifications[id] = nil
        Notification.CheckVisibility()
    end)

    Notification.UI:RegisterEventHandler("AllNotificationsClosed", function()
        Notification.Hide()
    end)
end

function Notification.Show()
    if not Notification.UI or Notification.isVisible then return end

    Notification.UI:SetLayer(3)
    Notification.isVisible = true
end

function Notification.Hide()
    if not Notification.UI or not Notification.isVisible then return end

    Notification.UI:SetLayer(1)
    Notification.isVisible = false
end

function Notification.CheckVisibility()
    local hasActive = false
    for _, active in pairs(Notification.activeNotifications) do
        if active then
            hasActive = true
            break
        end
    end

    if hasActive then
        Notification.Show()
    else
        Notification.Hide()
    end
end

function Notification.Send(type, title, message, duration)
    if not Notification.UI then
        Notification.Init()
    end

    if not Notification.UIReady then
        Timer.SetTimeout(function()
            Notification.Send(type, title, message, duration)
        end, 100)
        return
    end

    type = type or "info"
    title = title or "Notification"
    message = message or ""
    duration = duration or 3000

    Notification.notificationId = Notification.notificationId + 1
    local id = "notif_" .. Notification.notificationId

    Notification.UI:CallFunction("addNotification", id, type, title, message, duration)
    Notification.activeNotifications[id] = true
    Notification.Show()

    Timer.SetTimeout(function()
        Notification.Remove(id)
    end, duration + 500)

    return id
end

function Notification.Remove(id)
    if not Notification.activeNotifications[id] then
        return
    end

    if Notification.UI then
        Notification.UI:CallFunction("removeNotification", id)
    end

    Notification.activeNotifications[id] = nil
    Notification.CheckVisibility()
end

function Notification.Clear()
    if Notification.UI then
        Notification.UI:CallFunction("clearAll")
    end
    Notification.activeNotifications = {}
    Notification.Hide()
end

function Notification.Destroy()
    Notification.Clear()

    if Notification.UI then
        Notification.UI:Destroy()
        Notification.UI = nil
        Notification.UIReady = false
        Notification.isVisible = false
    end
end

function Notification.Success(title, message, duration)
    return Notification.Send("success", title, message, duration)
end

function Notification.Error(title, message, duration)
    return Notification.Send("error", title, message, duration)
end

function Notification.Warning(title, message, duration)
    return Notification.Send("warning", title, message, duration)
end

function Notification.Info(title, message, duration)
    return Notification.Send("info", title, message, duration)
end

_G.Notification = Notification

function onShutdown()
    Notification.Destroy()
end
