
local stars = require "stars"
local gDirs = { {-3, 1}, {-1, 3}, {3, -1}, {1,-3} }
local gDirIndex = 0
local gState = "move" -- "move" or "interp"
local interpInterval = 1
local moveInterval = 3
local velocity = 8
local gLastStateTime = 0
local gTimeAccum = 0

function drawDiags()

	-- tests to test primitive drawing behaviour in love2d

	local lineLen = 120 
	local pos = {400,300}

	local red = {1,0,0,1}
	local blue = {0,0,1,1}
	local yellow = {1,1,0,1}
	local green = {0,1,0,1}

	for i=0,lineLen-1 do
		if (i % 2 == 0) then love.graphics.points({pos[1] + i, pos[2]}) end
	end

	love.graphics.setColor({0,1,0,1})
	love.graphics.rectangle("fill", pos[1], pos[2] - 5, 40, 4)

	love.graphics.setColor(red)
	love.graphics.rectangle("fill", 20, 20, 100, 100)
	love.graphics.setColor(blue)
	love.graphics.rectangle("fill", 70, 70, 100, 100)

	for line=0,300 do
		love.graphics.setColor(yellow)
		love.graphics.line(line,line*2,line+2,line*2)
		love.graphics.setColor(green)
		for i=0,lineLen-1 do
			if (i % 2 == 0) then love.graphics.points(line + i, line*2+1) end
		end
	end
end


function love.load()
	local w, h = love.graphics.getDimensions()
	stars.loadStarLayers("stars.png", w, h)
	gLastStateTime = 0
end

function love.update(dt)
	gTimeAccum = gTimeAccum + dt
	local now = gTimeAccum

	-- first time only
	if gLastStateTime == 0 then
		gLastStateTime = now
		stars.setVelocity(gDirs[gDirIndex+1], velocity)
	end

	local time = now - gLastStateTime
	if gState == "interp" then
		local weight = math.min(time / interpInterval, 1) -- normalize to 1
	
		-- apply direction
		
		local oldIndex = gDirIndex
		local newIndex = (gDirIndex+1) % (#gDirs)

		local x1, y1 = gDirs[oldIndex+1][1], gDirs[oldIndex+1][2]
		local x2, y2 = gDirs[newIndex+1][1], gDirs[newIndex+1][2]
		local x = x1 * (1-weight) + x2 * weight
		local y = y1 * (1-weight) + y2 * weight
		local vel = { x, y }

		stars.setVelocity(vel, velocity)

		print( string.format("interp: %.3f  weight: %.2f", time, weight) )
		print("    (: " .. x1 .. ", " .. y1 .. ")")
		print("    (: " .. x2 .. ", " .. y2 .. ")")
		print( string.format("    %.2f, %.2f", x, y) )
		
		-- are we done?
		if now - gLastStateTime > interpInterval then
			print("STATE change to \"move\"")
			-- Set intended target velocity
			stars.setVelocity(gDirs[newIndex+1], velocity)
			gDirIndex = newIndex
			-- could set gLastStateTime to 'now', but if we've overshot the transition time by
			-- a bit, then we wouldn't be correcting.
			gLastStateTime = gLastStateTime + interpInterval
			gState = "move"			 
		end
	elseif gState == "move" then
		if time > moveInterval then
			print("STATE change to \"interp\"")
			gState = "interp"
			gLastStateTime = gLastStateTime + moveInterval
		end
	end

	stars.update(dt)

end


function love.draw()
	stars.draw()
	--drawDiags()
end


function love.resize(w, h)
	print("Resize to: " .. w .. ", " .. h)
	local dimX, dimY = love.graphics.getDimensions()
	print("getDimensions(): " .. dimX .. ", " .. dimY)
	stars.setDimensions(w,h)
end

