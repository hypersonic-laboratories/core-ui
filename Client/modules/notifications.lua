-- Notification class definition
Notification = {}

Notification.UI = WebUI("ContextMenu", "file:///ui/context-menu/index.html")
-- Sends a notification to the WebUI
function Notification.Send(title, text, time, position, color)
    -- Calls the WebUI event to show a notification with the specified parameters
    Notification.UI:CallEvent("ShowNotification", {
        title = title,   -- Title of the notification
        message = text,  -- Text content of the notification
        duration = time, -- Duration the notification should stay on screen (in seconds)
        pos = position,  -- Position on the screen ('center', 'top', 'bottom', etc.)
        color = color    -- Border color of the notification (CSS color value)
    })
end

-- Subscribes to a chat event to listen for specific player messages
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Checks if the received message is 'not'
    if message == 'not' then
        -- Sends a notification when the 'not' message is received
        Chat.AddMessage('dodododo')
        Notification.Send('Title', 'Content content content', 5, 'center', "#00f300")
        -- Parameters are title, message, duration, position, and color
    end
end)
