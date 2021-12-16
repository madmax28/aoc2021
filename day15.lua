local iter = require "lib/iter"
local priority_queue = require "lib/priority_queue"

local grid = { grid = {} }
local dim = 100
for x, line in iter:new(io.input("input/day15"):lines()):enumerate() do
    for y, risk in iter:new(line:gmatch(".")):map(tonumber):enumerate() do
        if not grid.grid[x] then grid.grid[x] = {} end
        grid.grid[x][y] = tonumber(risk)
    end
end

function grid:neighbors (x, y)
    return iter:new({
        { x = x, y = y - 1 },
        { x = x, y = y + 1 },
        { x = x - 1, y = y },
        { x = x + 1, y = y },
    }):filter(function (p)
        return self.grid[p.x] and self.grid[p.x][p.y]
    end):map(function (p)
        return { risk = self.grid[p.x][p.y], x = p.x, y = p.y }
    end)
end

function grid:expand (pq, visited)
    local x, y, risk
    do
        local cand
        repeat
            cand = pq:pop()
        until not visited[cand.x] or not visited[cand.x][cand.y]
        x, y, risk = cand.x, cand.y, cand.risk
    end

    if not visited[x] then visited[x] = {} end
    visited[x][y] = true

    for neighbor in self:neighbors(x, y) do
        local nx, ny = neighbor.x, neighbor.y
        if not visited[nx] or not visited[nx][ny] then
            pq:insert({ x = nx, y = ny, risk = risk + neighbor.risk })
        end
    end

    return x, y, risk
end

local function search ()
    local pq = priority_queue:new({ { x = 1, y = 1, risk = 0 } }, function(a, b)
        return a.risk < b.risk
    end)
    local visited = {}
    local x, y, risk
    while true do
        x, y, risk = grid:expand(pq, visited)
        if x == dim and y == dim then return risk end
    end
end
print("Part 1:", search())

for dx = 0, 4 do
    for dy = 0, 4 do
        if dx == 0 and dy == 0 then goto continue end

        for x = 1, dim do
            for y = 1, dim do
                if not grid.grid[x + dx * dim] then grid.grid[x + dx * dim] = {} end
                local risk = (grid.grid[x][y] - 1 + dx + dy) % 9 + 1
                grid.grid[x + dx * dim][y + dy * dim] = risk
            end
        end

        ::continue::
    end
end
dim = 500
print("Part 2:", search())
