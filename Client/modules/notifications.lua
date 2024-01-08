-- Notification class definition
Notification = {}

Notification.UI = WebUI("ContextMenu", "file:///ui/context-menu/index.html")
-- Sends a notification to the WebUI
function Notification.Send(type, title, text)
    -- Calls the WebUI event to show a notification with the specified parameters
    Notification.UI:CallEvent("ShowNotification", {
        type = type,   -- Title of the notification
        title = title,  -- Text content of the notification
        message = text, -- Duration the notification should stay on screen (in seconds)
    })
end

-- Subscribes to a chat event to listen for specific player messages
Chat.Subscribe("PlayerSubmit", function(message, player)
    -- Checks if the received message is 'not'
    if message == 'not' then
        -- Sends a notification when the 'not' message is received
        Chat.AddMessage('dodododo')
        Notification.Send('success', 'Title', 'tessssxt')
        -- Parameters are title, message, duration, position, and color
    end
end)
