local priority_queue = require "lib.priority_queue"

local costs = { A = 1, B = 10, C = 100, D = 1000 }
local target_ys = { A = 4, B = 6, C = 8, D = 10 }

local Map = {}

function Map:new()
    local m = { data = {}, cost = 0, eval_cost = 0 }
    setmetatable(m, self)
    self.__index = self
    return m
end

function Map:clone()
    local m = Map:new()
    for x, ys in pairs(self.data) do
        for y, c in pairs(ys) do
            m:insert(x, y, c)
        end
    end
    m.cost = self.cost
    m.eval_cost = self.eval_cost
    return m
end

function Map:insert(x, y, c)
    if not self.data[x] then self.data[x] = {} end
    self.data[x][y] = c
end

function Map:get(x, y)
    if self.data[x] then return self.data[x][y] end
end

function Map:neighbors(x, y)
    local ns = {
        { x = x - 1, y = y },
        { x = x + 1, y = y },
        { x = x, y = y - 1 },
        { x = x, y = y + 1 },
    }
    for i = #ns, 1, -1 do
        if self:get(ns[i].x, ns[i].y) ~= '.' then
            table.remove(ns, i)
        end
    end
    return ns
end

function Map:bfs(frontier, visited, xx, yy)
    local cand = table.remove(frontier, 1)
    if not cand then return nil end

    if cand.x == xx and cand.y == yy then
        return cand.steps
    end

    if not visited[cand.x] then visited[cand.x] = {} end
    visited[cand.x][cand.y] = true

    for _, n in ipairs(self:neighbors(cand.x, cand.y)) do
        if not visited[n.x] or not visited[n.x][n.y] then
            n.steps = cand.steps + 1
            table.insert(frontier, n)
        end
    end

    return self:bfs(frontier, visited, xx, yy)
end

function Map:moveCost(x, y, c, xx, yy, cc)
    if cc ~= "." then return nil end

    if xx > 2 then -- room
        -- can only move to assigned rooms
        if yy ~= target_ys[c] then return nil end

        -- cannot move inside a room
        if y == yy and x > 2 and xx > 2 then return nil end

        -- can not move to rooms containing non-destination pods
        for rx = 3, 6 do
            if self.data[rx] and self.data[rx][yy] ~= "." and self.data[rx][yy] ~= c then
                return nil
            end
        end

        -- if moving to destination room, must move to end of it
        for rx = xx + 1, 6 do
            if self.data[rx] and self.data[rx][yy] == "." then return nil end
        end

        local steps = self:bfs({{ x = x, y = y, steps = 0 }}, {}, xx, yy)
        if steps then
            -- if in hallway, only add cost to move from door into room. the
            -- rest was handled moving out of the room
            if x == 2 then -- hallway
                local cost = (xx - 2) * costs[c]
                return cost
            else -- room
                return costs[c] * steps
            end

        end
    else
        -- must not stop in front of room
        if yy == 4 or yy == 6 or yy == 8 or yy == 10 then return nil end

        -- must not move from hallway to hallway
        if x == 2 then return nil end

        local steps = self:bfs({{ x = x, y = y, steps = 0 }}, {}, xx, yy)
        if steps then
            -- add steps to move to its door now, so that each candidate is
            -- indeed always the best option
            steps = steps + math.abs(yy - target_ys[c])
            return costs[c] * steps
        end
    end
end

function Map:tryMoveIntoRoom(x, y, c)
    for xx, ys in pairs(self.data) do
        for yy, cc in pairs(ys) do
            if xx > 2 then -- room
                local cost = self:moveCost(x, y, c, xx, yy, cc)
                if cost then
                    local m = self:clone()
                    m:insert(x, y, cc)
                    m:insert(xx, yy, c)
                    m.cost = m.cost + cost
                    m.eval_cost = m.eval_cost
                    coroutine.yield(m)
                    return true
                end
            end
        end
    end
    return false
end

function Map:move(x, y, c)
    for xx, ys in pairs(self.data) do
        for yy, cc in pairs(ys) do
            if x == xx and y == yy then goto continue end

            local cost = self:moveCost(x, y, c, xx, yy, cc)
            if cost then
                local m = self:clone()
                m:insert(x, y, cc)
                m:insert(xx, yy, c)
                m.cost = m.cost + cost
                m.eval_cost = m.eval_cost + cost
                coroutine.yield(m)
            end

            ::continue::
        end
    end
end

function Map:_expand()
    -- first, try to move any pod into its destination room. if that works, do
    -- it and do not expand other options
    for x, ys in pairs(self.data) do
        for y, c in pairs(ys) do
            if c ~= "." then
                if self:tryMoveIntoRoom(x, y, c) then
                    return
                end
            end
        end
    end

    for x, ys in pairs(self.data) do
        for y, c in pairs(ys) do
            if c ~= "." then
                self:move(x, y, c)
            end
        end
    end
end

function Map:expand()
    return coroutine.wrap(function ()
        self:_expand()
    end)
end

function Map:isFinished()
    for x = 3, 6 do
        if self.data[x] and self.data[x][4] ~= 'A' then return false end
        if self.data[x] and self.data[x][6] ~= 'B' then return false end
        if self.data[x] and self.data[x][8] ~= 'C' then return false end
        if self.data[x] and self.data[x][10] ~= 'D' then return false end
    end
    return true
end

function Map:str()
    local s = ""
    for x = 1, 5 do
        for y = 1, 13 do
            if self.data[x] and self.data[x][y] then
                s = s .. tostring(self.data[x][y])
            end
        end
    end
    return s
end

local function parse(p2)
    local map = Map:new()
    local x = 0

    local function parse_line(line)
        local y = 0
        for c in line:gmatch(".") do
            y = y + 1
            if c ~= "#" and c ~= " " then
                map:insert(x, y, c)
            end
        end
    end

    for line in io.input("input/day23"):lines() do
        if p2 and x == 3 then
            x = x + 1
            parse_line("  #D#C#B#A#")
            x = x + 1
            parse_line("  #D#B#A#C#")
        end

        x = x + 1
        parse_line(line)
    end
    return map
end

local function solve(map)
    local pq = priority_queue:new({ map }, function(a, b)
        return a.eval_cost < b.eval_cost
    end)

    local seen = { [map:str()] = 0 }
    while true do
        local cand = pq:pop()

        if cand:isFinished() then
            return cand.cost
        end

        for m in cand:expand() do
            local s = m:str()
            if not seen[s] or seen[s] > m.cost then
                pq:insert(m)
                seen[s] = m.cost
            end
        end
    end
end

local map = parse()
print("Part 1:", solve(map))

map = parse(true)
print("Part 2:", solve(map))
