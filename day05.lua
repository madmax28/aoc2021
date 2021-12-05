local iter = require "lib/iter"

local Line = {}

function Line:new (x1, y1, x2, y2)
    local o = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Line:isDiagonal ()
    return self.x1 ~= self.x2 and self.y1 ~= self.y2
end

function Line:points ()
    return coroutine.wrap(function ()
        local stepx, stepy
        if self.x1 <= self.x2 then stepx = 1 else stepx = -1 end
        if self.y1 <= self.y2 then stepy = 1 else stepy = -1 end

        if self.x1 == self.x2 then
            for y = self.y1, self.y2, stepy do
                coroutine.yield({self.x1, y})
            end
        elseif self.y1 == self.y2 then
            for x = self.x1, self.x2, stepx do
                coroutine.yield({x, self.y1})
            end
        else
            local cnt = math.abs(self.x1 - self.x2) + 1
            local x, y = self.x1, self.y1
            for _ = 1, cnt do
                coroutine.yield({x, y})
                x, y = x + stepx, y + stepy
            end
        end
    end)
end

local lines = iter:new(io.open("input/day05"):lines()):map(function (line)
    return Line:new(table.unpack(iter:new(line:gmatch("%d+")):map(tonumber):collect()))
end):collect()

local Map = {}

function Map:new ()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.data = {}
    return o
end

function Map:addLine (line)
    for x, y in iter:new(line:points()):map(table.unpack) do
        if not self.data[x] then self.data[x] = {} end

        if self.data[x][y] then
            self.data[x][y] = self.data[x][y] + 1
        else
            self.data[x][y] = 1
        end
    end
end

function Map:countOverlaps ()
    local res = 0
    for _, ys in pairs(self.data) do
        for _, cnt in pairs(ys) do
            if cnt > 1 then res = res + 1 end
        end
    end
    return res
end

local map = Map:new()
for line in iter:new(lines):filter(function(l) return not l:isDiagonal() end) do
    map:addLine(line)
end
print("Part 1:", map:countOverlaps())

map = Map:new()
for line in iter:new(lines) do
    map:addLine(line)
end
print("Part 2:", map:countOverlaps())
