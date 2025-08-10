return {
    Name = "setleaderboardvalue",
    Aliases = { "slv" },
    Description = "Sets the value of a leaderboard for a player or set of players.",
    Group = "Admin",
    Args = {
        {
            Type = "players",
            Name = "victims",
            Description = "The players to set the value of the leaderboard for.",
        },
        {
            Type = "string",
            Name = "leaderboard",
            Description = "The leaderboard to set the value of.",
        },
        {
            Type = "number",
            Name = "value",
            Description = "The value to set the leaderboard to.",
        },
    },
}
