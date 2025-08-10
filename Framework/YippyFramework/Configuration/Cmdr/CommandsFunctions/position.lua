return function(_, player)
    local character = player.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return ""
    end

    return tostring(character.HumanoidRootPart.Position):gsub("%s", "")
end
