local nums = io.input("input/day17"):read():gmatch("-?%d+")
local xmin, xmax, ymin, ymax = tonumber(nums()), tonumber(nums()), tonumber(nums()), tonumber(nums())

print("Part 1:", ymin * (ymin + 1) / 2)

local cnt = 0
for vx = 0, xmax do
    for vy = ymin, -ymin do
        local cur_vx, x = vx, 0
        local cur_vy, y = vy, 0

        for _ = 1, 500 do
            x = x + cur_vx
            if cur_vx > 0 then cur_vx = cur_vx - 1 end

            y = y + cur_vy
            cur_vy = cur_vy - 1

            if x >= xmin and x <= xmax and y >= ymin and y <= ymax then
                cnt = cnt + 1
                break
            end

            if x > xmax or y < ymin then break end
        end
    end
end
print("Part 2:", cnt)
