--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local FloatAnimation = {}
FloatAnimation.__index = FloatAnimation
FloatAnimation.Tag = "FloatAnimation"

--= Roblox Services =--
local RunService = game:GetService("RunService")

--= Modules & Config =--

--= Constructor =--

function FloatAnimation.new(Model: Model)
    local self = setmetatable({}, FloatAnimation)
    self.Model = Model
    self.OriginalCFrame = Model:GetPivot()
    self.StartTime = tick()

    -- Animation settings
    self.FloatHeight = 0.3 -- How high to float up and down (in studs)
    self.FloatSpeed = 0.4 -- How fast to float (cycles per second)
    self.RotationSpeed = 0.4 -- How fast to rotate (rotations per second)

    -- Start the animation
    self.Connection = RunService.Heartbeat:Connect(function()
        self:UpdateAnimation()
    end)

    return self
end

function FloatAnimation:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end

    -- Reset model to original position
    if self.Model and self.Model.Parent then
        self.Model:PivotTo(self.OriginalCFrame)
    end
end

--= Methods =--

function FloatAnimation:UpdateAnimation()
    if not self.Model or not self.Model.Parent then
        self:Destroy()
        return
    end

    local currentTime = tick()
    local elapsedTime = currentTime - self.StartTime

    -- Calculate floating offset (sine wave for smooth up/down motion)
    local floatOffset = math.sin(elapsedTime * self.FloatSpeed * math.pi * 2) * self.FloatHeight

    -- Calculate rotation (continuous 360-degree rotation)
    local rotationAngle = (elapsedTime * self.RotationSpeed * math.pi * 2) % (math.pi * 2)

    -- Create the new CFrame with float and rotation
    local newCFrame = self.OriginalCFrame
        * CFrame.new(0, floatOffset, 0) -- Float up and down
        * CFrame.Angles(0, rotationAngle, 0) -- Rotate around Y-axis

    -- Apply the transformation
    self.Model:PivotTo(newCFrame)
end

-- Optional: Methods to adjust animation parameters
function FloatAnimation:SetFloatHeight(height: number)
    self.FloatHeight = height
end

function FloatAnimation:SetFloatSpeed(speed: number)
    self.FloatSpeed = speed
end

function FloatAnimation:SetRotationSpeed(speed: number)
    self.RotationSpeed = speed
end

return FloatAnimation
