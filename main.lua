-- constants
-- define the tile size
CELLSIZE = 16
-- sprites must be exported with their original name and scale as defined below
-- and put in a folder named 'scale'x ie. 1x, 5x etc.
SCALE = 3
ANIMSPEED = 5
-- singleton for game start, so that assets are only loaded once
startGame = true

-- makes a list of tiles given a tileset and its columns and rows
-- leave no padding or borders in the tileset
function makeTiles(tileset, cols, rows)
    quads = {}
    for y = 0, cols do
        for x = 0, rows do
            table.insert(quads,love.graphics.newQuad(x * CELLSIZE * SCALE, y * CELLSIZE * SCALE, CELLSIZE * SCALE, CELLSIZE * SCALE, tileset:getWidth(), tileset:getHeight()))
        end
    end
    return quads
end

-- takes a spritesheet and creates an animation
-- leave no padding or borders in the spritesheet
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

-- make a square level surrounded by walls with random obstacles
function makeLevel(width, height, obstacles)
    local level = {}
    for y = 1, height do
        table.insert(level, {})
        for x = 1, width do
            -- square is wall
            if y == 1 or y == height or x == 1 or x == width then
                table.insert(level[y], math.random(1, 2))
            -- add obstacle
            elseif obstacles > 0  and math.random(1, width) == 1 then
                table.insert(level[y], math.random(1, 2))
                obstacles = obstacles - 1
            -- square is grass
            else
                table.insert(level[y], math.random(3, 6))
            end
        end
    end
    return level
end

function loadGame()
    -- load sprites and animations
    tileset = love.graphics.newImage(tostring(SCALE) .. "x/" .. "loveTiles.png")
    pinkSprite = love.graphics.newImage(tostring(SCALE) .. "x/" .. "pink.png")
    blueSprite = love.graphics.newImage(tostring(SCALE) .. "x/" .. "blue.png")
    winAnim = makeAnim(love.graphics.newImage(tostring(SCALE) .. "x/" .. "win.png"), (CELLSIZE * SCALE) * 2,  (CELLSIZE * SCALE) + (2 * SCALE), 4)

    -- separate tileset into individual tiles
    tiles = makeTiles(tileset, 2, 1)

    love.graphics.setBackgroundColor(.75, 1, 1)
end

function love.load()
    -- load assets if this is first level
    if startGame then
        loadGame()
        startGame = false
    end

    -- reset random seed
    math.randomseed(os.time()) 

    -- size of the width and length of the level
    levelWidth = math.random(9, 13)
    levelHeight = math.random(9, 13)

    -- how many obstacles to add
    obstacles = math.random(2, 5)

    -- set the starting positions of the players
    midX = math.floor(levelWidth / 2) - 1
    midY = math.floor(levelHeight / 2) - 1
    blueX = math.random(2, midX)
    blueY = math.random(2, midY)
    pinkX = math.random(midX, levelWidth - 1)
    pinkY = math.random(midY, levelHeight - 1)

    -- set up win trigger
    win = false
    -- reset win animation
    winAnim.currentTime = 0

    -- make the level
    level = makeLevel(levelWidth, levelHeight, obstacles)
end

function love.keypressed(key)
    if key == "r" then
        love.load()
    end

    if key == "up" or key == "down" or key == "left" or key == "right" then
        -- find next position based on key press
        local dx = 0
        local dy = 0
        if key == "left" then
            dx = -1
        elseif key == "right" then
            dx = 1
        elseif key == "up" then
            dy = -1
        elseif key == "down" then
            dy = 1
        end

        local blueNext = level[blueY + dy][blueX + dx]
        local pinkNext = level[pinkY - dy][pinkX - dx]

        -- check if space clear, then move
        if not win and (blueX + dx ~= pinkX or blueY + dy ~= pinkY) and blueNext ~= 1 and blueNext ~= 2 then
            blueX = blueX + dx
            blueY = blueY + dy
        end
        if not win and (pinkX - dx ~= blueX or pinkY - dy ~= blueY) and pinkNext ~= 1 and pinkNext ~= 2 then
            pinkX = pinkX - dx
            pinkY = pinkY - dy
        end

        -- check if won after moving
        if (blueY == pinkY) and (blueX + 1 == pinkX or blueX - 1 == pinkX) then
            win = true
        end
    end
end

function love.update(dt)
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
        local animX = blueX
        local animY = blueY
        local spriteNum = math.floor(winAnim.currentTime / winAnim.duration * #winAnim.quads) + 1
        
        if blueX - 1 == pinkX then
            love.graphics.draw(winAnim.spriteSheet, winAnim.quads[spriteNum], (animX + 1) * (CELLSIZE * SCALE), animY * (CELLSIZE * SCALE) -2, 0, -1, 1)
        else
            love.graphics.draw(winAnim.spriteSheet, winAnim.quads[spriteNum], animX * (CELLSIZE * SCALE), animY * (CELLSIZE * SCALE) -2)
        end
    -- draw players
    else
        -- flip player if they pass midpoint
        if blueX > pinkX then
            love.graphics.draw(blueSprite, (blueX + 1) * (CELLSIZE * SCALE), blueY * (CELLSIZE * SCALE) -2, 0, -1, 1)
        else
            love.graphics.draw(blueSprite, blueX * (CELLSIZE * SCALE), blueY * (CELLSIZE * SCALE) -2)
        end

        if blueX > pinkX then
            love.graphics.draw(pinkSprite, (pinkX + 1) * (CELLSIZE * SCALE), pinkY * (CELLSIZE * SCALE) -2, 0, -1, 1)
        else
            love.graphics.draw(pinkSprite, pinkX * (CELLSIZE * SCALE), pinkY * (CELLSIZE * SCALE) -2)
        end
    end
end