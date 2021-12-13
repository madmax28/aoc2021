local iter = require "lib/iter"

local lines = io.input("input/day13"):lines()
local paper, folds = {}, {}
while true do
    local line = lines()
    if line == "" then break end

    local p = iter:new(line:gmatch("%d+")):map(tonumber):collect()
    if not paper[p[1]] then paper[p[1]] = {} end
    paper[p[1]][p[2]] = true
end

for line in lines do
    for axis, n in line:gmatch("(%a)=(%d+)") do
        table.insert(folds, { axis = axis, n = tonumber(n) })
    end
end

local function fold_paper(axis, n)
    local newpaper = {}
    for x, ys in pairs(paper) do
        for y, _ in pairs(ys) do
            if axis == "x" then
                if x < n then
                    if not newpaper[x] then newpaper[x] = {} end
                    newpaper[x][y] = true
                elseif x > n then
                    if not newpaper[2 * n - x] then newpaper[2 * n - x] = {} end
                    newpaper[2 * n - x][y] = true
                end
            else
                if y < n then
                    if not newpaper[x] then newpaper[x] = {} end
                    newpaper[x][y] = true
                elseif y > n then
                    if not newpaper[x] then newpaper[x] = {} end
                    newpaper[x][2 * n - y] = true
                end
            end
        end
    end
    paper = newpaper
end

fold_paper(folds[1].axis, folds[1].n)
local cnt = 0
for _, ys in pairs(paper) do for _ in pairs(ys) do cnt = cnt + 1 end end
print("Part 1:", cnt)

local function print_paper()
    local xmax, ymax = 0, 0
    for x, ys in pairs(paper) do
        for y, _ in pairs(ys) do
            if x > xmax then xmax = x end
            if y > ymax then ymax = y end
        end
    end

    for y = 0, ymax do
        for x = 0, xmax do
            if paper[x] and paper[x][y] then
                io.write("#")
            else
                io.write(".")
            end
        end
        io.write("\n")
    end
end

for i = 2, #folds do
    fold_paper(folds[i].axis, folds[i].n)
end
print("Part 2:")
print_paper()
