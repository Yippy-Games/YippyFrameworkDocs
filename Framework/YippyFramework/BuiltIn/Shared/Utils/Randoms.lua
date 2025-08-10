local Randoms = {
    BuiltIn = true
}

function Randoms:RandomDecimals(min, max)
    if type(min) ~= "number" or type(max) ~= "number" then
        return 0
    end
    
    return min + (max - min) * math.random()
end

function Randoms:RandomInteger(min, max)
    if type(min) ~= "number" or type(max) ~= "number" then
        return 0
    end
    
    return math.random(math.floor(min), math.floor(max))
end

function Randoms:RandomFromArray(array)
    if type(array) ~= "table" or #array == 0 then
        return nil
    end
    
    return array[math.random(1, #array)]
end

function Randoms:RandomBool(chance)
    chance = chance or 0.5
    return math.random() < chance
end

function Randoms:RandomVector3(minX, maxX, minY, maxY, minZ, maxZ)
    return Vector3.new(
        self:RandomDecimals(minX or 0, maxX or 1),
        self:RandomDecimals(minY or 0, maxY or 1),
        self:RandomDecimals(minZ or 0, maxZ or 1)
    )
end

function Randoms:RandomColor3()
    return Color3.fromRGB(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

return Randoms
