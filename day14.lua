local iter = require "lib/iter"

local lines = io.input("input/day14"):lines()
local polymer = iter:new(lines():gmatch("%a")):collect()

local pair_freqs = {}
for i = 2, #polymer do
    local a, b = polymer[i - 1], polymer[i]
    if not pair_freqs[a] then pair_freqs[a] = {} end
    if not pair_freqs[a][b] then
        pair_freqs[a][b] = 1
    else
        pair_freqs[a][b] = pair_freqs[a][b] + 1
    end
end

lines() -- discard empty line

local rules = {}
for line in lines do
    local chars = iter:new(line:gmatch("%a")):collect()
    if not rules[chars[1]] then rules[chars[1]] = {} end
    rules[chars[1]][chars[2]] = chars[3]
end

local function step ()
    local newpair_freqs = {}
    for a, bs in pairs(pair_freqs) do
        for b, cnt in pairs(bs) do
            local c = rules[a][b]
            if not newpair_freqs[a] then newpair_freqs[a] = {} end
            if not newpair_freqs[a][c] then newpair_freqs[a][c] = 0 end
            newpair_freqs[a][c] = newpair_freqs[a][c] + cnt
            if not newpair_freqs[c] then newpair_freqs[c] = {} end
            if not newpair_freqs[c][b] then newpair_freqs[c][b] = 0 end
            newpair_freqs[c][b] = newpair_freqs[c][b] + cnt
        end
    end
    pair_freqs = newpair_freqs
end

local function count ()
    local cnts = {}
    for a, bs in pairs(pair_freqs) do
        for _, cnt in pairs(bs) do
            if not cnts[a] then
                cnts[a] = cnt
            else
                cnts[a] = cnts[a] + cnt
            end
        end
    end

    local last = polymer[#polymer]
    if not cnts[last] then
        cnts[last] = 1
    else
        cnts[last] = cnts[last] + 1
    end

    local min, max
    for _, cnt in pairs(cnts) do
        if not min then
            min, max = cnt, cnt
        elseif cnt < min then
            min = cnt
        elseif cnt > max then
            max = cnt
        end
    end

    return max - min
end

for _ = 1, 10 do step() end
print("Part 1:", count())

for _ = 11, 40 do step() end
print("Part 2:", count())
