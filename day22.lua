local iter = require "lib.iter"

local Range1d = {}

function Range1d:new(n1, n2)
    local r = { n1 = n1, n2 = n2 }
    setmetatable(r, self)
    self.__index = self
    return r
end

function Range1d:contains(n)
    return n >= self.n1 and n <= self.n2
end

function Range1d:overlaps(other)
    return other.n1 <= self.n2 and other.n2 >= self.n1
end

function Range1d:mergable(other)
    return other.n1 <= self.n2 + 1 and other.n2 >= self.n1 - 1
end

function Range1d:combine(other)
    local ns = { self.n1, self.n2, other.n1, other.n2 }
    table.sort(ns)

    local ranges = {}
    if ns[2] > ns[1] then
        table.insert(ranges, Range1d:new(ns[1], ns[2] - 1))
    end
    table.insert(ranges, Range1d:new(ns[2], ns[3]))
    if ns[4] > ns[3] then
        table.insert(ranges, Range1d:new(ns[3] + 1, ns[4]))
    end
    return ranges
end

function Range1d:equals(other)
    return self.n1 == other.n1 and self.n2 == other.n2
end

local Range3d = {}

function Range3d:new(onoff, coords)
    local r = {
        onoff = onoff,
        x = Range1d:new(coords[1], coords[2]),
        y = Range1d:new(coords[3], coords[4]),
        z = Range1d:new(coords[5], coords[6]),
    }
    setmetatable(r, self)
    self.__index = self
    return r
end

function Range3d:contains(x, y, z)
    return self.x:contains(x) and self.y:contains(y) and self.z:contains(z)
end

function Range3d:overlaps(other)
    return self.x:overlaps(other.x) and self.y:overlaps(other.y) and self.z:overlaps(other.z)
end

function Range3d:count()
    local cnt = 1 + self.x.n2 - self.x.n1
    cnt = cnt * (1 + self.y.n2 - self.y.n1)
    cnt = cnt * (1 + self.z.n2 - self.z.n1)
    return cnt
end

function Range3d:remove(other)
    local ranges = {}
    for _, x in ipairs(self.x:combine(other.x)) do
        for _, y in ipairs(self.y:combine(other.y)) do
            for _, z in ipairs(self.z:combine(other.z)) do
                if self:contains(x.n1, y.n1, z.n1) and not other:contains(x.n1, y.n1, z.n1) then
                    table.insert(ranges, Range3d:new("on", { x.n1, x.n2, y.n1, y.n2, z.n1, z.n2 }))
                end
            end
        end
    end
    return ranges
end

function Range3d:merge(other)
    if self.x:equals(other.x) and self.y:equals(other.y) then
        if self.z:mergable(other.z) then
            return Range3d:new("on", {
                self.x.n1, self.x.n2,
                self.y.n1, self.y.n2,
                math.min(self.z.n1, other.z.n1), math.max(self.z.n2, other.z.n2),
            })
        end
    elseif self.x:equals(other.x) and self.z:equals(other.z) then
        if self.y:mergable(other.y) then
            return Range3d:new("on", {
                self.x.n1, self.x.n2,
                math.min(self.y.n1, other.y.n1), math.max(self.y.n2, other.y.n2),
                self.z.n1, self.z.n2,
            })
        end
    elseif self.y:equals(other.y) and self.z:equals(other.z) then
        if self.x:mergable(other.x) then
            return Range3d:new("on", {
                math.min(self.x.n1, other.x.n1), math.max(self.x.n2, other.x.n2),
                self.y.n1, self.y.n2,
                self.z.n1, self.z.n2,
            })
        end
    end
end

local function merge_ranges(ranges)
    local i = 1
    while i <= #ranges do
        for j = i + 1, #ranges do
            local res = ranges[i]:merge(ranges[j])
            if res then
                table.remove(ranges, j)
                table.remove(ranges, i)
                table.insert(ranges, res)

                goto continue
            end
        end

        i = i + 1
        ::continue::
    end
end

local rangemap = { ranges = {} }

function rangemap:add(range)
    if range.onoff == "on" then
        local new = { range }
        for i = 1, #self.ranges do
            for j = #new, 1, -1 do
                if self.ranges[i]:overlaps(new[j]) then
                    local r = table.remove(new, j)
                    for _, rr in ipairs(r:remove(self.ranges[i])) do
                        table.insert(new, rr)
                    end
                end
            end
        end

        merge_ranges(new)

        for _, r in ipairs(new) do
            table.insert(self.ranges, r)
        end
    else
        local newranges = {}
        for _, r in ipairs(self.ranges) do
            if r:overlaps(range) then
                local rem = r:remove(range)
                merge_ranges(rem)
                for _, rr in ipairs(rem) do
                    table.insert(newranges, rr)
                end
            else
                table.insert(newranges, r)
            end
        end
        self.ranges = newranges
    end
end

function rangemap:count()
    local cnt = 0
    for _, r in ipairs(self.ranges) do
        cnt = cnt + r:count()
    end
    return cnt
end

local seq = {}
for line in io.input("input/day22"):lines() do
    local onoff = line:match("^%a+")
    local coords = iter:new(line:gmatch("-?%d+")):map(tonumber):collect()
    table.insert(seq, {
        onoff = onoff,
        coords = coords,
    })
end

for _, ins in ipairs(seq) do
    local coords = {
        math.max(-50, ins.coords[1]), math.min(50, ins.coords[2]),
        math.max(-50, ins.coords[3]), math.min(50, ins.coords[4]),
        math.max(-50, ins.coords[5]), math.min(50, ins.coords[6]),
    }
    if coords[1] <= coords[2] and coords[3] <= coords[4] and coords[5] <= coords[6] then
        local range = Range3d:new(ins.onoff, coords)
        rangemap:add(range)
    end
end
print("Part 1:", string.format("%d", rangemap:count()))

rangemap.ranges = {}
for _, ins in ipairs(seq) do
    local range = Range3d:new(ins.onoff, ins.coords)
    rangemap:add(range)
end
print("Part 2:", string.format("%d", rangemap:count()))
