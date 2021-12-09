local iter = require "lib/iter"
local util = require "lib/util"

local map = { data = {}, lows = {}, basins = {} }

function map:neighbors (x, y)
    return iter:new({
        { x = x - 1, y = y },
        { x = x + 1, y = y },
        { x = x, y = y - 1 },
        { x = x, y = y + 1 },
    })
    :filter(function (p) return self.data[p.x] and self.data[p.x][p.y] end)
    :map(function (p) return p.x, p.y end)
end

function map:score (x, y)
    for px, py in self:neighbors(x, y) do
        if self.data[px][py] <= self.data[x][y] then return 0 end
    end
    table.insert(self.lows, { x = x, y = y })
    return 1 + self.data[x][y]
end

function map:expandBasin (x, y, basin)
    assert(self.data[x][y] < 9)
    for xx, yy in self:neighbors(x, y) do
        if not basin.data[xx] or not basin.data[xx][yy] then
            if self.data[xx][yy] < 9 then
                if not basin.data[xx] then basin.data[xx] = {} end
                basin.data[xx][yy] = true
                basin.size = basin.size + 1
                self:expandBasin(xx, yy, basin)
            end
        end
    end
end

function map:findBasins ()
    for _, p in ipairs(self.lows) do
        local basin = { size = 0, data = {} }
        self:expandBasin(p.x, p.y, basin)
        table.insert(self.basins, basin)
    end
end

local x = 0
for line in io.input("input/day09"):lines() do
    x = x + 1
    if not map.data[x] then map.data[x] = {} end

    local y = 0
    for num in line:gmatch("%d") do
        y = y + 1
        map.data[x][y] = tonumber(num)
    end
end

local score = 0
for x = 1, #map.data do
    for y = 1, #map.data[1] do
        score = score + map:score(x, y)
    end
end
print("Part 1:", score)


map:findBasins()
table.sort(map.basins, function (b1, b2)
    return b1.size > b2.size
end)
local ans = 1
for i = 1, 3 do
    ans = ans * map.basins[i].size
end
print("Part 2:", ans)
