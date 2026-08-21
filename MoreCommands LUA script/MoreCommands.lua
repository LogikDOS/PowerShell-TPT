mc = mc or {}

function mc.element(name)
    if type(name) ~= "string" then
        return nil
    end

    return tpt.element(name)
end

mc = mc or {}

function mc.randomfill()
    local maxelem = tpt.element("SEED")

    for y = 0, sim.YRES - 1 do
        for x = 0, sim.XRES - 1 do

            -- Random element from NONE through SEED
            local elem = math.random(0, maxelem)

            -- Don't create NONE
            if elem ~= 0 then
                local p = sim.partCreate(-3, x, y, elem)

                if p and p >= 0 then
                    sim.partProperty(p, "life", math.random(0, 65535))
                    sim.partProperty(p, "ctype", math.random(0, maxelem))

                    sim.partProperty(p, "temp", math.random(0, 5000))

                    sim.partProperty(p, "tmp", math.random(0, 65535))
                    sim.partProperty(p, "tmp2", math.random(0, 65535))
                    sim.partProperty(p, "tmp3", math.random(0, 65535))
                    sim.partProperty(p, "tmp4", math.random(0, 65535))

                    sim.partProperty(p, "vx", math.random(-100, 100) / 10)
                    sim.partProperty(p, "vy", math.random(-100, 100) / 10)

                    sim.partProperty(p, "flags", math.random(0, 15))

                    -- Random decoration colour
                    sim.partProperty(p, "dcolour",
                        math.random(0, 0xFFFFFFFF)
                    )
                end
            end
        end
    end
end


mc = mc or {}

function mc.locate(x, y)
    x = tonumber(x)
    y = tonumber(y)

    if not x or not y then
        return false
    end

    if x < 0 or x >= sim.XRES or y < 0 or y >= sim.YRES then
        return false
    end

    sim.partCreate(-3, x, y, tpt.element("DMND"))
    return true
end

mc = mc or {}

function mc.datetime()
    local time = os.date("%Y-%m-%d %H:%M:%S")
    print(time)
    return time
end

mc = mc or {}

mc = mc or {}

function mc.testscreen()
    sim.clearSim()

    local width = sim.XRES
    local height = sim.YRES
    local dmnd = tpt.element("DMND")

    -- Helper: create a coloured DMND pixel
    local function pixel(x, y, colour)
        local p = sim.partCreate(-3, x, y, dmnd)
        if p >= 0 then
            sim.partProperty(p, "dcolour", colour)
        end
    end

    -- =========================================================
    -- 1. RAINBOW
    -- =========================================================

    local rainbow = {
        0xFFFF0000, -- Red
        0xFFFF8000, -- Orange
        0xFFFFFF00, -- Yellow
        0xFF00FF00, -- Green
        0xFF00FFFF, -- Cyan
        0xFF0080FF, -- Blue
        0xFF8000FF  -- Purple
    }

    local rainbowHeight = math.floor(height * 0.45)

    for y = 0, rainbowHeight - 1 do
        local i = math.floor(y / rainbowHeight * #rainbow) + 1
        if i > #rainbow then i = #rainbow end

        for x = 0, width - 1 do
            pixel(x, y, rainbow[i])
        end
    end

    -- =========================================================
    -- 2. GRAYSCALE
    -- =========================================================

    local grayStart = rainbowHeight
    local grayHeight = math.floor(height * 0.2)

    for y = grayStart, grayStart + grayHeight - 1 do
        for x = 0, width - 1 do
            local gray = math.floor((x / (width - 1)) * 255)

            local colour =
                0xFF000000 +
                gray * 0x010101

            pixel(x, y, colour)
        end
    end

    -- =========================================================
    -- 3. RGB / CMY COLOR BARS
    -- =========================================================

    local barsStart = grayStart + grayHeight
    local barsHeight = math.floor(height * 0.2)

    local bars = {
        0xFFFF0000, -- Red
        0xFF00FF00, -- Green
        0xFF0000FF, -- Blue
        0xFFFFFF00, -- Yellow
        0xFF00FFFF, -- Cyan
        0xFFFF00FF  -- Magenta
    }

    local barHeight = math.max(1, math.floor(barsHeight / #bars))

    for i, colour in ipairs(bars) do
        local y1 = barsStart + (i - 1) * barHeight
        local y2 = math.min(height - 1, y1 + barHeight - 1)

        for y = y1, y2 do
            for x = 0, width - 1 do
                pixel(x, y, colour)
            end
        end
    end

    -- =========================================================
    -- 4. BLACK / WHITE CHECKERBOARD
    -- =========================================================

    local checkerStart = barsStart + barsHeight
    local block = 10

    for y = checkerStart, height - 1 do
        for x = 0, width - 1 do
            local bx = math.floor(x / block)
            local by = math.floor(y / block)

            local colour

            if (bx + by) % 2 == 0 then
                colour = 0xFFFFFFFF
            else
                colour = 0xFF000000
            end

            pixel(x, y, colour)
        end
    end
end

mc = mc or {}
function mc.elementtest()
    local startx = math.floor((sim.XRES - 100) / 2)
    local starty = math.floor((sim.YRES - 100) / 2)

    local x = startx
    local y = starty
    local count = 0

    for elem = 1, 1000 do
        if x >= startx + 100 then
            x = startx
            y = y + 1
        end

        if y >= starty + 100 then
            break
        end

        local p = sim.partCreate(-3, x, y, elem)

        if p and p >= 0 then
            x = x + 1
            count = count + 1
        end
    end

    tpt.log("Usable element IDs found: " .. count)
end

mc = mc or {}
mc = mc or {}

function mc.frames(fps, seconds)
    local frames = tonumber(fps) * tonumber(seconds)
    print("Frames: " .. frames)
end

function mc.noise()
    sim.clearSim()

    local dmnd = tpt.element("DMND")

    for y = 0, sim.YRES - 1 do
        for x = 0, sim.XRES - 1 do
            local p = sim.partCreate(-3, x, y, dmnd)

            if p >= 0 then
                local colour

                if math.random(0, 1) == 0 then
                    colour = 0xFF000000 -- 00 black
                else
                    colour = 0xFFFFFFFF -- FF white
                end

                sim.partProperty(p, "dcolour", colour)
            end
        end
    end
end

function mc.perlin()
    sim.clearSim()

    local dmnd = tpt.element("DMND")
    local scale = 0.035

    -- Random gradient vectors
    local gradients = {}

    local function gradient(ix, iy)
        local key = ix .. "," .. iy

        if not gradients[key] then
            local angle = math.random() * math.pi * 2
            gradients[key] = {
                math.cos(angle),
                math.sin(angle)
            }
        end

        return gradients[key]
    end

    local function fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function dot(gx, gy, x, y)
        return gx * x + gy * y
    end

    local function noise(x, y)
        local x0 = math.floor(x)
        local y0 = math.floor(y)
        local xf = x - x0
        local yf = y - y0

        local g00 = gradient(x0,     y0)
        local g10 = gradient(x0 + 1, y0)
        local g01 = gradient(x0,     y0 + 1)
        local g11 = gradient(x0 + 1, y0 + 1)

        local n00 = dot(g00[1], g00[2], xf,     yf)
        local n10 = dot(g10[1], g10[2], xf - 1, yf)
        local n01 = dot(g01[1], g01[2], xf,     yf - 1)
        local n11 = dot(g11[1], g11[2], xf - 1, yf - 1)

        local u = fade(xf)
        local v = fade(yf)

        local nx0 = lerp(n00, n10, u)
        local nx1 = lerp(n01, n11, u)

        return lerp(nx0, nx1, v)
    end

    for y = 0, sim.YRES - 1 do
        for x = 0, sim.XRES - 1 do
            local value = noise(x * scale, y * scale)

            -- Convert roughly -1..1 into 0..255
            local gray = math.floor((value + 1) * 127.5)

            if gray < 0 then gray = 0 end
            if gray > 255 then gray = 255 end

            local colour =
                0xFF000000 +
                gray * 0x010101

            local p = sim.partCreate(-3, x, y, dmnd)

            if p >= 0 then
                sim.partProperty(p, "dcolour", colour)
            end
        end
    end
end

print("Loaded MoreCommands by LogikDOS. No errors")