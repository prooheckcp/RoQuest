local RunService = game:GetService("RunService")

local Client = require(script.Client)
local Server = require(script.Server)

if RunService:IsClient() then -- No Server object on the client
    script.Server:Destroy()
    Server = nil
else
    Client = nil
end

return {
    Client = Client,
    Server = Server,
}