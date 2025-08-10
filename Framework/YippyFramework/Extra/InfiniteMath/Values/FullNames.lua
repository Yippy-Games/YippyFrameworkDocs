local small = require(script.Parent.Suffixes)
-- Predefined names for 0–20
local pre = {
    [1] = "Thousand",
    [2] = "Million",
    [3] = "Billion",
    [4] = "Trillion",
    [5] = "Quadrillion",
    [6] = "Quintillion",
    [7] = "Sextillion",
    [8] = "Septillion",
    [9] = "Octillion",
    [10] = "Nonillion",
    [11] = "Decillion",
    [12] = "Undecillion",
    [13] = "Duodecillion",
    [14] = "Tredecillion",
    [15] = "Quattuordecillion",
    [16] = "Quindecillion",
    [17] = "Sedecillion",
    [18] = "Septendecillion",
    [19] = "Octodecillion",
    [20] = "Novendecillion",
}
-- Latin prefixes for units
local units = {
    [1] = "un", [2] = "duo", [3] = "tres", [4] = "quattuor",
    [5] = "quin", [6] = "ses", [7] = "septen", [8] = "octo", [9] = "novem",
}
-- Latin prefixes for tens
local tens = {
    [2] = "vigint", [3] = "trigint", [4] = "quadragint",
    [5] = "quinquagint", [6] = "sexagint", [7] = "septuagint",
    [8] = "octogint", [9] = "nonagint",
}

local full = {}
for i, code in ipairs(small) do
    local n = i - 1
    if pre[n] then
        full[i] = pre[n]
    else
        local t = math.floor(n / 10)
        local u = n % 10
        local name = (units[u] or "") .. (t > 1 and tens[t] or "") .. "illion"
        -- capitalize first letter
        full[i] = name:gsub("^%l", string.upper)
    end
end

return full
