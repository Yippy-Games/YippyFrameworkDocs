local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Definitions = {}

local NetworkDef = require(ReplicatedFirst.Framework.Extra.YippyNetwork.Def)

export type SignalDatastoreClient = {
    Connect: (nil, Path: string, ChangedValue: any, PathArray: { string }) -> (),
}

export type SignalDatastoreServer = {
    Connect: (nil, Player: Player, Path: string, ChangedValue: any, PathArray: { string }) -> (),
}

export type BuiltInServer = {
    Network: {
        Channel: (self: any, Name: string) -> NetworkDef.Server,
        FireAllExcept: (self: any, Player: Player, EventName: string, ...any) -> (),
        FireList: (self: any, PlayerList: { Player }, EventName: string, ...any) -> (),
        FireWithFilter: (self: any, Filter: (Player) -> boolean, EventName: string, ...any) -> (),
        On: (self: any, EventName: string, Callback: ((Player, ...any) -> ...any)?) -> (),
        Folder: (self: any, Player: Player?) -> Folder,
    },
    Datastore: {
        -- Core Data Operations
        Get: (self: any, Player: Player, Path: string) -> any,
        GetData: (self: any, Player: Player) -> table?,
        Exists: (self: any, Player: Player, Path: string) -> boolean,
        
        -- Modern Listen API
        Listen: (self: any, options: {
            player: Player?,
            path: string?,
            filter: ((event: {
                player: Player,
                path: string,
                pathArray: {string},
                newValue: any,
                oldValue: any,
                changeInfo: any
            }) -> boolean)?
        }, callback: (event: {
            player: Player,
            path: string,
            pathArray: {string},
            newValue: any,
            oldValue: any,
            changeInfo: any
        }) -> ()) -> { disconnect: () -> () },
        
        -- Dynamic Operations (auto-generated from DataTypes)
        -- Boolean operations:
        Set: (self: any, Player: Player, Path: string, Value: any) -> (),
        SetMany: (self: any, Player: Player, Paths: table) -> (),
        Toggle: (self: any, Player: Player, Path: string, Value: any) -> (),
        ToggleMany: (self: any, Player: Player, Paths: table) -> (),
        
        -- Number operations:
        Add: (self: any, Player: Player, Path: string, Value: any) -> (),
        AddMany: (self: any, Player: Player, Paths: table) -> (),
        Subtract: (self: any, Player: Player, Path: string, Value: any) -> (),
        SubtractMany: (self: any, Player: Player, Paths: table) -> (),
        Multiply: (self: any, Player: Player, Path: string, Value: any) -> (),
        MultiplyMany: (self: any, Player: Player, Paths: table) -> (),
        Divide: (self: any, Player: Player, Path: string, Value: any) -> (),
        DivideMany: (self: any, Player: Player, Paths: table) -> (),
        
        -- Table operations:
        Insert: (self: any, Player: Player, Path: string, Value: any) -> (),
        InsertMany: (self: any, Player: Player, Paths: table) -> (),
        Remove: (self: any, Player: Player, Path: string, Value: any) -> (),
        RemoveMany: (self: any, Player: Player, Paths: table) -> (),
        Clear: (self: any, Player: Player, Path: string, Value: any) -> (),
        ClearMany: (self: any, Player: Player, Paths: table) -> (),
        
        -- Internal/Setup functions
        CreateReplicaData: (self: any, Player: Player, PlayerProfile: table) -> table,
        GetTypeHandler: (self: any, value: any) -> any?,
        EncodeDataForStorage: (self: any, data: any) -> any,
        DecodeDataFromStorage: (self: any, data: any) -> any,
        ProcessValues: (self: any, Player: Player, Paths: table, operation: any, operationType: string?) -> (),
        RegisterDynamicOperations: (self: any) -> (),
        PlayerAdded: (self: any, Player: Player) -> boolean?,
        PlayerRemoving: (self: any, Player: Player) -> (),
        GetAvailableOperations: (self: any) -> table,
    },
    GlobalStats: {
        SetInfo: (self: any, Type: string, Value: any) -> (),
        GetInfo: (self: any, Type: string) -> any,
        HasPermission: (self: any, Player: Player) -> boolean,
        PlayerAdded: (self: any, Player: Player) -> (),
        BuiltinCalculation: (self: any) -> (),
    },
    Marketplace: {
        PromptProduct: (self: any, Player: Player, ProductName: string, ...any) -> (),
    },
    Notifications: {
        Create: (self: any, Player: Player, Type: string, Message: string) -> (),
        CreateAll: (self: any, Type: string, Message: string) -> (),
        Clear: (self: any, Player: Player) -> (),
    },
    Chat: {
        SendServerMessage: (self: any, Message: string, Params: { [string]: any }) -> (),
        GiveRank: (self: any, Player: Player, Rank: string) -> (),
        RemoveRank: (self: any, Player: Player, Rank: string) -> (),
    },
    Animations: {
        CharacterAdded: (self: any, Player: Player, Character: Model) -> (),
        ListenAnimateChange: (self: any, Player: Player, Character: Model) -> (),
        GetAnimator: (self: any, entity: Instance) -> Animator?,
        ChangeDefaultAnimation: (self: any, entity: Instance, Type: string, source: any) -> (),
        RevertDefaultAnimation: (self: any, entity: Instance, type: string?) -> (),
        LoadAnimations: (self: any, entity: Instance, source: Instance) -> { [string]: AnimationTrack }?,
        UnloadAnimations: (self: any, entity: Instance) -> (),
        Play: (self: any, entity: Instance, animationName: string, ...any) -> AnimationTrack?,
        Stop: (self: any, entity: Instance, animationName: string) -> (),
        Freeze: (self: any, entity: Instance, animationName: string) -> (),
        Unfreeze: (self: any, entity: Instance, animationName: string) -> (),
        SetSpeed: (self: any, entity: Instance, animationName: string, speed: number) -> (),
        StopAll: (self: any, entity: Instance) -> (),
        StopCurrent: (self: any, entity: Instance) -> (),
        LoadAnimationsFor: (self: any, entity: Instance, source: Instance) -> (),
        PlayFor: (self: any, entity: Instance, animationName: string, ...any) -> AnimationTrack?,
        UnloadAnimationsFor: (self: any, entity: Instance) -> (),
        StopCurrentFor: (self: any, entity: Instance) -> (),
        StopFor: (self: any, entity: Instance, animationName: string) -> (),
    },
    Ragdoll: {
        CharacterAdded: (self: any, player: Player, Character: Model) -> (),
        SetupHumanoid: (self: any, hum: Humanoid) -> (),
        BuildCollisionPart: (self: any, char: Model) -> (),
        EnableCollisionParts: (self: any, Char: Model, enabled: boolean) -> (),
        BuildNPCRagdoll: (self: any, Character: Model) -> (),
        RagdollCharacter: (self: any, Character: Model, Options: table) -> (),
        UnragdollCharacter: (self: any, Character: Model) -> (),
    },
    Chat: {
        PlayerAdded: (self: any, Player: Player) -> (),
        CheckGroupRanks: (self: any, Player: Player) -> (),
        GiveRank: (self: any, Player: Player, Rank: string, RankData: table?) -> (),
        RemoveRank: (self: any, Player: Player, Rank: string) -> (),
        ResortRankOrder: (self: any, Player: Player) -> (),
        GetPlayerRankByType: (self: any, Player: Player, Type: string) -> any?,
        HasPlayerRankOfType: (self: any, Player: Player, Type: string) -> boolean,
        CreateRank: (self: any, RankName: string, RankData: table) -> (),
        UpdatePlayerChatPrefix: (self: any, Player: Player) -> (),
        SendServerMessage: (self: any, Message: string, Params: { [string]: any }) -> (),
    },
    Leaderboard: {
        PlayerRemoving: (self: any, Player: Player) -> (),
        PlayerAdded: (self: any, Player: Player) -> (),
        findInstanceByPath: (self: any, startInstance: Instance, path: string, retryInterval: number?) -> Instance?,
        CreateBoard: (self: any, Config: table) -> (),
        CheckIfRankChanged: (self: any, Player: Player, Board: table) -> (),
        UpdateFrameVisual: (self: any, row: table, Data: table, Rank: number, Config: table) -> (),
        UpdateTopPlayer: (self: any, Model: Model, Data: table) -> (),
        CreateLBVisual: (self: any, Model: Model, Config: table) -> (),
        GetHolderFrame: (self: any, Model: Instance) -> Instance,
        GetFrame: (self: any, i: number) -> Instance,
    },
}

export type BuiltInClient = {
    Network: {
        Channel: (self: any, Name: string) -> NetworkDef.Client,
    },
    Datastore: {
        -- Core Data Operations
        Get: (self: any, Path: string) -> any,
        GetData: (self: any) -> table?,
        Exists: (self: any, Path: string) -> boolean,
        
        -- Modern Listen API
        Listen: (self: any, options: {
            path: string?,
            filter: ((event: {
                path: string,
                pathArray: {string},
                newValue: any,
                oldValue: any?,
                changeInfo: {
                    oldValue: any?,
                    newValue: any,
                    operationType: string,
                    difference: any?,
                    changeType: string,
                }
            }) -> boolean)?
        }, callback: (event: {
            path: string,
            pathArray: {string},
            newValue: any,
            oldValue: any?,
            changeInfo: {
                oldValue: any?,
                newValue: any,
                operationType: string,
                difference: any?,
                changeType: string,
            }
        }) -> ()) -> { disconnect: () -> () },
        
        -- Core Functions
        WaitForDataReceived: (self: any) -> (),
        GetTypeHandler: (self: any, value: any) -> any?,
        DecodeDataFromStorage: (self: any, data: any) -> any,
        HandlePlayerDataCreation: (self: any, replica: any) -> (),
        HandleAtomicDataChange: (self: any, eventData: any) -> (),
        ClearTablePath: (self: any, Path: table, selects: number?) -> table,
        ClientDataChanged: (self: any, Path: table, serverChangeInfo: any?) -> (),
        FireChange: (self: any, signal: RBXScriptSignal, Path: table, DataTableRef: table, serverChangeInfo: any?) -> (),
    },
    GlobalStats: {
        SetInfo: (self: any, Type: string, Value: any) -> (),
        GetInfo: (self: any, Type: string) -> any,
        SetInfoServer: (self: any, Type: string, Value: any) -> (),
        Update: (self: any) -> (),
        CalculatePing: (self: any) -> number,
    },
    UI: {
        findInstanceByPath: (self: any, startInstance: Instance, path: string, retryInterval: number?) -> Instance?,
        EnableUsefullCore: (self: any) -> (),
        GetRootUI: (self: any) -> Instance,
        GetFrameworkUI: (self: any) -> Instance,
        CloseGroupFrame: (self: any, Group: string) -> (),
        GetGroup: (self: any, Group: string) -> string?,
        SetGroup: (self: any, Group: string, Path: string) -> (),
        UnsetGroup: (self: any, Group: string) -> (),
        ProcessNextAnimation: (self: any, Group: string) -> (),
        CloseCurrentFrame: (self: any, Group: string?) -> (),
        GetLastAction: (self: any) -> string?,
        SetLastAction: (self: any, Action: string) -> (),
        GetLastOpenedFrame: (self: any) -> string?,
        Close: (self: any, Path: string, Group: string?, Action: string?) -> (),
        Open: (self: any, Path: string, Group: string?, Action: string?) -> (),
        tweenOutOfScreen: (self: any, Element: Instance) -> (),
        TweenScale: (self: any, Element: Instance, Scale: number, Time: number) -> (),
        TweenTransparencyGroup: (self: any, Element: Instance, Transparency: number, Time: number) -> (),
        CheckUIScale: (self: any, Instances: Instance) -> UIScale,
        CheckUIGradient: (self: any, Instances: Instance) -> UIGradient,
        ScaleTextOffset: (self: any, Text: string, FontFace: Font, MaxLettersPerLine: number, SizeScale: number, Options: table) -> Vector2,
        GetAverage: (self: any, vector: Vector2) -> number,
        ConvertBasedOnScreenSize: (self: any, Value: number) -> number,
        LoadUI: (self: any) -> (),
        ApplyChanges: (self: any, MainUI: Instance) -> (),
        CustomMouseLeave: (self: any, Instances: Instance, Callback: () -> ()) -> (),
        LoadCustomEvents: (self: any) -> (),
    },
    Marketplace: {
        PromptProduct: (self: any, ProductName: string, ...any) -> (),
    },
    Notifications: {
        Create: (self: any, Type: string, Message: string) -> (),
        Clear: (self: any) -> (),
        AlreadyExists: (self: any, Type: string, Message: string) -> boolean,
        UpdateCount: (self: any, Notif: Frame) -> (),
        Remove: (self: any, Notif: Frame) -> (),
        CreateUI: (self: any, Type: string, Message: string) -> (),
    },
    Chat: {
        DisplayServerMessage: (self: any, Message: string, Params: { [string]: any }) -> (),
    },
    Animations: {
        findInstanceByPath: (self: any, startInstance: Instance, path: string, retryInterval: number?) -> Instance?,
        CharacterAdded: (self: any, Player: Player) -> (),
        GetAnimator: (self: any, entity: Instance) -> Animator?,
        LoadAnimations: (self: any, source: Instance) -> { [string]: AnimationTrack }?,
        LoadAnimationsFor: (self: any, entity: Instance, source: Instance) -> { [string]: AnimationTrack }?,
        UnloadAnimations: (self: any) -> (),
        UnloadAnimationsFor: (self: any, entity: Instance) -> (),
        Play: (self: any, animationName: string, ...any) -> AnimationTrack?,
        PlayFor: (self: any, entity: Instance, animationName: string, ...any) -> AnimationTrack?,
        Stop: (self: any, animationName: string) -> (),
        StopFor: (self: any, entity: Instance, animationName: string) -> (),
        Freeze: (self: any, animationName: string) -> (),
        FreezeFor: (self: any, entity: Instance, animationName: string) -> (),
        Unfreeze: (self: any, animationName: string) -> (),
        UnfreezeFor: (self: any, entity: Instance, animationName: string) -> (),
        SetSpeed: (self: any, animationName: string, speed: number) -> (),
        SetSpeedFor: (self: any, entity: Instance, animationName: string, speed: number) -> (),
        StopAll: (self: any) -> (),
        StopCurrent: (self: any) -> (),
        StopCurrentFor: (self: any, entity: Instance) -> (),
    },
    Leaderboard: {
        findInstanceByPath: (self: any, startInstance: Instance, path: string, retryInterval: number?) -> Instance?,
        getCurrentMode: (self: any) -> string?,
        getAvailableModes: (self: any) -> { string },
        switchToMode: (self: any, mode: string) -> (),
        CreateLBVisual: (self: any, Model: Model, Holder: Instance) -> (),
        GetHolderFrame: (self: any, Model: Instance) -> Instance,
    },
    DebugUI: {
        HasPermissions: (self: any) -> boolean,
        RenderDefault: (self: any) -> (),
        Create: (self: any) -> (),
    },
}

export type BuiltInShared = {
    -- Shared Utility Modules
    Tween: {
        InstantTweenModelScale: (self: any, model: Model, info: TweenInfo, opt: { Scale: number }) -> Tween?,
        InstantModelTween: (self: any, model: Model, info: TweenInfo, opt: { CFrame: CFrame?, Position: Vector3? }) -> Tween?,
        InstantTween: (self: any, Part: Instance, info: TweenInfo, opt: { [string]: any }) -> Tween?,
        InstantTweenGradient: (self: any, gradient: UIGradient, info: TweenInfo, opt: table) -> Tween?,
    },
    Component: {
        GetInstanceByTag: (self: any, Instances: Instance, Tag: string) -> any?,
        GetInstanceByTagUntil: (self: any, Instances: Instance, Tag: string) -> any?,
    },
    Date: {
        convertToHMS: (self: any, Seconds: number) -> string,
        convertToDHMS: (self: any, Seconds: number) -> string,
        convertToMS: (self: any, Seconds: number) -> string,
    },
    Color: {
        toHex: (self: any, color: Color3) -> string,
        fromHex: (self: any, hex: string) -> Color3,
        lerp: (self: any, color1: Color3, color2: Color3, alpha: number) -> Color3,
    },
    Randoms: {
        RandomDecimals: (self: any, min: number, max: number) -> number,
        RandomInteger: (self: any, min: number, max: number) -> number,
        RandomFromArray: (self: any, array: { any }) -> any?,
        RandomBool: (self: any, chance: number?) -> boolean,
        RandomVector3: (self: any, minX: number?, maxX: number?, minY: number?, maxY: number?, minZ: number?, maxZ: number?) -> Vector3,
        RandomColor3: (self: any) -> Color3,
    },
    Part: {
        anchor: (self: any, model: Model) -> (),
        unanchor: (self: any, model: Model) -> (),
        SetCanCollide: (self: any, Model: Model, CanCollide: boolean) -> (),
        SetTool: (self: any, Model: Model, bool: boolean) -> (),
        SetTransparency: (self: any, Model: Model, Transparency: number) -> (),
        ResetTransparency: (self: any, Model: Model) -> (),
        getMassModel: (self: any, model: Model) -> number,
        SetCollisionGroup: (self: any, Model: Model, Group: string) -> (),
        HideModel: (self: any, Model: Model) -> (),
        ShowModel: (self: any, Model: Model) -> (),
        TweenTransparencyModel: (self: any, mod: Model, transparency: number, times: number) -> (),
        LocalTranspenracyModel: (self: any, mod: Model, transparency: number) -> (),
        FindRandomPositionInPart: (self: any, Part: Part) -> Vector3?,
        findInstanceByNameInChild: (self: any, parent: Instance, name: string) -> Instance?,
        findInstanceByPath: (self: any, startInstance: Instance, path: string, retryInterval: number?) -> Instance?,
        GetPathByInstance: (self: any, Start: Instance, End: Instance) -> string?,
        Dist: (self: any, part: BasePart, part2: BasePart) -> number,
        SetNetworkModel: (self: any, model: Model, network: string) -> (),
        Exist: (self: any, model: Model) -> boolean,
        UntilExist: (self: any, model: Model) -> boolean,
        weld: (main: BasePart, ...BasePart) -> (),
        makeMotor6D: (self: any, part0: BasePart, part1: BasePart) -> Motor6D,
        getChildrenOfClass: (self: any, container: Instance, class: string) -> { Instance },
        getDescendantsOfClass: (self: any, container: Instance, class: string) -> { Instance },
    },
    Table: {
        FindNestedValue: (self: any, data: table, path: string | { string }) -> { ref: table, key: any, value: any }?,
        getNestedValuePath: (self: any, data: table, path: { string }) -> any?,
        DeepCopy: (self: any, original: table) -> table,
        Merge: (self: any, t1: table, t2: table) -> table,
    },
    Logger: {
        levelList: { DEBUG: number, INFO: number, WARN: number, ERROR: number, FATAL: number },
        Level: number,
        loggers: { [string]: any },
        GetLogger: (self: any, namespace: string) -> {
            Debug: (self: any, ...any) -> (),
            Info: (self: any, ...any) -> (),
            Warn: (self: any, ...any) -> (),
            Error: (self: any, ...any) -> (),
            Fatal: (self: any, ...any) -> (),
        },
    },
    Registry: {
        Registries: { [string]: { Modules: { [string]: any }, Data: { [string]: { Name: string, Index: number } } } },
        CreateRegistry: (self: any, registryName: string, folder: Instance) -> (),
        GetModuleByName: (self: any, registryName: string, moduleName: string) -> any?,
        GetModuleByIndex: (self: any, registryName: string, index: number) -> any?,
        GetDataByName: (self: any, registryName: string, dataName: string) -> { Name: string, Index: number }?,
        GetDataByIndex: (self: any, registryName: string, index: number) -> { Name: string, Index: number }?,
        GetRegistryModuleList: (self: any, registryName: string) -> { [string]: any }?,
        GetRegistryDataList: (self: any, registryName: string) -> { [string]: { Name: string, Index: number } }?,
        GetModuleByParams: (self: any, registryName: string, key: string, value: any) -> any?,
        GetDataByParams: (self: any, registryName: string, key: string, value: any) -> { Name: string, Index: number }?,
    },
    Event: {
        On: (self: any, EventName: string, Callback: (...any) -> ()) -> RBXScriptConnection,
        Once: (self: any, EventName: string, Callback: (...any) -> ()) -> RBXScriptConnection,
        Fire: (self: any, EventName: string, ...any) -> (),
        FireDeferred: (self: any, EventName: string, ...any) -> (),
        Wait: (self: any, EventName: string) -> ...any,
        DisconnectAll: (self: any, EventName: string) -> (),
        Destroy: (self: any, EventName: string) -> (),
        HasSignal: (self: any, EventName: string) -> boolean,
    },
}

export type FrameworkConfig = {
    Settings: {
        -- Core Framework Settings
        FrameworkSettings: {
            Name: string,
            Version: string,
            Studio: string,
            FrameworkWarning: boolean,
            GroupId: number,
            BuiltIn: { { Name: string, Enabled: boolean? } },
            BuiltInLoadOrder: { string },
        },
        
        -- Module-specific Settings
        Animations: {
            AnimationsPlayerPath: string,
        },
        
        UI: {
            DisabledResetButton: boolean,
            EnabledUICore: { Enum.CoreGuiType },
            ScreenSize: Vector2,
        },
        
        Tooltips: {
            TooltipsRegistry: { [string]: any },
        },
        
        Notifications: {
            MaxNotifications: number,
            NotificationDuration: number,
            NotificationsTypes: { [string]: { Image: string, Color: Color3 } },
        },
        
        Chat: {
            ChatRanks: { [string]: { Layer: number, Color: Color3, Prefix: string?, Suffix: string? } },
        },
        
        Leaderboards: {
            LeaderboardsRegistry: { any },
        },
        
        Logger: {
            LoggerLevel: number,
            LoggerLevelList: {
                DEBUG: number,
                INFO: number,
                WARN: number,
                ERROR: number,
                FATAL: number,
            },
        },
        
        Cmdr: {
            CmdrEnabled: boolean,
            CmdrRankRequired: number,
            CmdrKey: Enum.KeyCode,
        },
        
        DebugUI: {
            DebugUIEnabled: boolean,
            DebugUIRankRequired: number,
            DebugUIKey: Enum.KeyCode,
        },
        
        GlobalStats: {
            GlobalStatsEnabled: boolean,
            GlobalStatsInstanceReceiver: Instance,
            GlobalStatsRankRequired: number,
        },
        
        Ragdoll: {
            RagdollOnDeath: boolean,
        },
        
        Marketplace: {
            ProductAreFree: boolean,
        },
        
        Datastore: {
            Key: string,
            Data: { [string]: any },
        },
    },
    
    -- Configuration Modules (not Settings)
    Cmdr: {
        Types: Instance,
        CommandsConfig: Instance,
        CommandsFunctions: Instance,
        Hooks: Instance,
    },
}

return Definitions
