local util = require("lib/util")
local set = {}

function set:new (list)
    list = list or {}

    local set = { items = {} }
    setmetatable(set, self)
    self.__index = self

    for _, entry in ipairs(list) do set.items[entry] = true end
    return set
end

function set:size ()
    local n = 0
    for _ in pairs(self.items) do n = n + 1 end
    return n
end

function set:print ()
    local s = "{\n"
    for item, _ in pairs(self.items) do
        s = s .. "  " .. tostring(item) .. ",\n"
    end
    s = s .. "}"
    print(s)
end

function set:erase (key)
    self.items[key] = nil
end

function set:iter ()
    local items = {}
    for k, _ in pairs(self.items) do table.insert(items, k) end
    return util.list_iter(items)
end

return set
