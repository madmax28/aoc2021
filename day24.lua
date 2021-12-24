local function input(digits)
    local i = 0
    return function()
        i = i + 1
        if i <= #digits then return digits[i] end
    end
end

local Alu = {}

function Alu:new(program)
    local alu = { x = 0, y = 0, z = 0, w = 0, input = input, program = program }
    setmetatable(alu, self)
    self.__index = self
    return alu
end

function Alu:get(op)
    if op:match("%d+") then
        return tonumber(op)
    end

    if op == "x" then return self.x end
    if op == "y" then return self.y end
    if op == "z" then return self.z end
    if op == "w" then return self.w end
end

function Alu:set(reg, val)
    if reg == "x" then self.x = val end
    if reg == "y" then self.y = val end
    if reg == "z" then self.z = val end
    if reg == "w" then self.w = val end
end

function Alu:run(digits)
    self.input = input(digits)
    self.x, self.y, self.z, self.w = 0, 0, 0, 0

    for _, op in ipairs(self.program) do
        if op.insn == "inp" then
            local inp = self.input()
            assert(inp)
            self:set(op.op1, inp)
        elseif op.insn == "add" then
            self:set(op.op1, self:get(op.op1) + self:get(op.op2))
        elseif op.insn == "mul" then
            self:set(op.op1, self:get(op.op1) * self:get(op.op2))
        elseif op.insn == "div" then
            local res = self:get(op.op1) / self:get(op.op2)
            if res > 0 then
                res = math.floor(res)
            else
                res = math.ceil(res)
            end

            self:set(op.op1, res)
        elseif op.insn == "mod" then
            self:set(op.op1, self:get(op.op1) % self:get(op.op2))
        elseif op.insn == "eql" then
            local res
            if self:get(op.op1) == self:get(op.op2) then
                res = 1
            else
                res = 0
            end

            self:set(op.op1, res)
        end
    end

    return self.z
end

local State = {}

function State:new(alu, digits)
    local s = { digits = digits, z = alu:run(digits) }
    setmetatable(s, self)
    self.__index = self
    return s
end

function State:num()
    local s = ""
    for _, d in ipairs(self.digits) do s = s .. tostring(d) end
    return tonumber(s)
end

function State:lessThan(other)
    return self:num() < other:num()
end

function State:largerThan(other)
    return self:num() > other:num()
end

local alu
do
    local program = {}
    for line in io.input("input/day24"):lines() do
        local words = line:gmatch("-?%w+")
        table.insert(program, { insn = words(), op1 = words(), op2 = words() })
    end
    alu = Alu:new(program)
end

local function search(state, cmp)
    local digits = {}
    for _, d in ipairs(state.digits) do
        table.insert(digits, d)
    end

    for i = 1, 14 do
        for j = i + 1, 14 do
            for ni = 1, 9 do
                for nj = 1, 9 do
                    local savei, savej = digits[i], digits[j]

                    digits[i], digits[j] = ni, nj
                    local newstate = State:new(alu, digits)

                    if newstate.z < state.z then
                        return search(newstate, cmp)
                    end

                    if newstate.z == 0 and cmp(newstate, state) then
                        return search(newstate, cmp)
                    end

                    digits[i], digits[j] = savei, savej
                end
            end
        end
    end

    return state:num()
end


local state = State:new(alu, { 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9 })
print("Part 1:", search(state, State.largerThan))

state = State:new(alu, { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 })
print("Part 2:", search(state, State.lessThan))
