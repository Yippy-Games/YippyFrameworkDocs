local Date = {
    BuiltIn = true
}

function Date:convertToHMS(Seconds: number): string
    local function Format(Int)
        return string.format("%02i", Int)
    end

    local Minutes = (Seconds - Seconds % 60) / 60
    Seconds = Seconds - Minutes * 60
    local Hours = (Minutes - Minutes % 60) / 60
    Minutes = Minutes - Hours * 60
    return Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

function Date:convertToDHMS(Seconds: number): string
    local function Format(Int)
        return string.format("%02i", Int)
    end

    local Minutes = (Seconds - Seconds % 60) / 60
    Seconds = Seconds - Minutes * 60
    local Hours = (Minutes - Minutes % 60) / 60
    Minutes = Minutes - Hours * 60
    local Days = (Hours - Hours % 24) / 24
    Hours = Hours - Days * 24
    return Format(Days) .. ":" .. Format(Hours) .. ":" .. Format(Minutes) .. ":" .. Format(Seconds)
end

function Date:convertToMS(Seconds: number): string
    local function Format(Int)
        return string.format("%02i", Int)
    end

    local Minutes = (Seconds - Seconds % 60) / 60
    Seconds = Seconds - Minutes * 60
    return Format(Minutes) .. ":" .. Format(Seconds)
end

return Date
