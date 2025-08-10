return function(_context, player: Player, amount: number)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = amount
        end
    end
    return "Set " .. player.Name .. "'s walkspeed to " .. amount
end
