local iter = require "lib/iter"

local Game = {}

function Game:new(p1, p2)
    local g = { pos = { p1, p2 }, turn = 1, score = { 0, 0 } }
    setmetatable(g, self)
    self.__index = self
    return g
end

function Game:clone()
    local g = Game:new()
    g.pos[1], g.pos[2] = self.pos[1], self.pos[2]
    g.score[1], g.score[2] = self.score[1], self.score[2]
    g.turn = self.turn
    return g
end

function Game:step(roll)
    self.pos[self.turn] = self.pos[self.turn] + roll
    while self.pos[self.turn] > 10 do self.pos[self.turn] = self.pos[self.turn] - 10 end
    self.score[self.turn] = self.score[self.turn] + self.pos[self.turn]
    if self.turn == 2 then self.turn = 1 else self.turn = 2 end
end

function Game:won(tgt)
    if self.score[1] >= tgt then
        return 1
    elseif self.score[2] >= tgt then
        return 2
    end
end

function Game:str()
    return string.format("%d,%d,%d,%d,%d",
        self.pos[1], self.pos[2], self.turn, self.score[1], self.score[2]
    )
end

local Counter = {}

function Counter:new()
    local c = {}
    setmetatable(c, self)
    self.__index = self
    return c
end

function Counter:add(game, cnt)
    local key = game:str()
    if self[key] then
        self[key].cnt = self[key].cnt + cnt
    else
        self[key] = { game = game, cnt = cnt }
    end
end

function Counter:size()
    local cnt = 0
    for _ in pairs(self) do cnt = cnt + 1 end
    return cnt
end

local outcomes = {}
for n1 = 1, 3 do
    for n2 = 1, 3 do
        for n3 = 1, 3 do
            local res = n1 + n2 + n3
            if not outcomes[res] then outcomes[res] = 0 end
            outcomes[res] = outcomes[res] + 1
        end
    end
end

local game
do
    local initial = iter:new(io.input("input/day21"):lines()):map(function(s)
        return tonumber(s:gmatch("%d+$")())
    end):collect()
    game = Game:new(initial[1], initial[2])
end

do
    local die = 1
    local function roll()
        local res = 0
        for _ = 1, 3 do
            res = res + die
            die = die + 1
            if die > 100 then die = die - 100 end
        end
        return res
    end

    local g = game:clone()
    local rolls = 0
    while not g:won(1000) do
        local res = roll()
        rolls = rolls + 1
        g:step(res)
    end

    local score
    if g:won(1000) == 1 then
        score = g.score[2]
    else
        score = g.score[1]
    end
    print("Part 1:", 3 *rolls * score)
end

local counter, won = Counter:new(), Counter:new()
counter:add(game, 1)
while counter:size() > 0 do
    local newcounter = Counter:new()
    for _, entry in pairs(counter) do
        for roll, ccnt in pairs(outcomes) do
            local g = entry.game:clone()
            g:step(roll)
            if g:won(21) then
                won:add(g, entry.cnt * ccnt)
            else
                newcounter:add(g, entry.cnt * ccnt)
            end
        end
    end
    counter = newcounter
end

local cnts = { 0, 0 }
for _, entry in pairs(won) do
    local winner = entry.game:won(21)
    cnts[winner] = cnts[winner] + entry.cnt
end

local cnt
if cnts[1] > cnts[2] then cnt = cnts[1] else cnt = cnts[2] end
print("Part 2:", string.format("%d", cnt))
