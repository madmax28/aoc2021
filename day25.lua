local Map = {}

function Map:new()
    local m = { data = {} }
    setmetatable(m, self)
    self.__index = self
    return m
end

function Map:clone()
    local m = Map:new()
    for x, ys in ipairs(self.data) do
        for y, c in ipairs(ys) do
            m:set(x, y, c)
        end
    end
    return m
end

function Map:set(x, y, c)
    if not self.data[x] then self.data[x] = {} end
    self.data[x][y] = c
end

function Map:get(x, y)
    if self.data[x] then return self.data[x][y] end
end

function Map:step()
    local xmax, ymax = 0, 0
    for x, ys in ipairs(self.data) do
        for y, _ in ipairs(ys) do
            xmax, ymax = math.max(x, xmax), math.max(y, ymax)
        end
    end

    local moves = false

    local newmap = self:clone()
    for x, ys in ipairs(self.data) do
        for y, c in ipairs(ys) do
            if c == ">" then
                local yy = y + 1
                if yy > ymax then yy = 1 end

                if self:get(x, yy) == "." then
                    moves = true
                    newmap:set(x, y, ".")
                    newmap:set(x, yy, ">")
                end
            end
        end
    end
    self.data = newmap.data

    newmap = self:clone()
    for x, ys in ipairs(self.data) do
        for y, c in ipairs(ys) do
            if c == "v" then
                local xx = x + 1
                if xx > xmax then xx = 1 end

                if self:get(xx, y) == "." then
                    moves = true
                    newmap:set(x, y, ".")
                    newmap:set(xx, y, "v")
                end
            end
        end
    end
    self.data = newmap.data

    return moves
end

local map = Map:new()
do
    local x = 0
    for line in io.input("input/day25"):lines() do
        x = x + 1
        local y = 0
        for c in line:gmatch(".") do
            y = y + 1
            map:set(x, y, c)
        end
    end
end

local steps = 0
while true do
    steps = steps + 1
    if not map:step() then break end
end
print("Part 1:", steps)
