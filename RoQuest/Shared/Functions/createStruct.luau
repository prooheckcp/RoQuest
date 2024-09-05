local function createStruct(data)
    return setmetatable({}, {
        __call = function(_, properties)
            local dataTable = setmetatable({}, data)
            
            for index: string, value: any in pairs(data) do
                if properties[index] == nil then
                    if typeof(value) == "table" then
                        dataTable[index] = table.clone(value)
                    else
                        dataTable[index] = value
                    end
                    continue
                end
                
                dataTable[index] = properties[index]
            end
    
            return dataTable
        end
    })
end

return createStruct