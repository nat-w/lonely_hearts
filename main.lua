-- constants
-- define the tile size
CELLSIZE = 16
-- sprites must be exported with their original name and scale as defined below
-- and put in a folder named 'scale'x ie. 1x, 5x etc.
SCALE = 3
-- size of the width and length of the level
LEVELSIZE = 10
-- how many obstacles to add
OBSTACLES = 0
ANIMSPEED = 1

function makeTiles(tileset, cols, rows)
    quads = {}
    for y = 0, cols do
        for x = 0, rows do
            table.insert(quads,love.graphics.newQuad(x * CELLSIZE * SCALE, y * CELLSIZE * SCALE, CELLSIZE * SCALE, CELLSIZE * SCALE, tileset:getWidth(), tileset:getHeight()))
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
    tileset = love.graphics.newImage(tostring(SCALE) .. "x/" .. "loveTiles.png")
    pinkSprite = love.graphics.newImage(tostring(SCALE) .. "x/" .. "pink.png")
    blueSprite = love.graphics.newImage(tostring(SCALE) .. "x/" .. "blue.png")
    winAnim = makeAnim(love.graphics.newImage(tostring(SCALE) .. "x/" .. "win.png"), (CELLSIZE * SCALE) * 2,  (CELLSIZE * SCALE) + (2 * SCALE), 4)
    
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
        if not win and (blueX + dx ~= pinkX or blueY + dy ~= pinkY) and blueNext ~= 1 and blueNext ~= 2 then
            blueX = blueX + dx
            blueY = blueY + dy
        end
        if not win and (pinkX - dx ~= blueX or pinkY - dy ~= blueY) and pinkNext ~= 1 and pinkNext ~= 2 then
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
        winAnim.currentTime = winAnim.currentTime + (dt * ANIMSPEED)
        if winAnim.currentTime >= winAnim.duration then
            winAnim.currentTime = 3
        end
    end
end

function love.draw()
    -- draw map
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            love.graphics.draw(tileset, tiles[cell], x * (CELLSIZE * SCALE), y * (CELLSIZE * SCALE))
        end
    end

    -- draw hug anim if game over
    if win then
        local animX = blueX < pinkX and blueX or pinkX
        local animY = blueY
        local spriteNum = math.floor(winAnim.currentTime / winAnim.duration * #winAnim.quads) + 1
        love.graphics.draw(winAnim.spriteSheet, winAnim.quads[spriteNum], animX * (CELLSIZE * SCALE), animY * (CELLSIZE * SCALE) -2)
    -- draw players
    else
        if blueX > LEVELSIZE / 2 then
            love.graphics.draw(blueSprite, blueX * (CELLSIZE * SCALE), blueY * (CELLSIZE * SCALE) -2, 0, -1, 1)
        else
            love.graphics.draw(blueSprite, blueX * (CELLSIZE * SCALE), blueY * (CELLSIZE * SCALE) -2)
        end

        if pinkX < LEVELSIZE / 2 then
            love.graphics.draw(pinkSprite, pinkX * (CELLSIZE * SCALE), pinkY * (CELLSIZE * SCALE) -2, 0, -1, 1)
        else
            love.graphics.draw(pinkSprite, pinkX * (CELLSIZE * SCALE), pinkY * (CELLSIZE * SCALE) -2)
        end
    end
end