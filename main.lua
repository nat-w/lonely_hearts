function makeLevel(width, height)
    local level = {}
    for y = 1, height do
        table.insert(level, {})
        for x = 1, width do
            -- square is wall
            if y == 1 or y == height or x == 1 or x == width then
                table.insert(level[y], math.random(1, 2))

            -- square is grass
            else
                table.insert(level[y], math.random(3, 6))
            end
        end
    end
    return level
end

function love.load()
    -- load sprites
    tileset = love.graphics.newImage("love_tiles.png")
    local image_width = tileset:getWidth()
    local image_height = tileset:getHeight()

    cellSize = 16

    -- separate tileset into individual tiles
    quads = {}

    for y = 0, 2 do
        for x = 0, 1 do
            table.insert(quads, love.graphics.newQuad(x * cellSize, y * cellSize, cellSize, cellSize, image_width, image_height))
        end
    end

    love.graphics.setBackgroundColor(1, 1, .75)

    blueX = 2
    blueY = 2
    pinkX = 6
    pinkY = 6

    level = makeLevel(8, 8)
end

function love.keypressed(key)
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        -- find next position based on key press
        local dx = 0
        local dy = 0
        if key == 'left' then
            dx = -1
        elseif key == 'right' then
            dx = 1
        elseif key == 'up' then
            dy = -1
        elseif key == 'down' then
            dy = 1
        end

        local blue_next = level[blueY + dy][blueX + dx]
        local pink_next = level[pinkY - dy][pinkX - dx]

        -- check if space clear then move
        if (blue_next ~= pinkX or blue_next ~= pinkY) and blue_next ~= 1 and blue_next ~= 2 then
            blueX = blueX + dx
            blueY = blueY + dy
        end
        if (pink_next ~= blueX or pink_next ~= blueY) and pink_next ~= 1 and pink_next ~= 2 then
            pinkX = pinkX - dx
            pinkY = pinkY - dy
        end
    end
end

function love.draw()
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            if x == blueX and y == blueY then
                love.graphics.setColor({.61, .9, 1})
                love.graphics.rectangle('fill', x * cellSize, y * cellSize, cellSize, cellSize)
                love.graphics.setColor(1, 1, 1)
            elseif x == pinkX and y == pinkY then
                love.graphics.setColor({1, .58, .82})
                love.graphics.rectangle('fill', x * cellSize, y * cellSize, cellSize, cellSize)
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.draw(tileset, quads[cell], x * cellSize, y * cellSize)
            end
        end
    end
end