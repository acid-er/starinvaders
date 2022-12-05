
local starLayers = {}

local viewX = 1
local viewY = 1

local gDirVec = {-3, 1}
local gSpeedModulation = 1.0

local shootingStars = {}
local nextStarSpawnAttempt = 0
local starSpawnInterval = {1, 7}

local gSpeed = 7

local function getStarSpawnTimeOffset()
	local val = math.random(starSpawnInterval[1], starSpawnInterval[2])	
	print("getStarSpawnTimeOffset: " .. val)
	return val
end

-- TODO: put this function in a collision utility
function bbIntersect( bb1, bb2 )

	--print("bb1:")
	--print("  center: " .. bb1.center[1] .. "," .. bb1.center[2])
	--print("   halfs: " .. bb1.halfs[1] .. "," .. bb1.halfs[2])
	--print("bb2:")
	--print("  center: " .. bb2.center[1] .. "," .. bb2.center[2])
	--print("   halfs: " .. bb2.halfs[1] .. "," .. bb2.halfs[2])

	local distX = math.abs(bb1.center[1] - bb2.center[1])
	local distY = math.abs(bb1.center[2] - bb2.center[2])

	local maxDistX = bb1.halfs[1] + bb2.halfs[1]
	local maxDistY = bb1.halfs[2] + bb2.halfs[2]

	--print("distX: " .. distX .. " maxDistX: " .. maxDistX)
	--print("distY: " .. distY .. " maxDistY: " .. maxDistY)
	if(distX <= maxDistX and distY <= maxDistY) then
		--print("intersect")
		return true
	end

	--print("NOT intersect")
	return false
end


local function updateBoundingBox(ss)
	
	-- set bounding box for this shooting star
	-- What is the top left point?
	-- TODO: store BB with center and w/h for easy update
	local ssPos = ss.pos
	local dir = ss.dir
	local trailLen = ss.trailLen
	local x1 = ssPos[1]
	local y1 = ssPos[2]
	local x2 = ssPos[1] + trailLen * dir[1] * (-1)
	local y2 = ssPos[2] + trailLen * dir[2] * (-1)

	local tmp
	if(x1 > x2) then
		tmp = x1
		x1 = x2
		x2 = tmp
	end
	if(y1 > y2) then
		tmp = y1
		y1 = y2
		y2 = tmp
	end

	ss.bb = {
		x1 = x1, y1 = y1, x2 = x2, y2 = y2,
		center = {(x1+x2)/2, (y1+y2)/2},
		halfs = {(x2-x1)/2, (y2-y1)/2} }
end

local function setDimensions(newViewX, newViewY)
	print "Star layers"
	print("Star layers -- new view dimensions " .. newViewX .. ", " .. newViewY)
	print("Star layers -- old view dimensions " .. viewX .. ", " .. viewY)
	for k1, stars in pairs(starLayers) do
		print( "layer " .. string.format("%x", k1) )
		for k2, star in pairs(stars) do
			star[1] = (star[1] / viewX) * newViewX
			star[2] = (star[2] / viewY) * newViewY
			print( "\t" .. star[1] .. "," .. star[2] .. ")" )
		end
	end

	viewX, viewY = newViewX, newViewY
end

local function setVelocity(dirVec, speed)
	gDirVec = dirVec
	gSpeed = speed
end

local function setDir(dirVec)
	gDirVec = dirVec
end

local function setSpeed(speed)
	gSpeed = speed
end

local function loadStarLayers(filename, viewW, viewH)

	math.randomseed(os.time())

	-- black is empty, any other color is a group of stars
	-- We are assuming only two colors for now, so asset on that

	local imageData = love.image.newImageData(filename)
	local image = love.graphics.newImage(imageData)

	local wImg, hImg = imageData:getDimensions()

	print("Image dimensions " .. wImg .. ", " .. hImg)

	for j=0,hImg-1 do
		for i=0,wImg-1 do
			--print("Getting " .. i .. ", " .. j)
			local r, g, b = imageData:getPixel(i, j)
			r = r * 255
			g = g * 255
			b = b * 255
			-- Map color channels to 0.255, so can pack them as 8 bits each
			local hash = r * 256 * 256 + g * 256 + b
			if( r ~= 0 or g ~= 0 or b ~= 0) then
				--print("hash: " .. string.format("%x", hash) .. "(" .. r .. "," ..
				--g .. "," .. b .. ") at (" .. i .. "," .. j .. ")")

				if(starLayers[hash] == nil) then
					print("New layer: " .. string.format("%x", hash))
					starLayers[hash] = {}
				end
				local point = {i/wImg,j/hImg}
				table.insert(starLayers[hash], point)
			end
		end
	end

	-- Adjust coordinates to viewport size
	setDimensions(viewW, viewH)

	nextStarSpawnAttempt = os.time() + getStarSpawnTimeOffset()
end

local function updateStarLayers()

	local dirVec = gDirVec
	local speed = gSpeed
	local speedDecay = 0.75 -- speed adjust for each successive layer
	
	local dispSq = math.sqrt(dirVec[1] * dirVec[1] + dirVec[2] * dirVec[2])
	local speedX = dirVec[1] / dispSq * speed
	local speedY = dirVec[2] / dispSq * speed

	-- VERIFY: will we always walk the layers in the same order?
	for _, layer in pairs(starLayers) do

		for _, star in pairs(layer) do
			star[1] = star[1] + speedX
			star[2] = star[2] + speedY
			if( star[1] < 0 ) then star[1] = star[1] + viewX end
			if( star[1] >= viewX ) then star[1] = star[1] - viewX end
			if( star[2] < 0 ) then star[2] = star[2] + viewY end
			if( star[2] >= viewY ) then star[2] = star[2] - viewY end
		end

		speedX = speedX * speedDecay
		speedY = speedY * speedDecay
	end
end


local function updateShootingStars()
	local now = os.time()

	-- play area bounds
	local playAreaBB = {
		center = { viewX / 2, viewY / 2},
		halfs = { viewX / 2, viewY / 2} }

	-- Determine how many shooting stars are still in the play area
	local numStarsBefore = 0
	for _, _ in pairs(shootingStars) do numStarsBefore = numStarsBefore + 1 end

	local numStars = 0
	for key, ss in pairs(shootingStars) do
		if(not bbIntersect(playAreaBB, ss.bb)) then
			shootingStars[key] = nil
		else
			local dir = ss.dir
			local pos = ss.pos
			local speed = ss.speed

			pos[1] = pos[1] + dir[1] * speed
			pos[2] = pos[2] + dir[2] * speed
			ss.pos = pos

			updateBoundingBox(ss)

			numStars = numStars + 1
		end
	end

	-- shooting stars have all vanished, schedule next spawn attempt
	if(numStarsBefore > numStars and numStars == 0) then
		nextStarSpawnAttempt = now + getStarSpawnTimeOffset()
	end

	-- spawn shooting stars if necessary
	if(numStars == 0 and now > nextStarSpawnAttempt) then
		-- how many stars?
		starsCountProb = { 50, 30, 10 } -- stars may not spawn at every interval
		--starsCountProb = { 100, 30, 10 } -- at least one star will spawn every interval

		local numStarsToSpawn = 0
		for i=#starsCountProb,1,-1 do
			if(math.random(1,100) <= starsCountProb[i]) then
				numStarsToSpawn = i
				break
			end
		end

		local minor=0.3
		local major=0.5
		local ssColors =
		{
			{major,minor,minor,1},
			{minor,major,minor,1},
			{minor,minor,major,1},
			{major,major,minor,1},
			{major,minor,major,1}
		}

		-- We're not spawning any stars now, schedule next attempt
		if(numStarsToSpawn == 0) then
			nextStarSpawnAttempt = now + getStarSpawnTimeOffset()
		end

		for i=1,numStarsToSpawn do

			-- left: 1, top: 2, right: 3, bottom: 4
			-- Which edge will the shooting star spawn from?
			local edge = math.random(1,4)

			-- where along that edge (normalized)
			local min=20
			local max=80
			local edgeLocalRatio = math.random(min, max) / 100
			local edgeLocalRatio2 = math.random(min, max) / 100
			--local edgeLocalRatio2 = 1 - edgeLocalRatio -- awesome effect with large numbers of stars (need to force opposite edge as well)
			-- adjacent

			local adjacentMap = {4, 3, 4, 3}
			local adjEdge = adjacentMap[edge]
			if(edgeLocalRatio < 0.5) then
				adjEdge = ((adjEdge -1 + 2) % 4) + 1 -- basing modulo off 0
			end

			local spawnInfo = { -- x/y spawn, x/y dest
				{0, (viewY-1) * edgeLocalRatio, (viewX-1), (viewY-1) * edgeLocalRatio2},
				{(viewX-1) * edgeLocalRatio, 0, (viewX-1) * edgeLocalRatio2, (viewY-1)},
				{(viewX-1), (viewY-1) * edgeLocalRatio, 0, (viewY-1) * edgeLocalRatio2},
				{(viewX-1) * edgeLocalRatio, (viewY-1), (viewX-1) * edgeLocalRatio2, 0} }

			spawnPoint = {spawnInfo[edge][1], spawnInfo[edge][2]}

			-- Will it go toward an opposite or adjacent edge?
			if( math.random(1,2) == 1 ) then
				destPoint  = {spawnInfo[edge][3], spawnInfo[edge][4]}
			else
				destPoint  = {spawnInfo[adjEdge][3], spawnInfo[adjEdge][4]}
			end

			--print("Spawning star:")
			--print("   start(" .. spawnPoint[1] .. "," .. spawnPoint[2] .. ")")
			--print("     end(" .. destPoint[1] .. "," .. destPoint[2] .. ")")

			local dir = {
				destPoint[1] - spawnPoint[1],
				destPoint[2] - spawnPoint[2]
			}

			--local speed = 5
			local speed = math.random(20,45)

			local dirLen = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
			local dirX = dir[1] / dirLen
			local dirY = dir[2] / dirLen

			local ss = {
				pos = spawnPoint,
				dir = {dirX, dirY}, -- normalized
				dirLen = dirLen,
				speed = speed,
				color = ssColors[math.random(1,5)],
				trailLen = 120,
				steps = 12,
				trailColor = .40,
				colorDrop = .1
			}

			updateBoundingBox(ss)

			table.insert(shootingStars, ss)
		end
	end

end


local function update(dt)
	updateStarLayers()
	updateShootingStars()
end


local function draw()

	love.graphics.setLineStyle("rough")

	local colors = {
		{0.5,0.5,0.5,1},
		{0.25,0.25,0.25,1}
	}
	local layerIndex = 1

	for colorHash, stars in pairs(starLayers) do

		love.graphics.setColor(colors[layerIndex])
		for k, star in pairs(stars) do
			--love.graphics.points(star[1], star[2])
			love.graphics.circle("fill", star[1], star[2], 2)
		end
		layerIndex = layerIndex + 1
	end

	-- draw trail and core for shooting stars
	-- TODO: trail properties should be part of object
	for _, ss in pairs(shootingStars) do

		local ssPos = ss.pos
		local dir = ss.dir
		local ssRadius = 1
		local trailLen = ss.trailLen
		local steps = ss.steps
		local stepLen = trailLen / steps
		local trailColor = ss.trailColor
		local colorDrop = ss.colorDrop

		local stepX = stepLen * dir[1]  * (-1)
		local stepY = stepLen * dir[2]  * (-1)
		
		local color = trailColor
		local colorV = {}
		for _, v in ipairs(ss.color) do
			table.insert(colorV, v)
		end

		for i=0,steps-1 do
			
			love.graphics.setColor(colorV)
			love.graphics.line(
				ssPos[1] + i * stepX,
				ssPos[2] + i * stepY,
				ssPos[1] + (i+1) * stepX,
				ssPos[2] + (i+1) * stepY)

			for c=1,3 do
				colorV[c] = colorV[c] * (1-colorDrop)
			end
		end

		-- draw shooting star as a few concentric rings
		local ssColor = ss.color
		love.graphics.setColor(ssColor)
		love.graphics.circle("fill", ssPos[1], ssPos[2], ssRadius)

		-- draw bounding box
		--if(ss.bb) then
			--local bb = ss.bb
			--local bbColor = {1,1,0,1}
			--love.graphics.setColor(bbColor)
			--love.graphics.rectangle("line", bb.x1, bb.y1, bb.x2 - bb.x1, bb.y2 - bb.y1)
		--end
	end

	--drawDiags()
end


return {

	init = init,
	setDimensions = setDimensions,
	setVelocity = setVelocity,
	setDir = setDir,
	setSpeed = setSpeed,
	loadStarLayers = loadStarLayers,
	update = update,
	draw = draw
}



