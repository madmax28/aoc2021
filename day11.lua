local iter = require "lib/iter"

local grid = { grid = {} }
for x, line in iter:new(io.input("input/day11"):lines()):enumerate() do
    for y, energy in iter:new(line:gmatch(".")):map(tonumber):enumerate() do
        if not grid.grid[x] then grid.grid[x] = {} end
        grid.grid[x][y] = { energy = energy, flashed = false }
    end
end

function grid:dumbos ()
    return coroutine.wrap(function ()
        for x, ys in pairs(self.grid) do
            for y, dumbo in pairs(ys) do
                coroutine.yield(dumbo, x, y)
            end
        end
    end)
end

function grid:neighbors (x, y)
    return iter:new({
        { x = x, y = y - 1 },
        { x = x, y = y + 1 },
        { x = x - 1, y = y },
        { x = x - 1, y = y - 1 },
        { x = x - 1, y = y + 1 },
        { x = x + 1, y = y },
        { x = x + 1, y = y - 1 },
        { x = x + 1, y = y + 1 },
    }):filter(function (p)
        return self.grid[p.x] and self.grid[p.x][p.y]
    end):map(function (p)
        return self.grid[p.x][p.y], p.x, p.y
    end)
end

function grid:step ()
    for dumbo in self:dumbos() do dumbo.energy = dumbo.energy + 1 end

    local num_flashes = 0
    local flashes = true
    while flashes do
        flashes = false
        for dumbo, x, y in self:dumbos() do
            if not dumbo.flashed and dumbo.energy > 9 then
                num_flashes = num_flashes + 1
                dumbo.flashed = true
                flashes = true
                for neighbor in self:neighbors(x, y) do
                    neighbor.energy = neighbor.energy + 1
                end
            end
        end
    end

    for dumbo in self:dumbos() do
        if dumbo.flashed then dumbo.energy = 0 end
        dumbo.flashed = false
    end

    return num_flashes
end

local flashes = 0
for _ = 1, 100 do flashes = flashes + grid:step() end
print("Part 1:", flashes)

local step = 101
while grid:step() ~= 100 do step = step + 1 end
print("Part 2:", step)
