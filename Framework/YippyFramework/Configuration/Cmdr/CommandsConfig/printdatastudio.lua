local Players = game:GetService("Players")

return {
    Name = "printdatastudio",
    Description = "Print in the console the data of the player.",
    Group = "Debug",
    Args = {
        {
            Type = "player",
            Name = "Player",
            Description = "The player to print the data of.",
            Default = Players.LocalPlayer,
        },
        {
            Type = "string",
            Name = "Key",
            Description = "The key to print the data of.",
            Default = "",
        },
    },
}
