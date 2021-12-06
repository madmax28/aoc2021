local iter = {}

function iter:new (o)
    local it = {}
    setmetatable(it, self)
    self.__index = self
    self.__call = self.next

    local f
    if type(o) == "table" then
        local i = 0
        local n = #o
        f = function ()
            i = i + 1
            if i <= n then return o[i] end
        end
    else
        f = o
    end
    assert(type(f) == "function", "iterator not a function")
    it.it = f

    return it
end

function iter:next ()
    return self.it()
end

function iter:collect ()
    local list = {}
    for item in self do
        table.insert(list, item)
    end
    return list
end

function iter:map (f)
    local old = self.it
    self.it = function ()
        local item = old()
        if item then return f(item) end
    end
    return self
end

function iter:filter (f)
    local old = self.it
    self.it = function ()
        repeat
            local item = old()
            if item and f(item) then return item end
        until not item
    end
    return self
end

function iter:count ()
    local cnt = 0
    for _ in self.it do cnt = cnt + 1 end
    return cnt
end

function iter:sum ()
    local sum = 0
    for num in self.it do sum = sum + num end
    return sum
end

return iter
