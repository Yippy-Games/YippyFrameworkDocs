return function(_, players)
    for _, player in pairs(players) do
        if player.Character then
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:TakeDamage(Humanoid.Health)
            end
        end
    end

    return ("Killed %d players."):format(#players)
end
