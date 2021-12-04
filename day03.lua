local util = require("lib.util")
local set = require("lib.set")

local nums = {}
for line in io.open("input/day03", "r"):lines() do
    table.insert(nums, line)
end

local diag = {}
for _, num in pairs(nums) do
    for idx = 1, #num do
        if idx > #diag then
            table.insert(diag, { ones = 0, zeros = 0 })
        end

        if num:sub(idx, idx) == "1" then
            diag[idx].ones = diag[idx].ones + 1
        else
            diag[idx].zeros = diag[idx].zeros + 1
        end
    end
end

local gamma, epsilon = "", ""
for _, count in pairs(diag) do
    if count.ones > count.zeros then
        gamma = gamma .. "1"
        epsilon = epsilon .. "0"
    else
        gamma = gamma .. "0"
        epsilon = epsilon .. "1"
    end
end
print("Part 1:", tonumber(gamma, 2) * tonumber(epsilon, 2))

local function most_common (nums, pos)
    local cnt = {}
    cnt["1"] = 0; cnt["0"] = 0

    for num, _ in pairs(nums) do
        cnt[num:sub(pos, pos)] = cnt[num:sub(pos, pos)] + 1
    end

    if cnt["1"] >= cnt["0"] then
        return "1"
    else
        return "0"
    end
end

local o2set = set:new(nums)
local co2set = set:new(nums)
local o2, co2
for idx = 1, #diag do
    if not o2 then
        local mc = most_common(o2set.items, idx)
        for cand, _ in pairs(o2set.items) do
            if cand:sub(idx, idx) ~= mc then
                o2set.items[cand] = nil
            end
        end

        if util.tablelength(o2set.items) == 1 then
            for res, _ in pairs(o2set.items) do
                o2 = res
            end
        end
    end

    if not co2 then
        local mc
        if most_common(co2set.items, idx) == "1" then
            mc = "0"
        else
            mc = "1"
        end

        for cand, _ in pairs(co2set.items) do
            if cand:sub(idx, idx) ~= mc then
                co2set.items[cand] = nil
            end
        end

        if util.tablelength(co2set.items) == 1 then
            for res, _ in pairs(co2set.items) do
                co2 = res
            end
        end
    end
end
print("Part 2:", tonumber(o2, 2) * tonumber(co2, 2))
