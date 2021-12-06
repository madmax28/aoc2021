local iter = require "lib/iter"

local state = { 0, 0, 0, 0, 0, 0, 0, 0, 0 }

for num in iter:new(io.input("input/day06"):read():gmatch("%d+")):map(tonumber) do
    state[num + 1] = state[num + 1] + 1
end

for _ = 1, 80 do
    local resets = table.remove(state, 1)
    state[7] = state[7] + resets
    table.insert(state, resets)
end
local cnt = iter:new(state):sum()
print("Part 1:", cnt)

for _ = 81, 256 do
    local resets = table.remove(state, 1)
    state[7] = state[7] + resets
    table.insert(state, resets)
end
local cnt = iter:new(state):sum()
print("Part 2:", cnt)
