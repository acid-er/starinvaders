
stars = require "stars/stars"

ship_x = 346
ship_y = 600
shipSpeed = 3
shipmove = true
collision = false
collision_x = false
collision_y = false
shooting = false
bullet_x = 0
bullet_y = 0
bullets = {}
scale_a = 0.6
scale_s = 0.8
ship_w = 64 * scale_s
ship_h = 64 * scale_s
alien_w = 58 * scale_a
alien_h = 48 * scale_a
aliens = {}
window_w = 750
bullet_h = 20
bullet_w = 2.5
pause = false
spawn = false
score = 0
nextScoreSpawn = 700
alienBullets = {}
alienshooting = false
drawShip = true
drawThrusters = true
collisionTime = 0
gameOverTime = 0
alienTime = 0
test = false
spawnSet = 0
lives = 3
mode = "titleScreen"
title_x = 100
title_y = 1500
nextBox1 = false
nextBox2 = false
nextBox3 = false
box1_y = 750
box2_y = 750
box3_y = 750
startOptions = false
select_y = 395
select_x = 200
selectMoving_down = false
selectMoving_up = false
alienBulletLimit = 1
gGrid = {}
gDebug = false

gShootSound = love.audio.newSource("sounds/shoot.wav", "static")
gAlienDeath = love.audio.newSource("sounds/alien-death.wav", "static")
gPlayerDeath = love.audio.newSource("sounds/death.wav", "static")
gMenuMove = love.audio.newSource("sounds/menu-move.wav", "static")
gMenuSelect = love.audio.newSource("sounds/menu-select.mp3", "static")
gMenuMove = love.audio.newSource("sounds/menu-move.wav", "static")
gIntroSound = love.audio.newSource("sounds/intro.wav", "static")
gAlienShoot = love.audio.newSource("sounds/alien-shoot.wav", "static")

function max2(x, y)

    if x > y then
        return x
    end

    return y
end


function max3(x, y, z)

    if x > y and x > z then
        return x 
    end

    if y > x and y > z then
        return y 
    end

    if z > x and z > y then
        return z
    end

    return x
end

function max3Papa(x, y, z)
    local max_xy = max2(x,y)
    local max_xyz = max2(max_xy, z)
    return max_xyz
end

function spawnAliens(alienCount, alienType)

    for i = 1, alienCount do
        --print("hello" .. i)
        local spriteNumber = alienType

        if alienType == nil then
            spriteNumber = math.random(1,2)
        end

        --local speedNumber = math.random(2,8)
        local speedNumber = 3

        local newAlien = {}
        newAlien["x"] = -1 * (i * (alien_w + scale_a * 20))
        newAlien["y"] = 500 + i * 0
        newAlien["color"] = color_magenta
        newAlien["sprite"] = alienSprites[spriteNumber]
        newAlien["direction"] = "right"
        newAlien["speed"] = speedNumber + spawnSet 
        newAlien["rnd"] = math.random(1, 1000)
        newAlien["lives"] = 1
        newAlien["id"] = i + 10
        newAlien["mode"] = "free"

        table.insert(aliens, newAlien)
        
        local alienInserted = false
        -- find a free spot in the grid
        for r, row in ipairs (gGrid) do
            
            for c, cell in ipairs(row) do
                
                if cell.alien == nil then
                    cell.alien = newAlien
                    alienInserted = true
                    print("found a spot for alien: " .. newAlien.id)
                    break
                end
            end

            if alienInserted == true then
                break
            end
        end
        
        if alienInserted == false then
            print("did not find a spot for: " .. newAlien.id)
        end
    end

end

function love.load()
    canvas = love.graphics.newCanvas(750, 750)

    -- star background ---------------------------------

    local w,h = love.graphics.getDimensions()
    stars.loadStarLayers("stars.png", w, h)
    stars.setVelocity({0, 3}, 5)

    ------------------------------------------------------------------

    print( max2(5, 7) )
    print( max2(13, 7) )
    print( max2(7, 7) )
    print( "-------" )
    print( max3(13, 6, 15) )
    print( max3(19, 20, 17) )
    print( max3(8, 8, 8) )    
    print( "-------" )
    print( max3Papa(13, 6, 15) )
    print( max3Papa(19, 20, 17) )
    print( max3Papa(8, 8, 8) )    

    --[[for peopleKey,t in pairs(people) do
        print(peopleKey)
        print(t)
        for key,value in pairs(t) do
            print(key .. ", " .. value)
        end
        print("-----")
    end]]--

    -- colors for aliens ---------------------------------

    local color_magenta = {1,0,1} 
    local color_blue = {0,0,1} 
    local color_green = {0,1,0}
    local color_yellow = {1,1,0}

    -- ship animation ---------------------------------

    shipSprite = love.graphics.newImage("ship1.png")
    engine1Sprite = love.graphics.newImage("engine1.png")
    engine2Sprite = love.graphics.newImage("engine2.png")
    engine3Sprite = love.graphics.newImage("engine3.png")

    frames = {}

    table.insert(frames, love.graphics.newImage("engine1.png"))
    table.insert(frames, love.graphics.newImage("engine2.png"))
    table.insert(frames, love.graphics.newImage("engine3.png"))

    currentFrame = 1

    -- title sprites ----------------------------------------

    titleSprite = love.graphics.newImage("title.png")
    startSprite = love.graphics.newImage("start.png")
    controlsSprite = love.graphics.newImage("controls.png")
    optionsSprite = love.graphics.newImage("options.png")
    controllerSprite = love.graphics.newImage("controlermap.png")

    -- loading alien sprites ---------------------------------

    alienSprites = {}
    local alienSprite1 = love.graphics.newImage("alien1.png")
    local alienSprite2 = love.graphics.newImage("alien2.png")
    local alienSprite3 = love.graphics.newImage("alien3.png")

    table.insert(alienSprites, alienSprite1)
    table.insert(alienSprites, alienSprite2)
    table.insert(alienSprites, alienSprite3)

   -- spawnAliens(8, math.random(1,3))


    -- alien lists ---------------------------------

 --[[   alien1 = {}
    alien1["x"] = 800
    alien1["y"] = 100
    alien1["color"] = color_magenta
    alien1["sprite"] = alienSprite1
    alien1["direction"] = "left"
    alien1["speed"] = 2

    alien2 = {}
    alien2["x"] = 0 - alien_w
    alien2["y"] = 200
    alien2["color"] = color_blue
    alien2["sprite"] = alienSprite2
    alien2["direction"] = "right"
    alien2["speed"] = 4

    alien3 = {}
    alien3["x"] = 800
    alien3["y"] = 300
    alien3["color"] = color_green
    alien3["sprite"] = alienSprite1
    alien3["direction"] = "left"
    alien3["speed"] = 6
 
    alien4 = {}
    alien4["x"] = 0 - alien_w
    alien4["y"] = 400
    alien4["color"] = color_yellow
    alien4["sprite"] = alienSprite1
    alien4["direction"] = "right"
    alien4["speed"] = 8 

    aliens[1] = alien1
    aliens[2] = alien2
    aliens[3] = alien3
    aliens[4] = alien4 ]]--

    nextIncreaseTime = os.time() + 60

end


function isCollision2(x1, y1, w1, h1, x2, y2, w2, h2)

    -- collision formula -----------------------------------

    local collision_x = false
    local collision_y = false

    if x1 > x2 and x1 < x2 + w2 or 
        x2 > x1 and x2 < x1 + w1 then
        collision_x = true
    end

    if y1 > y2 and y1 < y2 + h2 or 
        y2 > y1 and y2 < y1 + h1 then
        collision_y = true
    end

    if collision_x == true and collision_y == true then
        return true
    else
        return false
    end

--[[

    if dist_x < maxWidth and dist_y < maxHeight then
        print("collision!")
        print("   x1,y1,w1,h1: " .. x1 .. "," .. y1 .. "," .. w1 .. "," .. h1)
        print("   x2,y2,w2,h2: " .. x2 .. "," .. y2 .. "," .. w2 .. "," .. h2)
        print("   maxWidth: " .. maxWidth)
        print("   maxHeight: " .. maxHeight)
        print("   dist_x: " .. dist_x)        
        print("   dist_y: " .. dist_y)
        return true
    else
        return false
    end

]]--

end

function gameStarted()

    gGrid = {}
    gGrid["x"] = 50
    gGrid["y"] = 100

    gGrid["rows"] = 4
    gGrid["cols"] = 10
    gGrid["cellH"] = 50
    gGrid["cellW"] = 50
    gGrid["direction"] = "right"
    gGrid['cellW_min'] = gGrid.cellW
    gGrid['cellW_max'] = gGrid.cellW * 2
    gGrid['cellH_min'] = gGrid.cellH
    gGrid['cellH_max'] = gGrid.cellH * 2
    gGrid['mode'] = "expand"

    for r = 1, gGrid.rows do 
        local row = {}

        for c = 1, gGrid.cols do

            local cell = {}
            cell["name"] = c .. "," .. r
            cell["alien"] = nil
            row[c] = cell

        end
        
        gGrid[r] = row
        --table.insert(gGrid, row)

    end

    for r, row in ipairs(gGrid) do

        print("row number: " .. r)

        for c, cell in ipairs(row) do
            print("contents of table: " .. cell.name)
        end

    end

    if #aliens <= gGrid.rows * gGrid.cols - gGrid.cols then
        spawnAliens(gGrid["cols"], math.random (1, 3))
        nextAlienTime = os.time() + 5
    end

end

function updateAliensSnake()

    for alienKey, alien in pairs(aliens) do
        local x = alien["x"]
        local y = alien["y"]
        local direction = alien["direction"]
        local speed = alien["speed"]
        
        if direction == "left" then
            x = x - speed
        end
           
        if direction == "right" then 
            x = x + speed
        end

        if direction == "down" then
            y = y + speed
        end

        if direction == "left" and x <= 100 then
            alien["target"] = y + 64
            direction = "down"
            x = 100
        end

        if direction == "right" and x >= window_w - 158 and y < 366 then
            alien["target"] = y + 64
            direction = "down" 
            x = window_w - 158
        end

        if direction == "down"  and y >= alien["target"] and x <= 100 then 
            direction = "right"
        end 

        if direction == "down" and y >= alien["target"] and x >= window_w - 158 then
            direction = "left"
        end

        if x > 750 then
            table.remove(aliens, alienKey)
        end

        alien["x"] = x
        alien["direction"] = direction
        alien["y"] = y

    end

end

function updateAliensGalaga()

end

function love.keypressed(key, isrepeat)

    print(key)
    print(isrepeat)

    if isrepeat == true then
        return
    end

    if key == "d" then
        gDebug = not gDebug
    end

end

function love.update(dt)

    stars.update(dt)
    local currentTime = os.time()

    if mode == "controlScreen" then
        print ("screen")

        if love.keyboard.isDown("escape") then
            love.audio.stop(gMenuMove)
            love.audio.play(gMenuMove)
            mode = "titleScreen"
        end

    end

    if mode == "titleScreen" then

        love.audio.play(gIntroSound)

        if love.keyboard.isDown("rshift") then
            mode = "gameScreen"
            gameStarted()
        end

        alienBulletLimit = 1
        spawnSet = 0
        lives = 3
        score = 0 

        --print ("hello")

        -- moving title screen boxes --------------------------------------------

        title_y = title_y - 5

        if title_y < 100 then
            title_y = 100
            nextBox1 = true
        end

        if nextBox1 == true then
            box1_y = box1_y - 6
        end

        if nextBox2 == true then
            box2_y = box2_y - 6
        end

        -- if nextBox3 == true then
        --     box3_y = box3_y - 6
        -- end

        if box1_y < 380 then
            box1_y = 380
            nextBox2 = true
        end

        if box2_y < 485 then
            box2_y = 485
            nextBox3 = true
        end

        if box3_y < 590 then
            box3_y = 590
            startOptions = true
        end

        -- option select -----------------------------------------------

        if love.keyboard.isDown("down") and selectMoving_down == false and nextBox3 == true then
            selectMoving_down = true
            select_y = select_y + 500
            love.audio.stop(gMenuMove)
            love.audio.play(gMenuMove)
        end

        if love.keyboard.isDown("up") and selectMoving_up == false and nextBox3 == true then
            selectMoving_up = true
            select_y = select_y - 500
            love.audio.stop(gMenuMove)
            love.audio.play(gMenuMove)
        end
            
        if love.keyboard.isDown("down") == false then
            selectMoving_down = false
        end

        if love.keyboard.isDown("up") == false then
            selectMoving_up = false
        end

        if select_y >= 500 then
            select_x = 150
            select_y = 500
        end

        if select_y <= 395 then
            select_x = 200
            select_y = 395
        end

        -- selecting -------------------------------

        if select_y == 395 and love.keyboard.isDown("return") and nextBox3 == true then
            love.audio.stop(gMenuSelect)
            love.audio.play(gMenuSelect)
            mode = "gameScreen"
            gameStarted()
        end

        if select_y == 500 and love.keyboard.isDown("return") and nextBox3 == true then
            love.audio.stop(gMenuSelect)
            love.audio.play(gMenuSelect)
            mode = "controlScreen"
        end

    end


    if mode == "gameScreen" then

        -- if gGrid.mode == 'expand' then
        --     gGrid.cellW = gGrid.cellW + 0.5
        --     gGrid.cellH = gGrid.cellH + 0.5
        -- end

        -- if gGrid.mode == 'decrease' then
        --     gGrid.cellW = gGrid.cellW - 0.5
        --     gGrid.cellH = gGrid.cellH - 0.5
        -- end

        -- if gGrid.cellW >= gGrid.cellW_max then
        --     gGrid.mode = 'decrease'
        -- end

        -- if gGrid.cellW <= gGrid.cellW_min then
        --     gGrid.mode = 'expand'
        -- end

        -- if gGrid.cellH >= gGrid.cellH_max then
        --     gGrid.mode = 'decrease'
        -- end

        -- if gGrid.cellH <= gGrid.cellH_min then
        --     gGrid.mode = 'expand'
        -- end


        if gGrid['direction'] == "right" then 
            gGrid['x'] = gGrid['x'] + 2
        elseif 
            gGrid['direction'] == 'left' then
            gGrid['x'] = gGrid["x"] - 2
        end

        if gGrid['x'] + gGrid['cols'] * gGrid['cellW'] >= 700 then 
            gGrid["direction"] = "left"
        elseif
            gGrid['x'] <= 50 then
            gGrid['direction'] = "right"
        end



        -- update stars ---------------------------------

        if love.keyboard.isDown("p") then 
            pause = true
        end

        if love.keyboard.isDown("o") then
            pause = false
        end

        if pause == false then
            
           -- spawning new aliens every n points ---------------------------------

            -- if score == nextScoreSpawn then
            --     local alienN = math.random(1,3)
            --     spawnAliens(8, alienN)
            --     nextScoreSpawn = nextScoreSpawn + 700
            -- end

            shipTurbo = false
          --  shipmove = false
            currentFrame = currentFrame + 3 * dt

            -- manual spawn aliens ---------------------------------

            if love.keyboard.isDown("s") and spawn == false then  
                spawn = true
                spawnAliens(gGrid["cols"])
            end

            if love.keyboard.isDown("s") == false then
                spawn = false
            end

            -- ship animation update ---------------------------------

            if currentFrame >= 4 then
                currentFrame = 1
            end

            -- turbo test ---------------------------------

            if love.keyboard.isDown("z") then
                shipTurbo = true
            else
                shipTurbo = false
            end

            if shipTurbo == true then
                shipSpeed = 5
            end

            if shipTurbo == false then
                shipSpeed = 3
            end

            -- shooting ---------------------------------

            if love.keyboard.isDown("space") and shooting == false and #bullets < 1 then

                shooting = true

                love.audio.stop(gShootSound) 
                love.audio.play(gShootSound)

                local bullet = {}
                bullet["x"] = ship_x + ship_w/2
                bullet["y"] = ship_y - 25

                table.insert(bullets, bullet)

            end

            -- alien shooting ---------------------------------

            for alienKey, alien in pairs(aliens) do 
                local rnd = math.random(1,10000)

                if rnd < 30 and #alienBullets < alienBulletLimit then

                    alienshooting = true

                    love.audio.stop(gAlienShoot)
                    love.audio.play(gAlienShoot)

                    local alienBullet = {}

                    alienBullet["x"] = alien["x"]
                    alienBullet["y"] = alien["y"]
                    table.insert(alienBullets, alienBullet)

                end

                if rnd > 100 then
                    alienshooting = false
                end

            end

            if love.keyboard.isDown("space") == false then
                shooting = false
            end

            -- movement ---------------------------------

            if love.keyboard.isDown("left") then
                ship_x = ship_x - shipSpeed
            end

            if love.keyboard.isDown("right") then
                ship_x = ship_x + shipSpeed
            end
    --[[
            if love.keyboard.isDown("up") then
                ship_y = ship_y - shipSpeed
            end

            if love.keyboard.isDown("down") then
                ship_y = ship_y + shipSpeed
            end ]]--

          --[[  if love.keyboard.isDown("left") or 
                love.keyboard.isDown("right") or
                love.keyboard.isDown("up") or
                love.keyboard.isDown("down") then
                shipmove = true
            else
                shipmove = false
            end ]]--

            -- moving aliens ---------------------------------

           -- updateAliensSnake()


            for r, row in ipairs(gGrid) do 

                for c, cell in ipairs(row) do 

                    if cell.alien ~= nil then

                        if cell.alien.mode == "grid" then
                            local alien = cell.alien
                            alien.x = gGrid.x + (c - 1) * gGrid.cellW + gGrid.cellW/2 - alien_w/2
                            alien.y = gGrid.y + (r - 1) * gGrid.cellH + gGrid.cellH/2 - alien_h/2
                        elseif cell.alien.mode == 'free' then
                            local x_target = gGrid.x + (c - 1) * gGrid.cellW + gGrid.cellW/2 - alien_w/2
                            local y_target = gGrid.y + (r - 1) * gGrid.cellH + gGrid.cellH/2 - alien_h/2
                            local alien_distX = x_target - cell.alien.x
                            local alien_distY = y_target - cell.alien.y 

                            local distance_squared = alien_distX * alien_distX + alien_distY * alien_distY
                            local distance = math.sqrt(distance_squared)

                            -- print("alien_x: " .. cell.alien.x)
                            -- print("alien_y: " .. cell.alien.y)

                            local alienSpeed = 4

                            if distance <= alienSpeed then
                                cell.alien.mode = "grid"
                            else

                                local distanceRatio = alienSpeed/distance
                                local move_x = distanceRatio * alien_distX
                                local move_y = distanceRatio * alien_distY

                                -- print("Ratio: " .. distanceRatio)
                                -- print("alien_distX: " .. alien_distX)
                                -- print("alien_distY: " .. alien_distY)

                                cell.alien.x = cell.alien.x + move_x
                                cell.alien.y = cell.alien.y + move_y
                            end
                        end
                    end
                end
            end

            -- preventing from going out of bounds ---------------------------------

            if ship_x < 100 then
                ship_x = 100
            end

            if ship_y < 0 then
                ship_y = 0
            end

            if ship_x > 592 then
                ship_x = 592
            end

            if ship_y > 654 then
                ship_y = 654
            end

            -- bullet collision ---------------------------------

            for bulletKey,bullet in pairs(bullets) do
                local x = bullet["x"]
                local y = bullet["y"]

                for alienKey, alien in pairs(aliens) do 
                    print("Alien " .. alienKey)
                    local a_x = alien["x"]
                    local a_y = alien["y"]
                    local lives = alien["lives"]
                    local isTouching = isCollision2(x, y, bullet_w, bullet_h, a_x, a_y, alien_w, alien_h)


                    if isTouching then

                        love.audio.stop(gAlienDeath)
                        love.audio.play(gAlienDeath)

                        print("HIT ALIEN " .. alienKey)
                        table.remove(bullets, bulletKey)
                        lives = lives - 1
                        alien["lives"] = lives

                        print("Removing item #" .. alienKey .. " in list")

                        if lives <= 0 then
                            
                            table.remove(aliens, alienKey)
                            score = score + 100

                            for r, row in ipairs(gGrid) do

                                for c,cell in ipairs(row) do

                                    if alien == cell.alien then
                                        cell.alien = nil
                                    end

                                end
                            end
                        end                    
                    end
                end
            end

            

            -- bullet movement ---------------------------------

            for bulletKey,bullet in pairs(bullets) do
                local y = bullet["y"]
                y = y - 18 
                bullet["y"] = y
            end

            -- deleting when bullet out of bounds ---------------------------------

            for bulletKey,bullet in pairs(bullets) do
                local y = bullet["y"]

                if y < 0 then
                    table.remove(bullets, bulletKey)
                end

            end

            -- alien bullet movement ---------------------------------

            for alienBulletKey, alienBullet in pairs(alienBullets) do
                local y = alienBullet["y"]
                y = y + 7
                alienBullet["y"] = y 
            end

            -- removing alien bullets ---------------------------------

            for alienBulletKey, alienBullet in pairs(alienBullets) do 
                local y = alienBullet["y"]

                if y > 750 then
                    table.remove(alienBullets, alienBulletKey)
                end
            end

        end

            for alienBulletKey, alienBullet in pairs(alienBullets) do
                local x = alienBullet["x"]
                local y = alienBullet["y"]
                isTouching = isCollision2(x, y, bullet_w, bullet_h, ship_x, ship_y, ship_w, ship_h)

                if isTouching then

                    love.audio.stop(gPlayerDeath)
                    love.audio.play(gPlayerDeath)

                    drawShip = false
                    drawThrusters = false
                    collisionTime = os.time()
                    pause = true
                    test = true
                    lives = lives - 1

                    for bulletKey, bullet in pairs(bullets) do      
                        table.remove(bullets, bulletKey)                   
                    end          

                end

                if test == true then
                    table.remove(alienBullets, alienBulletKey)
                end 

            end

            if #aliens == 0 and alienTime == 0 then
                -- local alienN = math.random(1,3)
                -- spawnAliens(8, alienN)
                alienTime = os.time()
            end

            if currentTime - collisionTime > 2 then
                drawShip = true
                drawThrusters = true
                pause = false
            end

            if currentTime > nextIncreaseTime then
                spawnSet = spawnSet + 1
                alienBulletLimit = alienBulletLimit + 1 
                nextIncreaseTime = nextIncreaseTime + 60
                print ("nextIncreaseTime: " .. nextIncreaseTime)
                print ("currentTime: " ..  currentTime)
            end

            if #aliens <= gGrid.rows * gGrid.cols - gGrid.cols then

                if currentTime > nextAlienTime then
                    spawnAliens(gGrid['cols'], math.random(1,3)) 
                    nextAlienTime = nextAlienTime + 5
                end

            end

            if alienBulletLimit > 4 then 
                alienBulletLimit = 4
            end

            if spawnSet > 3 then
                spawnSet = 3
            end

            if currentTime - collisionTime > 3 then
                test = false
            end

            if currentTime > alienTime then
                alienTime = alienTime + 10
                alienTime = alienTime + 10
            end

            if lives == 0 then
                mode = "gameOver"
                gameOverTime = os.time()
            end
    end

    if mode == "gameOver" then

        if currentTime - gameOverTime > 5 then
            mode = "titleScreen"
        end
    end

    for alienkey, alien in pairs(aliens) do

        if mode == "titleScreen" or mode == "gameOver" then
            table.remove(aliens, alienkey)
        end
    end

end

    -- printing a boolean ---------------------------------

function booleanToString(b)

    if(b == true) then return "true"
    else return "false"
    end

end

function love.draw()

    love.graphics.setCanvas(canvas)

    love.graphics.clear(0, 0, 0)

    stars.draw()

    if mode == "controlScreen" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(controllerSprite, 10, 0)
    end

    if mode == "gameOver" then
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", 0, 0, 750, 750)
    end

    if mode == "titleScreen" then
        print (hello1)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(titleSprite, title_x, title_y)
        love.graphics.draw(startSprite, 265, box1_y)
        love.graphics.draw(controlsSprite, 225, box2_y)
        love.graphics.rectangle("fill", 325, box3_y, 100, 50)

        if nextBox3 == true then
            love.graphics.draw(optionsSprite, select_x, select_y)
        end

    end

    if mode == "gameScreen" then

        love.audio.stop(gIntroSound)

    if gDebug == true then

        local rows = gGrid["rows"]
        local cols = gGrid["cols"]

        local cellH = gGrid["cellH"]
        local cellW = gGrid["cellW"]

        love.graphics.setColor(0.5,0.5,0.5)
        --love.graphics.rectangle("line", gGrid["x"], gGrid["y"], 700, 300)

        for i = 0, cols do
            love.graphics.line(i * cellW + gGrid["x"], gGrid["y"], i * cellW + gGrid["x"], gGrid["y"] + rows * cellH)
        end

        for i = 0, rows do
            love.graphics.line(gGrid['x'], i * cellH + gGrid["y"], gGrid["x"] + cellW * cols, i * cellH + gGrid["y"] )
        end

        for r, row in ipairs(gGrid) do 

            for c, cell in ipairs(row) do

                if cell.alien ~= nil then

                    love.graphics.setColor(1,0,0, 0.5)
                    love.graphics.rectangle("fill", gGrid.x + (c - 1) * cellW, gGrid.y + (r - 1) * cellH, cellW, cellH)
                    
                end
            end
        end

        love.graphics.setColor(1,1,1,1)

    end


        local color_red = {1,0,0}
        local color_white = {1,1,1}
        love.graphics.setColor(color_white)

        -- set the color red if colliding ---------------------------------

        if collision == true then 
            love.graphics.setColor(1, 0, 0)
        end

        -- ship and alien collision ---------------------------------

        for alienKey,alien in pairs(aliens) do
           local x = alien["x"]
           local y = alien["y"]
           local isTouching = isCollision2(ship_x, ship_y, ship_w, ship_h, x, y, alien_w, alien_h)

            -- changing color when colliding + drawing aliens ---------------------------------

            love.graphics.setColor(1,1,1)
            love.graphics.draw(alien["sprite"], x, y, --[[math.rad(180)]] 0, scale_a, scale_a)
            love.graphics.setColor(0,1,0)
            --love.graphics.print(alien["lives"], x, y)
            --love.graphics.print(alienKey, x, y)
            --love.graphics.print(alien["id"], x, y+15)
            love.graphics.setColor(1,1,1)

            if isTouching then 
                love.graphics.setColor(1,0,0)
            else
               local color = alien["color"]

                if color == nil then
                    love.graphics.setColor(0.5,0.5,0.5)
                else
                    love.graphics.setColor(color)
                end
            end

            --love.graphics.rectangle("line", x, y, ship_w, ship_h)

        end

        -- drawing bullets ---------------------------------

        for bulletKey,bullet in pairs(bullets) do
            local x = bullet["x"]
            local y = bullet["y"]
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("fill", x, y, bullet_w, bullet_h)
        end

        -- drawing alien bullets ---------------------------------

        for alienBulletKey, alienBullet in pairs(alienBullets) do
            local x = alienBullet["x"]
            local y = alienBullet["y"]
            love.graphics.setColor(1,0,0)

            for alienKey, alien in pairs(aliens) do
                local spriteNumber = alien["sprite"]
                love.graphics.rectangle("fill", x, y, bullet_w, bullet_h)
            end

        end

        -- reset color to white ---------------------------------

        love.graphics.setColor(1, 1, 1)

        -- drawing the ship ---------------------------------

        if drawShip == true and lives > 0 then
            love.graphics.draw(shipSprite, ship_x, ship_y, 0, scale_s, scale_s)
        end

        if lives >= 1 then
            love.graphics.draw(shipSprite, 20, 690, 0, 0.5, 0.5)
        end

        if lives >= 2 then
            love.graphics.draw(shipSprite, 60, 690, 0, 0.5, 0.5)
        end

        if lives >= 3 then
            love.graphics.draw(shipSprite, 100, 690, 0, 0.5, 0.5)
        end

        love.graphics.print ("score:" .. score, 20, 660)

        -- drawing the thrusters ---------------------------------

        if shipmove == true and drawThrusters == true then
            local sprite = frames[math.floor(currentFrame)]
            love.graphics.draw(sprite, ship_x, ship_y, 0, scale_s, scale_s)
        end

        -- starting position of ship ---------------------------------

        -- love.graphics.print (ship_x, 5, 5)
        -- love.graphics.print (ship_y, 5, 20)
        
        -- printing variables ---------------------------------

        -- love.graphics.print ("shooting: " .. booleanToString(shooting), 5, 50)
        -- love.graphics.print ("number of bullets:  " .. #bullets, 5, 35)
        -- love.graphics.print ("number of alien bullets " .. #alienBullets, 5, 75)
        -- love.graphics.print ("drawShip: " .. booleanToString(drawShip), 5, 100)
        -- love.graphics.print ("gameStartTime: " .. spawnSet, 5, 115)
        -- love.graphics.print ("lives: " .. lives, 5, 145)
        -- love.graphics.print ("spawnSet: " .. spawnSet, 5, 205)

        -- if #aliens > 0 then
        --     love.graphics.print ("alien y: " .. aliens[1]["y"], 5, 130)
        --     love.graphics.print ("alien x: " .. aliens[1]["x"], 5, 300)

        if gDebug == true then
            love.graphics.print("Grid x: " .. gGrid.x, 5, 15)
            love.graphics.print("Grid y: " .. gGrid.y, 5, 30)
            love.graphics.print("Cell width: " .. gGrid.cellW, 5, 45)
            love.graphics.print("Cell height: " .. gGrid.cellH, 5, 60)
        end
    end -- gamescreen

    love.graphics.setCanvas()
    local width, height = love.graphics.getDimensions()

    --love.graphics.clear(0,1,0,1)

    local scale

    if width > height then
        scale = height/750
        love.graphics.draw(canvas, (width - 750 * scale)/2 , 0, 0, scale, scale)
    else
        scale = width/750
        love.graphics.draw(canvas, 0, (height - 750 * scale)/2, 0, scale, scale)
    end  

end

