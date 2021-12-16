local priority_queue = {}

function priority_queue:new (list, cmp)
    list = list or {}
    cmp = cmp or function (a, b) return a < b end

    local obj = { items = list, cmp = cmp }
    setmetatable(obj, self)
    self.__index = self

    for idx = math.floor(#obj.items / 2), 1, -1 do
        obj:_bubble_down(idx)
    end

    return obj
end

function priority_queue:_bubble_up (idx)
    while idx ~= 1 do
        local pidx = math.floor(idx / 2)
        local item, parent = self.items[idx], self.items[pidx]
        if not self.cmp(item, parent) then break end
        self.items[pidx] = item
        self.items[idx] = parent
        idx = pidx
    end
end

function priority_queue:insert (item)
    table.insert(self.items, item)
    self:_bubble_up(#self.items)
end

function priority_queue:_bubble_down (idx)
    local limit = math.floor(#self.items / 2)
    while idx <= limit do
        local cidx, child = 2 * idx, self.items[2 * idx]
        if self.items[cidx + 1] and self.cmp(self.items[cidx + 1], child) then
            cidx, child = cidx + 1, self.items[cidx + 1]
        end

        if self.cmp(child, self.items[idx]) then
            self.items[cidx] = self.items[idx]
            self.items[idx] = child
        else
            break
        end

        idx = cidx
    end
end

function priority_queue:pop ()
    local item = self.items[1]
    self.items[1] = self.items[#self.items]
    table.remove(self.items, #self.items)
    self:_bubble_down(1)
    return item
end

return priority_queue
