local Players = game:GetService("Players")

return {
    Name = "setwalkspeed",
    Description = "Change the walkspeed of a player.",
    Group = "Debug",
    Args = {
        {
            Type = "player",
            Name = "Player",
            Description = "The player to change the walkspeed of.",
            Default = Players.LocalPlayer,
        },
        {
            Type = "number",
            Name = "Walkspeed",
            Description = "The walkspeed to set the player to.",
            Default = 16,
        },
    },
}
