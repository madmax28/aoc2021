local iter = require "lib/iter"

local nums = iter:new(io.input("input/day07"):read():gmatch("%d+")):map(tonumber):collect()

local min, max
for _, num in ipairs(nums) do
    if not min then
        min = num
        max = num
    else
        if num < min then min = num end
        if num > max then max = num end
    end
end

local function search (nums, min, max, f)
    local fuel
    for num = min, max do
        if not fuel then
            fuel = f(nums, num)
        else
            local cand = f(nums, num)
            if cand < fuel then fuel = cand end
        end
    end
    return fuel
end

local function cost_p1 (nums, tgt)
    local c = 0
    for _, num in ipairs(nums) do
        c = c + math.abs(tgt - num)
    end
    return c
end
print("Part 1:", search(nums, min, max, cost_p1))

local function cost_p2 (nums, tgt)
    local c = 0
    for _, num in ipairs(nums) do
        local steps = math.abs(tgt - num)
        c = c + steps * (steps + 1) / 2
    end
    return c
end
print("Part 2:", search(nums, min, max, cost_p2))
