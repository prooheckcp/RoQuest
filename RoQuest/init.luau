local RunService = game:GetService("RunService")

local Client = require(script.Client)
local Server = require(script.Server)

if RunService:IsClient() then -- No Server object on the client
    script.Server:Destroy()
    Server = nil
else
    Client = nil
end

return setmetatable({
    Client = Client,
    Server = Server,
}, {
    __index = function(_, key)
        if key == "Server" then
            error("Cannot access RoQuest.Server on the client! Make sure to require(RoQuest).Client instead!")
        elseif key == "Client" then
            error("Cannot access RoQuest.Client on the server! Make sure to require(RoQuest).Server instead!")
        else
            error("RoQuest has no member named '" .. tostring(key) .. "'")
        end
    end
})