-- Notification System - New HELIX API
-- Handles multiple simultaneous notifications with animations

Notification = {}
Notification.__index = Notification
Notification.UI = nil
Notification.UIReady = false
Notification.pendingNotifications = {}
Notification.activeNotifications = {}
Notification.notificationId = 0
Notification.destroyTimer = nil

-- Initialize the notification UI
function Notification.Init()
    if Notification.UI then return end
    
    -- Create the WebUI
    local uiPath = "Client/ui/notification/index.html"
    Notification.UI = WebUI("NotificationUI", uiPath)
    Notification.UIReady = false
  
    -- Mark UI as ready after a delay and process pending notifications
    Timer.SetTimeout(function()
        Notification.UIReady = true
        
        for _, notif in ipairs(Notification.pendingNotifications) do
            if Notification.UI then
                Notification.UI:CallFunction("addNotification", 
                    notif.id, notif.type, notif.title, notif.message, notif.duration)
            end
        end
        Notification.pendingNotifications = {}
    end, 500)  -- Give UI time to load
    
    -- print("[Notification] System initialized")
end

-- Send a notification
function Notification.Send(type, title, message, duration)
    -- Initialize UI if not already done
    if not Notification.UI then
        Notification.Init()
    end
    
    -- Default values
    type = type or "info"
    title = title or "Notification"
    message = message or ""
    duration = duration or 3000  -- Default 3 seconds
    
    -- Generate unique ID
    Notification.notificationId = Notification.notificationId + 1
    local id = "notif_" .. Notification.notificationId
    
    -- Store notification data
    local notifData = {
        id = id,
        type = type,
        title = title,
        message = message,
        duration = duration
    }
    
    -- If UI is ready, send immediately, otherwise queue it
    if Notification.UIReady then
        Timer.SetTimeout(function()
            if Notification.UI then
                Notification.UI:CallFunction("addNotification", id, type, title, message, duration)
            end
        end, 100)
    else
        -- Add to pending queue to be sent when UI is ready
        table.insert(Notification.pendingNotifications, notifData)
    end
    
    Notification.activeNotifications[id] = true
    
    local totalActive = 0
    for k, v in pairs(Notification.activeNotifications) do
        if v then totalActive = totalActive + 1 end
    end
    print("[Notification] Added notification:", id, "Total active:", totalActive)
    
    if Notification.destroyTimer then
        Timer.Clear(Notification.destroyTimer)
        Notification.destroyTimer = nil
        print("[Notification] Cancelled pending UI destruction")
    end
    
    -- Auto-remove after duration
    Timer.SetTimeout(function()
        print("[Notification] Auto-removing notification:", id)
        Notification.Remove(id)
    end, duration + 1000)  -- Add extra time for fade out animation
    
    -- print("[Notification]", type:upper(), "-", title, ":", message)
    return id
end

-- Remove a specific notification
function Notification.Remove(id)
    if not Notification.activeNotifications[id] then
        -- print("[Notification] Trying to remove non-existent notification:", id)
        return
    end
    
    -- print("[Notification] Removing notification:", id)
    
    if Notification.UI then
        Notification.UI:CallFunction("removeNotification", id)
    end
    
    Notification.activeNotifications[id] = nil
    
    local hasActiveNotifications = false
    local count = 0
    for k, v in pairs(Notification.activeNotifications) do
        if v then
            hasActiveNotifications = true
            count = count + 1
        end
    end
    
    -- print("[Notification] Active notifications remaining:", count)
    
    if not hasActiveNotifications then
        if Notification.destroyTimer then
            Timer.Clear(Notification.destroyTimer)
        end
        
        -- print("[Notification] No active notifications, scheduling UI destruction")
        Notification.destroyTimer = Timer.SetTimeout(function()
            -- print("[Notification] Destroying UI")
            if Notification.UI then
                Notification.UI:Destroy()
                Notification.UI = nil
                Notification.UIReady = false
                Notification.activeNotifications = {}
            end
            Notification.destroyTimer = nil
        end, 1000)
    end
end

-- Clear all notifications
function Notification.Clear()
    if Notification.UI then
        Notification.UI:CallFunction("clearAll")
    end
    Notification.activeNotifications = {}
end

-- Destroy the notification system
function Notification.Destroy()
    Notification.Clear()
    
    if Notification.UI then
        Notification.UI:Destroy()
        Notification.UI = nil
    end

    -- print("[Notification] System destroyed")
end

-- Convenience functions for different notification types
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

-- Global reference
_G.Notification = Notification

-- print("[Notification] System loaded - Use Notification.Send(type, title, message) to show notifications")