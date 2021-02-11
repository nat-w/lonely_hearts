-- constants
-- define the tile size
CELLSIZE = 16
-- sprites must be exported at the same scale as defined here
SCALE = 1
-- size of the width and length of the level
LEVELSIZE = 10
-- how many obstacles to add
OBSTACLES = 0

function makeLevel(width, height, obstacles)
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
    pinkSprite = love.graphics.newImage("pink.png")
    blueSprite = love.graphics.newImage("blue.png")
    -- winAnim = love.graphics.newImage("win.png")

    -- set the cell size based on constants
    cellSize = CELLSIZE * SCALE

    -- separate tileset into individual tiles
    quads = {}
    for y = 0, 2 do
        for x = 0, 1 do
            table.insert(quads,love.graphics.newQuad(x * cellSize, y * cellSize, cellSize, cellSize, tileset:getWidth(), tileset:getHeight()))
        end
    end

    love.graphics.setBackgroundColor(1, 1, .75)

    -- set the starting positions of the players
    blueX = 2
    blueY = 2
    pinkX = 8
    pinkY = 8

    -- make the level
    level = makeLevel(LEVELSIZE, LEVELSIZE, OBSTACLES)
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

        local blueNext = level[blueY + dy][blueX + dx]
        local pinkNext = level[pinkY - dy][pinkX - dx]

        -- check if space clear then move
        if (blueNext ~= pinkX or blueNext ~= pinkY) and blueNext ~= 1 and blueNext ~= 2 then
            blueX = blueX + dx
            blueY = blueY + dy
        end
        if (pinkNext ~= blueX or pinkNext ~= blueY) and pinkNext ~= 1 and pinkNext ~= 2 then
            pinkX = pinkX - dx
            pinkY = pinkY - dy
        end
    end
end

function love.draw()
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            -- draw map tile
            love.graphics.draw(tileset, quads[cell], x * cellSize, y * cellSize)

            -- draw player
            -- y - 2 because sprites are 18 pixels tall, not 16
            if x == blueX and y == blueY then
                -- flip sprite if past middle
                if blueX > then
                else
                    love.graphics.draw(blueSprite, x * cellSize, y * cellSize -2)
                end
            elseif x == pinkX and y == pinkY then
                love.graphics.draw(pinkSprite, x * cellSize, y * cellSize -2)
            end
        end
    end
end