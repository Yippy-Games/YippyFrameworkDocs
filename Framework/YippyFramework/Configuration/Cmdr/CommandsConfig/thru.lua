return {
    Name = "thru",
    Aliases = { "t", "through" },
    Description = "Teleports you through whatever your mouse is hovering over, placing you equidistantly from the wall.",
    Group = "Debug",
    Args = {
        {
            Type = "number",
            Name = "Extra distance",
            Description = "Go through the wall an additional X studs.",
            Default = 0,
        },
    },
}
