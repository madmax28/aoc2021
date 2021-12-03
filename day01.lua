local input = {}
for line in io.open("input/day01", "r"):lines() do
    table.insert(input, tonumber(line))
end

local cnt = 0
for idx = 2, #input do
    if input[idx] > input[idx - 1] then
        cnt = cnt + 1
    end
end
print("Part 1:", cnt)

cnt = 0
for idx = 4, #input do
    if input[idx] > input[idx - 3] then
        cnt = cnt + 1
    end
end
print("Part 2:", cnt)
