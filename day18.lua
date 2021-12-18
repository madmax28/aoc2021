local iter = require "lib/iter"

local function parse(str)
    local num = {}
    for c in str:gmatch(".") do
        if c == "[" or c == "]" then
            table.insert(num, c)
        elseif c ~= "," then
            table.insert(num, tonumber(c))
        end
    end
    return num
end

local nums = iter:new(io.input("input/day18"):lines()):map(parse):collect()

local function explode(num)
    local exploded = false
    local idx, depth = 1, 0
    while idx < #num do
        if num[idx] == "[" then
            if depth == 4 then
                exploded = true

                table.remove(num, idx)
                local left = table.remove(num, idx)
                local right = table.remove(num, idx)
                num[idx] = 0

                local tmpidx = idx - 1
                while type(num[tmpidx]) ~= "number" and tmpidx > 0 do
                    tmpidx = tmpidx - 1
                end
                if tmpidx > 0 then num[tmpidx] = num[tmpidx] + left end

                tmpidx = idx + 1
                while type(num[tmpidx]) ~= "number" and tmpidx <= #num do
                    tmpidx = tmpidx + 1
                end
                if tmpidx <= #num then num[tmpidx] = num[tmpidx] + right end
            else
                depth = depth + 1
            end
        elseif num[idx] == "]" then
            depth = depth - 1
        end
        idx = idx + 1
    end
    return exploded
end

local function split(num)
    local idx = 1
    while idx < #num do
        if type(num[idx]) == "number" and num[idx] > 9 then
            local left = math.floor(num[idx] / 2)
            local right = math.ceil(num[idx] / 2)
            num[idx] = "]"
            table.insert(num, idx, right)
            table.insert(num, idx, left)
            table.insert(num, idx, "[")
            return true
        end
        idx = idx + 1
    end
    return false
end

local function add(a, b)
    -- copy a
    local num = {}
    for _, v in ipairs(a) do table.insert(num, v) end

    table.insert(num, 1, "[")
    for _, v in ipairs(b) do table.insert(num, v) end
    table.insert(num, "]")

    repeat
        local exploded = explode(num)
        local splitted = split(num)
    until not exploded and not splitted

    return num
end

local function magnitude(num, idx)
    idx = idx or { 1 }
    local mag
    if type(num[idx[1]]) == "string" then
        idx[1] = idx[1] + 1
        mag = 3 * magnitude(num, idx)
        mag = mag + 2 * magnitude(num, idx)
        idx[1] = idx[1] + 1
    else
        mag = num[idx[1]]
        idx[1] = idx[1] + 1
    end
    return mag
end

local mag = magnitude(iter:new(nums):reduce(add))
print("Part 1:", mag)

mag = 0
for _, a in ipairs(nums) do
    for _, b in ipairs(nums) do
        if a ~= b then
            local cand = magnitude(add(a, b))
            if cand > mag then mag = cand end
        end
    end
end
print("Part 2:", mag)
