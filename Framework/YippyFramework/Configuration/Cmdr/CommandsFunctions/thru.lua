return function(context, extra)
    local mouse = context.Executor:GetMouse()
    local character = context.Executor.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return "You don't have a character."
    end

    local pos = character.HumanoidRootPart.Position
    local diff = (mouse.Hit.p - pos)

    character:MoveTo((diff * 2) + (diff.unit * extra) + pos)

    return "Blinked!"
end
