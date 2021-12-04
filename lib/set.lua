local set = {}

function set:new (list)
    list = list or {}

    local set = { items = {} }
    setmetatable(set, self)
    self.__index = self

    for _, entry in ipairs(list) do set.items[entry] = true end
    return set
end

return set
