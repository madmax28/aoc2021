local iter = require "lib/iter"
local Vec3 = require "lib/vec3"

local function apply_ops(scanner, ops)
    for _, scan in ipairs(scanner.scans) do
        for _, op in ipairs(ops) do
            op(scan)
        end
    end
end

local function scannerpos(p, v1, v2)
    return Vec3:new{p.x + v1.x - v2.x, p.y + v1.y - v2.y, p.z + v1.z - v2.z}
end

local function beaconpos(p, v1)
    return Vec3:new{p.x + v1.x, p.y + v1.y, p.z + v1.z}
end

local ops = {
    {},
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.roty },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.roty },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.roty, Vec3.rotx, Vec3.roty, Vec3.roty },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.roty },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.roty },
    { Vec3.rotx },
    { Vec3.rotx },
    { Vec3.rotx },
}

local scanners = {}
local cur = { scans = {} }
for line in io.input("input/day19"):lines() do
    if line:match(",") then
        table.insert(cur.scans, Vec3:new(
            iter:new(line:gmatch("-?%d+")):map(tonumber):collect())
        )
    elseif line == "" then
        table.insert(scanners, cur)
        cur = { scans = {} }
    end
end
table.insert(scanners, cur)

local function match_scanners(s1, s2)
    for s1i1 = 1, #s1.scans do
        for s2i1 = 1, #s2.scans do
            local matched2 = { [s2i1] = true }
            local pos1 = scannerpos(s1.pos, s1.scans[s1i1], s2.scans[s2i1])

            local matches = 1
            for s1i2 = s1i1 + 1, #s1.scans do
                for s2i2 = 1, #s2.scans do
                    if not matched2[s2i2] then
                        local pos2 = scannerpos(s1.pos, s1.scans[s1i2], s2.scans[s2i2])
                        if pos1:equals(pos2) then
                            matches = matches + 1
                            matched2[s2i2] = true
                        end
                    end
                end
            end

            if matches >= 12 then
                s2.pos = pos1
                return matches
            end
        end
    end
end

scanners[1].pos = Vec3:new{0, 0, 0}
local checked = {} -- optimization: avoid checking distinct pairs multiple times
while iter:new(scanners):filter(function (s) return not s.pos end):count() > 0 do
    for i = 1, #scanners do
        if not scanners[i].pos then goto continue_outer end

        for j = 1, #scanners do
            if scanners[j].pos or i == j then goto continue_inner end
            if checked[i] and checked[i][j] then goto continue_inner end

            if not checked[i] then checked[i] = {} end
            checked[i][j] = true

            for _, os in ipairs(ops) do
                apply_ops(scanners[j], os)
                local matches = match_scanners(scanners[i], scanners[j])
                if matches then
                    goto continue_outer
                end
            end

            ::continue_inner::
        end

        ::continue_outer::
    end
end

local map = {}
for _, scanner in ipairs(scanners) do
    for _, scan in ipairs(scanner.scans) do
        local pos = beaconpos(scanner.pos, scan)
        if not map[pos.x] then map[pos.x] = {} end
        if not map[pos.x][pos.y] then map[pos.x][pos.y] = {} end
        map[pos.x][pos.y][pos.z] = true
    end
end

local cnt = 0
for _, ys in pairs(map) do
    for _, zs in pairs(ys) do
        for _ in pairs(zs) do
            cnt = cnt + 1
        end
    end
end
print("Part 1:", cnt)

local max = 0
for i = 1, #scanners do
    for j = i + 1, #scanners do
        local d = scanners[i].pos:manhattan(scanners[j].pos)
        if d > max then max = d end
    end
end
print("Part 2:", max)
