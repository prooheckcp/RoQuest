local function assertProperties(properties, class)
    properties = properties or {}

    for index: string, value: any in properties do
        if class[index] == nil then
            error(string.format("Property %s does not exist in class %s", index, class.__type))
        end

        if typeof(value) ~= typeof(class[index]) then
            print(value, class[index], class)
            error(string.format("Property %s is not of type %s in class %s", index, class[index], class.__type))
        end
    end

    return setmetatable(properties, class)
end

return assertProperties