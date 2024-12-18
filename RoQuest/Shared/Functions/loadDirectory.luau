local WarningMessages = require(script.Parent.Parent.Data.WarningMessages)
local Quest = require(script.Parent.Parent.Classes.Quest)
local QuestLifeCycle = require(script.Parent.Parent.Classes.QuestLifeCycle)

type Quest = Quest.Quest
type QuestLifeCycle = QuestLifeCycle.QuestLifeCycle

local LOAD_DIRECTORY_TYPES: {[string]: true} = {
	["Quest"] = true,
	["QuestLifeCycle"] = true,
}

--[[
    Loads all the quests and lifecycles from the directory and returns them in an array

	@private
	@server
	@param instancesToFilter {Instance}

	@return {Quest | QuestLifeCycle}
]]
local function loadDirectory(instancesToFilter: {Instance}): {Quest | QuestLifeCycle}
	local array: {Quest | QuestLifeCycle} = {}

	for _, childInstance: Instance in instancesToFilter do
		if not childInstance:IsA("ModuleScript") then
			continue
		end

		local requiredObject: any = require(childInstance)

		if LOAD_DIRECTORY_TYPES[requiredObject.__type] then
			if #array > 0 and array[1].__type ~= requiredObject.__type then
				error(WarningMessages.LoadDirectoryMixedType)
			end

			array[#array+1] = requiredObject
		end
	end

	return array
end

return loadDirectory