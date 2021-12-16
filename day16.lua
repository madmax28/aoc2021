local hex2bin = {
    ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
    ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
    ["8"] = "1000", ["9"] = "1001", ["A"] = "1010", ["B"] = "1011",
    ["C"] = "1100", ["D"] = "1101", ["E"] = "1110", ["F"] = "1111",
}

local packet = ""
for hex in io.input("input/day16"):read():gmatch(".") do
    packet = packet .. hex2bin[hex]
end

local parser = { packet = packet, idx = 1, ver_sum = 0 }

local function apply_op(type_id, a, b)
    if type_id == 0 then
        return a + b
    elseif type_id == 1 then
        return a * b
    elseif type_id == 2 then
        return math.min(a, b)
    elseif type_id == 3 then
        return math.max(a, b)
    elseif type_id == 5 then
        if a > b then return 1 else return 0 end
    elseif type_id == 6 then
        if a < b then return 1 else return 0 end
    elseif type_id == 7 then
        if a == b then return 1 else return 0 end
    end
end

function parser:extract_str(len)
    local str = self.packet:sub(self.idx, self.idx + len - 1)
    self.idx = self.idx + len
    return str
end

function parser:extract_num(len)
    return tonumber(self:extract_str(len), 2)
end

function parser:parse()
    local version = self:extract_num(3)
    self.ver_sum = self.ver_sum + version
    local type_id = self:extract_num(3)

    if type_id == 4 then
        local payload = ""
        while self:extract_num(1) == 1 do
            payload = payload .. self:extract_str(4)
        end
        return tonumber(payload .. self:extract_str(4), 2)
    else -- operator
        local length_id = self:extract_num(1)
        local res
        if length_id == 0 then
            local bit_len = self:extract_num(15)
            local bit_tgt = self.idx + bit_len
            while self.idx < bit_tgt do
                local rres = self:parse()
                if not res then res = rres else res = apply_op(type_id, res, rres) end
            end
        else -- length_id == 1
            local num_subs = self:extract_num(11)
            for _ = 1, num_subs do
                local rres = self:parse()
                if not res then res = rres else res = apply_op(type_id, res, rres) end
            end
        end
        return res
    end
end

local res = parser:parse()
print("Part 1:", parser.ver_sum)
print("Part 2:", res)
