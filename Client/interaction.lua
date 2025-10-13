-- Interaction System - New HELIX API
-- Multiple simultaneous interactions with progress bars

Interaction = {}
Interaction.__index = Interaction
Interaction.instances = {} -- Store multiple interaction instances
Interaction.UI = nil       -- Single UI instance for all interactions

-- Initialize the interaction UI
function Interaction.Init()
    if Interaction.UI then return end

    -- Create the WebUI
    local uiPath = "Client/ui/interaction/index.html"
    Interaction.UI = WebUI("InteractionUI", uiPath, 2)
    Interaction.UIReady = false


    -- Mark UI as ready after a delay
    Timer.SetTimeout(function()
        Interaction.UIReady = true
        -- print("[Interaction] UI is now ready")

        -- Process any pending interactions
        for id, interaction in pairs(Interaction.instances) do
            if interaction.active and not interaction.sent then
                Interaction.UI:CallFunction("addInteraction", id, interaction.text, interaction.key, interaction
                .duration)
                interaction.sent = true
            end
        end

        Interaction.StartInputCheck()
    end, 1500) -- Give UI time to load

    -- print("[Interaction] System initialized")
end

-- Input detection loop
function Interaction.StartInputCheck()
    Timer.CreateThread(function()
        while Interaction.UI do
            local Player = HPlayer

            for id, interaction in pairs(Interaction.instances) do
                if interaction.active then
                    local FKey = UE.FKey()
                    FKey.KeyName = interaction.key

                    if Player:IsInputKeyDown(FKey) then
                        if not interaction.pressing then
                            interaction.pressing = true
                            interaction.startTime = os.clock()
                            Interaction.UI:CallFunction("startProgress", id)
                        else
                            local elapsed = (os.clock() - interaction.startTime) * 1000
                            local progress = math.min((elapsed / interaction.duration) * 100, 100)

                            Interaction.UI:CallFunction("updateProgressFromLua", id, progress)

                            if progress >= 100 and not interaction.completed then
                                interaction.completed = true
                                Interaction.OnComplete(id)
                            end
                        end
                    elseif interaction.pressing then
                        local elapsed = (os.clock() - interaction.startTime) * 1000
                        local progress = (elapsed / interaction.duration) * 100

                        interaction.pressing = false
                        interaction.completed = false

                        if progress < 100 and progress > 10 then
                            Interaction.OnCancel(id)
                        end

                        Interaction.UI:CallFunction("resetProgress", id)
                    end
                end
            end

            Timer.Wait(10)
        end
    end)
end

-- Create a new interaction
function Interaction.Create(id, config)
    -- Initialize UI if not already done
    if not Interaction.UI then
        Interaction.Init()
    end

    -- Default configuration
    config = config or {}
    local interaction = {
        id = id,
        text = config.text or "Interact",
        key = config.key or "E",
        duration = config.duration or 2000,
        onComplete = config.onComplete or function() end,
        onCancel = config.onCancel or function() end,
        active = true,
        pressing = false,
        completed = false,
        startTime = 0,
        sent = false
    }

    -- Store the interaction
    Interaction.instances[id] = interaction

    -- Send to UI if ready, otherwise it will be sent when UI is ready
    if Interaction.UIReady then
        Timer.SetTimeout(function()
            if Interaction.UI and interaction.active and not interaction.sent then
                Interaction.UI:CallFunction("addInteraction", id, interaction.text, interaction.key, interaction
                .duration)
                interaction.sent = true
            end
        end, 100)
    end

    -- print("[Interaction] Created:", id, "-", interaction.text)
    return interaction
end

-- Remove an interaction
function Interaction.Remove(id)
    local interaction = Interaction.instances[id]
    if not interaction then return end

    interaction.active = false

    -- Remove from UI
    if Interaction.UI then
        Interaction.UI:CallFunction("removeInteraction", id)
    end

    -- Remove from instances
    Interaction.instances[id] = nil

    -- print("[Interaction] Removed:", id)
end

-- Handle interaction completion
function Interaction.OnComplete(id)
    local interaction = Interaction.instances[id]
    if not interaction or not interaction.active then return end

    -- print("[Interaction] Completed:", id)

    -- Execute callback
    if interaction.onComplete then
        interaction.onComplete()
    end

    -- Remove the interaction
    Interaction.Remove(id)
end

-- Handle interaction cancellation
function Interaction.OnCancel(id)
    local interaction = Interaction.instances[id]
    if not interaction or not interaction.active then return end

    -- print("[Interaction] Cancelled:", id)

    -- Execute cancel callback
    if interaction.onCancel then
        interaction.onCancel()
    end
end

-- Remove all interactions
function Interaction.Clear()
    for id, _ in pairs(Interaction.instances) do
        Interaction.Remove(id)
    end
end

-- Cleanup on script unload
function Interaction.Destroy()
    Interaction.Clear()

    if Interaction.UI then
        Interaction.UI:Destroy()
        Interaction.UI = nil
    end

    -- print("[Interaction] System destroyed")
end

-- Global reference
_G.Interaction = Interaction
