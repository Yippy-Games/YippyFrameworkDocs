--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local LeaderboardLib = require(ReplicatedFirst.Framework.Extra.Leaderboard)
--= Framework =--
local Leaderboard = {
    BuiltIn = true
}
--= Core =--

function Leaderboard:Start(Linker: table)
    self.Linker = Linker
    self.ActiveBoards = {}

    for _, cfg in pairs(Framework.FrameworkConfig.Settings.Leaderboards.LeaderboardsRegistry or {}) do
        self:CreateBoard(cfg)
    end

    Framework.BuiltInShared.Event:On("LeaderboardRankChanged", function(Player: Player, BoardName: string)
        for _, board in pairs(self.ActiveBoards) do
            if board.Config.Name == BoardName then
                self:UpdatePlayerChatTag(Player, board)
            end
        end
    end)
end

function Leaderboard:PlayerRemoving(Player: Player)
    for _, board in pairs(self.ActiveBoards) do
        board.PreviousRanks[Player.UserId] = nil
        board.InitializedPlayers[Player.UserId] = nil
    end
end

function Leaderboard:PlayerAdded(Player: Player)
    for _, board in pairs(self.ActiveBoards) do
        if not board.InitializedPlayers[Player.UserId] then
            board.InitializedPlayers[Player.UserId] = true
            board.PreviousRanks[Player.UserId] = self:GetPlayerRank(Player, board.Config.Name)
        end
        
        if board.Config.ChatTag then
            self:UpdatePlayerChatTag(Player, board)
        end
    end
end

--= Methods =--

function Leaderboard:findInstanceByPath(startInstance, path, retryInterval)
    if startInstance == nil or path == nil then
        error("[findInstanceByPath] startInstance and path are required")
    end

    local segments = string.split(path, "/")
    local maxRetries = 3
    retryInterval = retryInterval or 1

    local function getChild(parent, key)
        if typeof(parent) == "Instance" then
            return parent:FindFirstChild(key)
        elseif typeof(parent) == "table" then
            return parent[key]
        end
    end

    for _ = 1, maxRetries do
        local current = startInstance

        for _, part in ipairs(segments) do
            if part == ".." then
                current = typeof(current) == "Instance" and current.Parent or nil
            elseif part ~= "." then
                current = getChild(current, part)
            end

            if current == nil then
                task.wait(retryInterval)
                break
            end
        end

        if current ~= nil then
            return current
        end
    end

    return nil
end

function Leaderboard:CreateBoard(Config: table)
    local board = LeaderboardLib.new(Leaderboard:MergeKey(Config), Config.Params)
    local Model = Config.ModelPath and Leaderboard:findInstanceByPath(game, Config.ModelPath)
    local Templates = ReplicatedFirst.FrameworkAssets.UI.Leaderboards

    if self.Linker and self.Linker.CreateLBVisual then
        self.Linker:CreateLBVisual(Model, Config)
    else
        Model.Leaderboard.Leaderboard.Frame.Top.Title.Text = Config.Title
    end

    local LbData = {}
    for _, lb in pairs(Config.LB) do
        LbData[lb] = {}
        LbData[lb].Frames = self:PrecreateFrames(Model, Templates, Config.Params.RecordCount, lb)
    end

    self.ActiveBoards[Config.Name] = {
        Config = Config,
        Model = Model,
        Board = board,
        LbData = LbData,
        PreviousRanks = {},
        InitializedPlayers = {},
    }

    -- Framework.BuiltInServer.Datastore
    --     :ListenToGlobalPathChanged(Config.DataPath)
    --     :Connect(function(player, _, _, _, changeInfo)
    --         if not changeInfo then
    --             return
    --         end

    --         if Config.DataChangeHandler then
    --             Config.DataChangeHandler(player, board, changeInfo)
    --         else
    --             if changeInfo.changeType == "increment" then
    --                 board:IncrementValues(Config.LB, player.UserId, math.floor(changeInfo.difference))
    --             end
    --         end
    --     end)

    for _, Player in pairs(Players:GetPlayers()) do
        if not self.ActiveBoards[Config.Name].InitializedPlayers[Player.UserId] then
            self.ActiveBoards[Config.Name].InitializedPlayers[Player.UserId] = true
            self.ActiveBoards[Config.Name].PreviousRanks[Player.UserId] = self:GetPlayerRank(Player, Config.Name)
        end
    end

    board.Updated:Connect(function(boards)
        for _, boarddata in boards do
            self.ActiveBoards[Config.Name].Data = boarddata
            for _, Player in pairs(Players:GetPlayers()) do
                self:CheckIfRankChanged(Player, self.ActiveBoards[Config.Name])
            end
            self:Render(boarddata, self.ActiveBoards[Config.Name], boarddata.Type)
        end
    end)
end

function Leaderboard:CheckIfRankChanged(Player: Player, Board: table)
    local CurrentRank = self:GetPlayerRank(Player, Board.Config.Name)
    local PreviousRank = Board.PreviousRanks[Player.UserId]
    
    if CurrentRank ~= PreviousRank then
        Framework.BuiltInShared.Event:Fire("LeaderboardRankChanged", Player, Board.Config.Name, CurrentRank, PreviousRank)
    end
    
    Board.PreviousRanks[Player.UserId] = CurrentRank
end

function Leaderboard:Render(board: table, boardConfig: table, boardType: string)
    if #boardConfig.LbData[boardType].Frames == 0 then
        return
    end

    for i = 1, boardConfig.Config.Params.RecordCount do
        local row = boardConfig.LbData[boardType].Frames[i]
        local Data = board.Data[i]
        if Data then
            row:SetAttribute("Active", true)
            row:SetAttribute("UserId", Data.UserId)

            if i == 1 and self.Linker and self.Linker.UpdateTopPlayer then
                self.Linker:UpdateTopPlayer(boardConfig.Model, Data)
            end

            if self.Linker and self.Linker.UpdateFrameVisual then
                self.Linker:UpdateFrameVisual(row, Data, i, boardConfig.Config)
            else
                row.Rank.Title.Text = i
                if typeof(Data.Value) == "number" then
                    local formattedValue = formatter:Format(Data.Value)
                    row.Value.Title.Text = formattedValue
                else
                    row.Value.Title.Text = Data.Value
                end
                row.PlayerIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Data.UserId .. "&w=150&h=150"
                row.PlayerInfo.Title.Text = "@" .. Data.Username
            end
        else
            row:SetAttribute("Active", false)
            row:SetAttribute("UserId", nil)
        end
    end
end

function Leaderboard:PrecreateFrames(Model: Instance, Templates: Instance, RecordCount: number, LbName: string)
    if not (Model and Templates) then
        return
    end
    local holder = nil
    if self.Linker and self.Linker.GetHolderFrame then
        holder = self.Linker:GetHolderFrame(Model)
    else
        holder = Model.Leaderboard.Frame.Players
    end

    if not holder then
        return
    end
    local Frames = {}

    for i = 1, RecordCount do
        local FrameBase = nil
        if self.Linker and self.Linker.GetFrame then
            FrameBase = self.Linker:GetFrame(i)
        else
            FrameBase = (i == 1 and Templates.first)
                or (i == 2 and Templates.second)
                or (i == 3 and Templates.third)
                or Templates.all
        end

        local f = FrameBase:Clone()
        if i == 1 then
            f:SetAttribute("Top", true)
        end
        f:SetAttribute("Category", LbName)
        f:SetAttribute("Active", false)
        f.Visible = false
        f.LayoutOrder = i
        f.Name = "Item-" .. i
        f.Parent = holder
        Frames[i] = f
    end

    return Frames
end

function Leaderboard:MergeKey(Config: table)
    local Key = Config.Key
    local LB = Config.LB

    local LbKeys = {}
    for indx, lb in pairs(LB) do
        LbKeys[indx] = `{lb}-{Key}`
    end

    return LbKeys
end

function Leaderboard:GetPlayerRank(Player: Player, BoardName: string)
    for Name, board in pairs(self.ActiveBoards) do
        if not Name == BoardName then
            continue
        end

        for _, lb in pairs(board.Data.Data) do
            if lb.UserId == tostring(Player.UserId) then
                return lb.Rank
            end
        end
    end
end

function Leaderboard:GetPlayerRankColor(Rank: number)
    if Rank == 1 then
        return Color3.fromRGB(255, 204, 0)
    elseif Rank == 2 then
        return Color3.fromRGB(169, 222, 254)
    elseif Rank == 3 then
        return Color3.fromRGB(205, 123, 0)
    elseif Rank <= 10 then
        return Color3.fromRGB(216, 89, 255)
    elseif Rank <= 25 then
        return Color3.fromRGB(144, 238, 144)
    elseif Rank <= 50 then
        return Color3.fromRGB(86, 213, 255)
    elseif Rank <= 100 then
        return Color3.fromRGB(233, 117, 117)
    else
        return Color3.fromRGB(255, 255, 255)
    end
end

function Leaderboard:UpdatePlayerChatTag(Player: Player, board: table)
    if not board.Data then
        return
    end

    local LeaderboardTagType = "Leaderboard-" .. board.Config.Name
    local ExistingRankData, ExistingRankObject = Framework.BuiltInServer.Chat:GetPlayerRankByType(Player, LeaderboardTagType)
    local CurrentRank = self:GetPlayerRank(Player, board.Config.Name)
    
    if board.Config.ChatTag then
        if CurrentRank then
            local TagName = board.Config.ChatTag.Prefix .. CurrentRank .. board.Config.ChatTag.Suffix

            if ExistingRankData and ExistingRankData.Name ~= TagName then
                Framework.BuiltInServer.Chat:RemoveRank(Player, ExistingRankObject.Rank)
            end
            
            if not ExistingRankData or ExistingRankData.Name ~= TagName then
                local color = self:GetPlayerRankColor(CurrentRank)
                Framework.BuiltInServer.Chat:GiveRank(Player, TagName, {
                    Name = board.Config.ChatTag.Prefix .. CurrentRank .. board.Config.ChatTag.Suffix,
                    Layer = board.Config.ChatTag.Layer or 20,
                    Color = color,
                    Type = LeaderboardTagType
                })
            end
        else
            if ExistingRankData then
                Framework.BuiltInServer.Chat:RemoveRank(Player, ExistingRankObject.Rank)
            end
        end
    end
end

return Leaderboard
