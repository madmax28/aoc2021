local set = {}

function set:new (list)
    list = list or {}

    local set = {}
    setmetatable(set, self)
    self.__index = self

    for _, entry in pairs(list) do set[entry] = true end
    return set
end

return set
