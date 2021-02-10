CELL_SIZE = 16
SCALE_FACTOR = 5

function love.load()
    -- load tiles
    tileset = love.graphics.newImage("love_tiles.png")
    local image_width = image:getWidth()
    local image_height = image:getHeight()

    quads = {}

    for i = 0, 2 do
        for j = 0, 1 do
            table.insert(quads, love.graphics.newQuad(1 + j * (width + 2), 1 + i * (height + 2), width, height, image_width, image_height))
        end
    end

    love.graphics.setBackgroundColor(1, 1, .75)

    blue = '@'
    pink = '&'
    wall = '#'
    empty = ' '

    level = {
        {'#', '#', '#', '#', '#', '#', '#', '#'},
        {'#', ' ', ' ', ' ', ' ', ' ', ' ', '#'},
        {'#', ' ', ' ', ' ', ' ', ' ', ' ', '#'},
        {'#', '@', ' ', ' ', ' ', ' ', '&', '#'},
        {'#', ' ', ' ', ' ', ' ', ' ', ' ', '#'},
        {'#', ' ', ' ', ' ', ' ', ' ', ' ', '#'},
        {'#', '#', '#', '#', '#', '#', '#', '#'}
    }

end

function love.keypressed(key)
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        -- get both players positions
        local blueX
        local blueY
        local pinkX
        local pinkY

        for y, row in ipairs(level) do
            for x, cell in ipairs(row) do
                if cell == blue then
                    blueX = x
                    blueY = y
                elseif cell == pink then
                    pinkX = x
                    pinkY = y
                end
            end
        end

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

        -- check if space clear then move
        local blue_next = level[blueY + dy][blueX + dx]
        local pink_next = level[pinkY - dy][pinkX - dx]

        if blue_next == empty then
            level[blueY][blueX] = empty
            level[blueY + dy][blueX + dx] = blue
        end
        if pink_next == empty then
            level[pinkY][pinkX] = empty
            level[pinkY - dy][pinkX - dx] = pink
        end
    end
end

function love.draw()
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            local cell_size = (CELL_SIZE - 1) * SCALE_FACTOR

            local colors = {
                [blue] = {.61, .9, 1},
                [pink] = {1, .58, .82},
                [empty] = {2, 3, 4, 5},
                [wall] = {0, 1}
            }

            love.graphics.setColor(colors[cell])
            love.graphics.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize, cellSize)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(level[y][x], (x - 1) * cellSize, (y - 1) * cellSize)
        end
    end
end