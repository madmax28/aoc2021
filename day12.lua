local iter = require "lib/iter"

local graph = { nodes = {} }
for line in io.input("input/day12"):lines() do
    local edge = iter:new(line:gmatch("%a+")):collect()

    for node in iter:new(edge) do
        if not graph.nodes[node] then
            local small = node == node:lower()
            graph.nodes[node] = { neighbors = {}, small = small }
        end
    end

    table.insert(graph.nodes[edge[1]].neighbors, edge[2])
    table.insert(graph.nodes[edge[2]].neighbors, edge[1])
end

local function contains (list, item)
    for _, v in ipairs(list) do
        if v == item then return true end
    end
    return false
end

local function _dfs (path, revisit)
    if path[#path] == "end" then return coroutine.yield(path) end

    for _, neighbor in ipairs(graph.nodes[path[#path]].neighbors) do
        if neighbor ~= "start" then
            local visit, revisit = true, revisit
            if graph.nodes[neighbor].small then
                visit = revisit or not contains(path, neighbor)
                revisit = revisit and not contains(path, neighbor)
            end

            if visit then
                table.insert(path, neighbor)
                _dfs(path, revisit)
                table.remove(path, #path)
            end
        end
    end
end

local function dfs (path, revisit)
    return coroutine.wrap(function ()
        _dfs(path, revisit)
    end)
end

print("Part 1:", iter:new(dfs({ "start" }, false)):count())
print("Part 2:", iter:new(dfs({ "start" }, true)):count())
