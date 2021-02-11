-- constants
-- define the tile size
CELLSIZE = 16
-- sprites must be exported at the same scale as defined here
SCALE = 1
-- size of the width and length of the level
LEVELSIZE = 10
-- how many obstacles to add
OBSTACLES = 0

function makeTiles(tileset, cols, rows)
    quads = {}
    for y = 0, cols do
        for x = 0, rows do
            table.insert(quads,love.graphics.newQuad(x * cellSize, y * cellSize, cellSize, cellSize, tileset:getWidth(), tileset:getHeight()))
        end
    end
    return quads
end

function makeAnim(image, width, height, frames)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    animation.duration = frames or 1
    animation.currentTime = 0
    return animation
end

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
    winAnim = makeAnim(love.graphics.newImage("win.png"), CELLSIZE * 2, CELLSIZE + 2, 4)

    -- set the cell size based on constants
    cellSize = CELLSIZE * SCALE

    -- separate tileset into individual tiles
    tiles = makeTiles(tileset, 2, 1)

    love.graphics.setBackgroundColor(.75, 1, 1)

    -- set the starting positions of the players
    blueX = 2
    blueY = 2
    pinkX = 8
    pinkY = 8

    -- set up win trigger
    win = false

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
        if (blueX + dx ~= pinkX or blueY + dy ~= pinkY) and blueNext ~= 1 and blueNext ~= 2 then
            blueX = blueX + dx
            blueY = blueY + dy
        end
        if (pinkX - dx ~= blueX or pinkY - dy ~= blueY) and pinkNext ~= 1 and pinkNext ~= 2 then
            pinkX = pinkX - dx
            pinkY = pinkY - dy
        end
    end
end

function love.update(dt)
    -- check if won
    if (blueY == pinkY) and (blueX + 1 == pinkX or blueX - 1 == pinkX) then
        win = true
    end

    if win then
        winAnim.currentTime = winAnim.currentTime + dt
        if winAnim.currentTime >= winAnim.duration then
            winAnim.currentTime = winAnim.currentTime - winAnim.duration
        end
    end
end

function love.draw()
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            -- draw map tile
            love.graphics.draw(tileset, tiles[cell], x * cellSize, y * cellSize)

            -- draw player
            -- y - 2 because sprites are 18 pixels tall, not 16
            if x == blueX and y == blueY then
                -- flip sprite if past middle
                if blueX > LEVELSIZE / 2 then
                    love.graphics.draw(blueSprite, x * cellSize, y * cellSize -2, 0, -1, 1)
                else
                    love.graphics.draw(blueSprite, x * cellSize, y * cellSize -2)
                end
            elseif x == pinkX and y == pinkY then
                if pinkX < LEVELSIZE / 2 then
                    love.graphics.draw(pinkSprite, x * cellSize, y * cellSize -2, 0, -1, 1)
                else
                    love.graphics.draw(pinkSprite, x * cellSize, y * cellSize -2)
                end
            end
        end
    end

    -- anim test
    if win then
        local spriteNum = math.floor(winAnim.currentTime / winAnim.duration * #winAnim.quads) + 1
        love.graphics.draw(winAnim.spriteSheet, winAnim.quads[spriteNum], 0, 0)
    end
end