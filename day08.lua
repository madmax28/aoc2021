local iter = require "lib/iter"
local util = require "lib/util"

local Digit = {}

function Digit:new (str)
    local d = { str = str }
    setmetatable(d, self)
    self.__index = self
    return d
end

function Digit:len ()
    return self.str:len()
end

function Digit:contains (other)
    for c in util.char_iter(other.str) do
        if not self.str:find(c) then return false end
    end
    return true
end

function Digit:equals (other)
    return self.str == other.str
end

local segments = {}

for line in io.input("input/day08"):lines() do
    local seg = { patterns = {}, digits = {} }
    local word = line:gmatch("%a+")
    for _ = 1, 10 do table.insert(seg.patterns, Digit:new(word())) end
    for _ = 1, 4 do table.insert(seg.digits, Digit:new(word())) end
    table.insert(segments, seg)
end

local cnt = 0
for _, seg in ipairs(segments) do
    for _, digit in ipairs(seg.digits) do
        local len = digit:len()
        if len == 2 or len == 4 or len == 3 or len == 7 then cnt = cnt + 1 end
    end
end
print("Part 1:", cnt)

for _, seg in ipairs(segments) do
    local solutions = { digits = {} }

    function solutions:contains (digit)
        for _, d in pairs(self.digits) do
            if d.str == digit.str then return true end
        end
        return false
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 2 then
            solutions.digits["1"] = digit
        elseif digit:len() == 3 then
            solutions.digits["7"] = digit
        elseif digit:len() == 4 then
            solutions.digits["4"] = digit
        elseif digit:len() == 7 then
            solutions.digits["8"] = digit
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 5 and digit:contains(solutions.digits["1"]) then
            solutions.digits["3"] = digit
            break
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 6 and not digit:contains(solutions.digits["1"]) then
            solutions.digits["6"] = digit
            break
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 5 and solutions.digits["6"]:contains(digit) then
            solutions.digits["5"] = digit
            break
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 6 and digit:contains(solutions.digits["4"]) then
            solutions.digits["9"] = digit
            break
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 5 and not solutions:contains(digit) then
            solutions.digits["2"] = digit
            break
        end
    end

    for _, digit in ipairs(seg.patterns) do
        if digit:len() == 6 and not solutions:contains(digit) then
            solutions.digits["0"] = digit
            break
        end
    end

    seg.solutions = solutions
end

local sum = 0
for _, seg in ipairs(segments) do
    local num = ""
    for _, digit in ipairs(seg.digits) do
        for k, v in pairs(seg.solutions.digits) do
            if digit:contains(v) and v:contains(digit) then
                num = num .. k
                break
            end
        end
    end
    sum = sum + tonumber(num)
end
print("Part 2:", sum)

