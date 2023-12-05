Player.Subscribe("Ready", function(self)
    local new_char = Character(Vector(0, 0, 0), Rotator(0, 0, 0), "helix::SK_Male")
    new_char:AddSkeletalMeshAttached("head", "helix::SK_Male_Head")

    self:Possess(new_char)
end)

Package.Subscribe("Load", function()
    local allPlayers = Player.GetAll()

    for k, player in pairs(allPlayers) do
        local new_char = Character(Vector(0, 0, 0), Rotator(0, 0, 0), "helix::SK_Male")
        new_char:AddSkeletalMeshAttached("head", "helix::SK_Male_Head")

        player:Possess(new_char)
    end
end)
