local Players = game:GetService("Players")

return {
    Name = "setjumpower",
    Description = "Change the jump power of a player.",
    Group = "Debug",
    Args = {
        {
            Type = "player",
            Name = "Player",
            Description = "The player to change the jump power of.",
            Default = Players.LocalPlayer,
        },
        {
            Type = "number",
            Name = " Jumppower",
            Description = "The Jumppower to set the player to.",
            Default = 50,
        },
    },
}
