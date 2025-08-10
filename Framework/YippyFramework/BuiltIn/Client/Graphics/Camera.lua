--[[
    Author: Rask/AfraiEda
    Creation Date: 01/06/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
--= Framework =--
local Camera = {
    BuiltIn = true
}
--= Modules & Config =--
local Input = require(ReplicatedFirst.Framework.Extra.Input)
local Signal = require(ReplicatedFirst.Framework.Extra.Signal)
--= Constants =--

--= Variables =--

function Camera:ConnectViewportSize()
    game.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.ViewportSize = workspace.CurrentCamera.ViewportSize
        self.ViewportChanged:Fire(self.ViewportSize)
    end)
end

function Camera:GetViewportSize()
    return self.ViewportSize
end

function Camera:GetCurrentInput()
    return self.CurrentInput
end

function Camera:ShakeCamera(Duration: number, Intensity: number)
    local camera = workspace.CurrentCamera
    local originalCFrame = camera.CFrame

    -- Store the original CFrame if not already shaking
    if not self.IsShaking then
        self.OriginalCFrame = originalCFrame
        self.IsShaking = true
    end

    local startTime = tick()
    local connection

    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = elapsed / Duration

        if progress >= 1 then
            -- Shake is complete, restore original position
            camera.CFrame = self.OriginalCFrame
            self.IsShaking = false
            self.OriginalCFrame = nil
            connection:Disconnect()
            return
        end

        -- Calculate shake intensity that decreases over time
        local currentIntensity = Intensity * (1 - progress)

        -- Generate random shake offset
        local shakeX = (math.random() - 0.5) * 2 * currentIntensity
        local shakeY = (math.random() - 0.5) * 2 * currentIntensity
        local shakeZ = (math.random() - 0.5) * 2 * currentIntensity

        -- Apply shake to the original camera position
        local shakeOffset = Vector3.new(shakeX, shakeY, shakeZ)
        camera.CFrame = self.OriginalCFrame + shakeOffset
    end)
end

--= Main Methods =--

function Camera:Start()
    self.ViewportChanged = Signal.new()
    self.ViewportSize = workspace.CurrentCamera.ViewportSize
    self:ConnectViewportSize()
    self.CurrentInput = Input.PreferredInput.Current

    -- Initialize shake variables
    self.IsShaking = false
    self.OriginalCFrame = nil

    Input.PreferredInput.Observe(function(preferred)
        self.CurrentInput = preferred
    end)
end

return Camera
