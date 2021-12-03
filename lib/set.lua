local set = {}

function set.Set (list)
    local s = {}
    for _, l in pairs(list) do s[l] = true end
    return s
end

return set
