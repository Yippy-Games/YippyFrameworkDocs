local Table = {
    BuiltIn = true
}

function Table:FindNestedValue(data, path)
    if type(data) ~= "table" then
        return nil
    end
    
    local segments = type(path) == "string" and string.split(path, "/") or path
    local current = data
    local parent = nil
    local key = nil
    
    for i, segment in ipairs(segments) do
        if current == nil then
            return nil
        end
        
        if i == #segments then
            -- Last segment - return reference info
            return {
                ref = current,
                key = segment,
                value = current[segment]
            }
        else
            -- Navigate deeper
            parent = current
            key = segment
            current = current[segment]
        end
    end
    
    return nil
end

function Table:getNestedValuePath(data, path)
    local result = self:FindNestedValue(data, path)
    return result and result.value or nil
end

function Table:DeepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[self:DeepCopy(key)] = self:DeepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

function Table:Merge(t1, t2)
    local result = self:DeepCopy(t1)
    for key, value in pairs(t2) do
        result[key] = value
    end
    return result
end

return Table
