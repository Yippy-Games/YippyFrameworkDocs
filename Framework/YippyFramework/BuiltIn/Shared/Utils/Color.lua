local Color = {
    BuiltIn = true
}

function Color:toHex(color)
    if typeof(color) ~= "Color3" then
        return "#FFFFFF"
    end
    
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)  
    local b = math.floor(color.B * 255)
    
    return string.format("#%02X%02X%02X", r, g, b)
end

function Color:fromHex(hex)
    if type(hex) ~= "string" then
        return Color3.fromRGB(255, 255, 255)
    end
    
    -- Remove # if present
    hex = hex:gsub("#", "")
    
    -- Ensure it's 6 characters
    if #hex ~= 6 then
        return Color3.fromRGB(255, 255, 255)
    end
    
    local r = tonumber("0x" .. hex:sub(1,2)) or 255
    local g = tonumber("0x" .. hex:sub(3,4)) or 255
    local b = tonumber("0x" .. hex:sub(5,6)) or 255
    
    return Color3.fromRGB(r, g, b)
end

function Color:lerp(color1, color2, alpha)
    if typeof(color1) ~= "Color3" or typeof(color2) ~= "Color3" then
        return Color3.fromRGB(255, 255, 255)
    end
    
    return color1:Lerp(color2, alpha)
end

return Color
