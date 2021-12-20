local iter = require "lib/iter"

local Map = {}

local function neighbors(x, y)
    return {
        { x - 1, y - 1 },
        { x - 1, y },
        { x - 1, y + 1 },
        { x, y - 1 },
        { x, y },
        { x, y + 1 },
        { x + 1, y - 1 },
        { x + 1, y },
        { x + 1, y + 1 },
    }
end

function Map:new(enhancement)
    local m = { default = ".", data = {}, enhancement = enhancement }
    setmetatable(m, self)
    self.__index = self
    return m
end

function Map:get(x, y)
    if self.data[x] and self.data[x][y] then return self.data[x][y] end
    return self.default
end

function Map:insert(x, y, c)
    if not self.data[x] then self.data[x] = {} end
    self.data[x][y] = c
end

function Map:points()
    local xmin, xmax, ymin, ymax
    for x, ys in pairs(self.data) do
        for y, _ in pairs(ys) do
            if not xmin then
                xmin, xmax, ymin, ymax = x, x, y, y
            else
                if x < xmin then xmin = x end
                if x > xmax then xmax = x end
                if y < ymin then ymin = y end
                if y > ymax then ymax = y end
            end
        end
    end

    return coroutine.wrap(function()
        for x = xmin - 1, xmax + 1 do
            for y = ymin - 1, ymax + 1 do
                coroutine.yield(x, y)
            end
        end
    end)
end

function Map:step()
    local newmap = Map:new()
    for x, y in self:points() do
        local num = ""
        for n in iter:new(neighbors(x, y)) do
            if self:get(n[1], n[2]) == "#" then
                num = num .. "1"
            else
                num = num .. "0"
            end
        end
        num = tonumber(num, 2)
        newmap:insert(x, y, self.enhancement[num + 1])
    end
    self.data = newmap.data

    if self.default == "." then
        self.default = "#"
    else
        self.default = "."
    end
end

function Map:countLit()
    local lit = 0
    for x, y in self:points() do
        if self:get(x, y) == "#" then lit = lit + 1 end
    end
    return lit
end

local map
do
    local lines = io.input("input/day20"):lines()

    local enhancement = {}
    for c in lines():gmatch(".") do table.insert(enhancement, c) end

    lines() -- skip empty line

    map = Map:new(enhancement)
    do
        local x = 0
        for line in lines do
            x = x + 1
            local y = 0
            for c in line:gmatch(".") do
                y = y + 1
                map:insert(x, y, c)
            end
        end
    end
end

for _ = 1, 2 do map:step() end
print("Part 1:", map:countLit())

for _ = 3, 50 do map:step() end
print("Part 1:", map:countLit())
