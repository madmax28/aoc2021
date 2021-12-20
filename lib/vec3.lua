local Vec3 = {}

function Vec3:new(list)
    local vec = { x = list[1], y = list[2], z = list[3] }
    setmetatable(vec, self)
    self.__index = self
    return vec
end

function Vec3:rotx()
    local z = self.y
    self.y = -self.z
    self.z = z
end

function Vec3:roty()
    local z = -self.x
    self.x = self.z
    self.z = z
end

function Vec3:rotz()
    local y = self.x
    self.x = -self.y
    self.y = y
end

function Vec3:equals(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

function Vec3:manhattan(other)
    local d = math.abs(other.x - self.x)
    d = d + math.abs(other.y - self.y)
    d = d + math.abs(other.z - self.z)
    return d
end

function Vec3:print()
    io.write(self.x, ",", self.y, ",", self.z, "\n")
end

return Vec3
