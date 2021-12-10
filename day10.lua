function token (char)
    if char == "(" then
        return { type = "(", open = true }
    elseif char == ")" then
        return { type = "(", open = false }
    elseif char == "{" then
        return { type = "{", open = true }
    elseif char == "}" then
        return { type = "{", open = false }
    elseif char == "[" then
        return { type = "[", open = true }
    elseif char == "]" then
        return { type = "[", open = false }
    elseif char == "<" then
        return { type = "<", open = true }
    elseif char == ">" then
        return { type = "<", open = false }
    end
end

local error_scores = {
    ["("] = 3,
    ["["] = 57,
    ["{"] = 1197,
    ["<"] = 25137,
}

local score = 0
local incomplete = {}
for line in io.input("input/day10"):lines() do
    local stack = {}
    local err = false

    for char in line:gmatch(".") do
        local token = token(char)
        if token.open then
            table.insert(stack, token)
        else
            if token.type == stack[#stack].type then
                table.remove(stack, #stack)
            else
                score = score + error_scores[token.type]
                err = true
                break
            end
        end
    end

    if not err then table.insert(incomplete, stack) end
end
print("Part 1:", score)

local auto_scores = {
    ["("] = 1,
    ["["] = 2,
    ["{"] = 3,
    ["<"] = 4,
}

local scores = {}
for _, stack in ipairs(incomplete) do
    score = 0
    while #stack > 0 do
        score = score * 5 + auto_scores[table.remove(stack, #stack).type]
    end
    table.insert(scores, score)
end
table.sort(scores)
print("Part 2:", scores[(#scores + 1) / 2])
