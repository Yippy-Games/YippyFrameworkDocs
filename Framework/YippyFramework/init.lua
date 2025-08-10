local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require(script.FrameworkServer)
else
    local FrameworkServer = script:FindFirstChild("FrameworkServer")
    if FrameworkServer and RunService:IsRunning() then
        FrameworkServer:Destroy()
    end
    return require(script.FrameworkClient)
end
