return function(_context, player: Player, amount: number)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = amount
        end
    end
    return "Set " .. player.Name .. "'s jump power to " .. amount
end
