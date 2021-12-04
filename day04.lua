local util = require "lib/util"
local set = require "lib/set"

local input = io.open("input/day04", "r"):lines()

local nums = {}
do
    for str in input():gmatch("%d+") do
        table.insert(nums, tonumber(str))
    end
    input()
end

local Board = {}

function Board:new (data)
    local b = {}
    setmetatable(b, self)
    self.__index = self

    b.data = data or {}
    return b
end

function Board:print ()
    util.print_table(self)
end

function Board:tag (num)
    for _, row in ipairs(self.data) do
        for _, entry in ipairs(row) do
            if entry.num == num then entry.seen = true end
        end
    end
end

function Board:won ()
    for i = 1, #self.data do
        local won_col, won_row = true, true
        for j = 1, #self.data do
            won_row = won_row and self.data[i][j].seen
            won_col = won_col and self.data[j][i].seen
        end

        if won_col or won_row then return true end
    end

    return false
end

function Board:score (num)
    local sum = 0
    for _, row in ipairs(self.data) do
        for _, entry in ipairs(row) do
            if not entry.seen then sum = sum + entry.num end
        end
    end
    return sum * num
end

local boards = {}
do
    local data = {}
    for line in input do
        if line == "" then
            table.insert(boards, Board:new(data))
            data = {}
        else
            local row = {}
            for str in line:gmatch("%d+") do
                table.insert(row, { num = tonumber(str), seen = false })
            end
            table.insert(data, row)
        end
    end
    table.insert(boards, Board:new(data))
end

local score
local it = util.list_iter(nums)
for num in it do
    local found = false
    for _, board in ipairs(boards) do
        board:tag(num)
        if board:won() then
            score = board:score(num)
            found = true
        end
    end
    if found then break end
end
print("Part 1", score)

boards = set:new(boards)
for num in it do
    for board in boards:iter() do
        board:tag(num)
        if board:won() then boards:erase(board) end
    end

    if boards:size() == 1 then break end
end

local board = boards:iter()()
for num in it do
    board:tag(num)
    if board:won() then
        score = board:score(num)
        break
    end
end
print("Part 2", score)
