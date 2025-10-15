-- Interaction System - New HELIX API
-- Multiple simultaneous interactions with progress bars

Interaction = {}
Interaction.__index = Interaction
Interaction.instances = {}
Interaction.UI = nil
Interaction.inputDispatcher = nil
Interaction.UIReady = false
Interaction.isVisible = false

function Interaction.Init()
    if Interaction.UI then return end

    local uiPath = "core-ui/Client/ui/interaction/index.html"
    Interaction.UI = WebUI("InteractionUI", uiPath, 1)

    Interaction.UI:RegisterEventHandler("Ready", function()
        Interaction.UIReady = true

        for id, interaction in pairs(Interaction.instances) do
            if interaction.active and not interaction.sent then
                Interaction.UI:CallFunction("addInteraction", id, interaction.text, interaction.key, interaction.duration)
                interaction.sent = true
            end
        end
    end)

    Interaction.UI:RegisterEventHandler("AllInteractionsClosed", function()
        Interaction.Hide()
    end)

    Interaction.InitializeInputDispatcher()
end

function Interaction.Show()
    if not Interaction.UI or Interaction.isVisible then return end
    Interaction.UI:SetLayer(3)
    Interaction.isVisible = true
end

function Interaction.Hide()
    if not Interaction.UI or not Interaction.isVisible then return end
    Interaction.UI:SetLayer(1)
    Interaction.isVisible = false
end

function Interaction.CheckVisibility()
    local hasActive = false
    for _, interaction in pairs(Interaction.instances) do
        if interaction.active then
            hasActive = true
            break
        end
    end

    if hasActive then
        Interaction.Show()
    else
        Interaction.Hide()
    end
end

function Interaction.InitializeInputDispatcher()
    local inputDispatchActorClass = UE.UClass.Load('/HelixCommonUI/VAULT/Blueprints/BP_InputDispatchActor.BP_InputDispatchActor_C')

    if inputDispatchActorClass then
        Interaction.inputDispatcher = UE.UGameplayStatics.GetActorOfClass(HWorld, inputDispatchActorClass)
    end

    if Interaction.inputDispatcher and Interaction.inputDispatcher.OnKeyPressed then
        Interaction.inputDispatcher.OnKeyPressed:Add(Interaction.inputDispatcher, function(_, key)
            if not key then return end
            Interaction.OnKeyPressed(key)
        end)
    end

    if Interaction.inputDispatcher and Interaction.inputDispatcher.OnKeyReleased then
        Interaction.inputDispatcher.OnKeyReleased:Add(Interaction.inputDispatcher, function(_, key)
            if not key then return end
            Interaction.OnKeyReleased(key)
        end)
    end
end

function Interaction.OnKeyPressed(key)
    for id, interaction in pairs(Interaction.instances) do
        if interaction.active and key.KeyName == interaction.key then
            if not interaction.pressing then
                interaction.pressing = true
                interaction.startTime = os.clock()
                Interaction.UI:CallFunction("startProgress", id)
                Interaction.StartProgressTracking(id)
            end
        end
    end
end

function Interaction.OnKeyReleased(key)
    for id, interaction in pairs(Interaction.instances) do
        if interaction.active and key.KeyName == interaction.key and interaction.pressing then
            local elapsed = (os.clock() - interaction.startTime) * 1000
            local progress = (elapsed / interaction.duration) * 100

            interaction.pressing = false
            interaction.completed = false

            if progress >= 100 then
                Interaction.OnComplete(id)
            elseif progress > 10 then
                Interaction.OnCancel(id)
            end

            Interaction.UI:CallFunction("resetProgress", id)
        end
    end
end

function Interaction.StartProgressTracking(id)
    Timer.CreateThread(function()
        local interaction = Interaction.instances[id]
        if not interaction then return end

        while interaction.pressing and interaction.active do
            local elapsed = (os.clock() - interaction.startTime) * 1000
            local progress = math.min((elapsed / interaction.duration) * 100, 100)

            Interaction.UI:CallFunction("updateProgressFromLua", id, progress)

            if progress >= 100 and not interaction.completed then
                interaction.completed = true
                interaction.pressing = false
                Interaction.OnComplete(id)
                break
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
        if Interaction.UI and interaction.active and not interaction.sent then
            Interaction.UI:CallFunction("addInteraction", id, interaction.text, interaction.key, interaction
                .duration)
            interaction.sent = true
        end
    end

    Interaction.Show()

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

    -- Check if we should hide
    Interaction.CheckVisibility()

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
        Interaction.UIReady = false
        Interaction.isVisible = false
    end

    -- print("[Interaction] System destroyed")
end

-- Global reference
_G.Interaction = Interaction

function onShutdown()
    Interaction.Destroy()
end
