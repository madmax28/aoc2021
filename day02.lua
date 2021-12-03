local util = require("util")

local input = {}
for dir, val in io.open("input/day02", "r"):read("*all"):gmatch("(%w+)%s(%d+)") do
    table.insert(input, { dir = dir, val = tonumber(val) })
end

local down, forward = 0, 0
for _, v in pairs(input) do
    if v.dir == "forward" then
        forward = forward + v.val
    elseif v.dir == "down" then
        down = down + v.val
    else
        down = down - v.val
    end
end
print("Part 1", down * forward)

local aim = 0
down = 0
forward = 0
for _, v in pairs(input) do
    if v.dir == "forward" then
        forward = forward + v.val
        down = down + aim * v.val
    elseif v.dir == "down" then
        aim = aim + v.val
    else
        aim = aim - v.val
    end
end
print("Part 2", down * forward)
