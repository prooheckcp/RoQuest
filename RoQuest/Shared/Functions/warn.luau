--!strict
local HEADER: string = "[RoQuest]: "

return function(message: string): ()
    warn(HEADER .. message, "\n", debug.traceback())
end