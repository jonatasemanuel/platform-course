function love.load()
	anim8 = require("libraries/anim8/anim8")

	sti = require("libraries/Simple-Tiled-Implementation/sti")
	cameraFile = require("libraries/hump/camera")
	cam = cameraFile()

	sprites = {}
	sprites.playerSheet = love.graphics.newImage("sprites/playerSheet.png")
	sprites.enemySheet = love.graphics.newImage("sprites/enemySheet.png")

	local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
	local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

	animations = {}
	animations.idle = anim8.newAnimation(grid("1-15", 1), 0.05)
	animations.jump = anim8.newAnimation(grid("1-5", 2), 0.05)
	animations.run = anim8.newAnimation(grid("1-15", 3), 0.05)
	animations.enemy = anim8.newAnimation(enemyGrid("1-2", 1), 0.03)

	wf = require("libraries/windfield")
	world = wf.newWorld(0, 800, false)
	world:setQueryDebugDrawing(true)

	world:addCollisionClass("Platform")
	world:addCollisionClass("Danger")
	world:addCollisionClass("Player")

	require("player")
	require("enemy")
	require("libraries/show")

	-- danzerZone = world:newRectangleCollider(0, 550, 800, 50, { collision_class = "Danger" })
	-- danzerZone:setType("static")

	platforms = {}

	saveData = {}
	saveData.currentLevel = "level-1"

	flagX = 0
	flagY = 0

	if love.filesystem.getInfo("data.lua") then
		local data = love.filesystem.load("data.lua")
		data()
	end

	loadMap(saveData.currentLevel)
end

function love.keypressed(key)
	if key == "up" then
		local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, { "Platform" })
		if #colliders > 0 then
			if player.grounded then
				player:applyLinearImpulse(0, -4000)
			end
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		local colliders = world:queryCircleArea(x, y, 200, { "Platform", "Danger" })
		for i, c in ipairs(colliders) do
			c:destroy()
		end
	end
end

function spawnPlatform(x, y, w, h)
	if w > 0 and h > 0 then
		local platform = world:newRectangleCollider(x, y, w, h, { collision_class = "Platform" })
		platform:setType("static")
		table.insert(platforms, platform)
	end
end

function love.update(dt)
	world:update(dt)
	gameMap:update(dt)
	playerUpdate(dt)
	updateEnemies(dt)

	local px, py = player:getPosition()
	-- cam:lookAt(px, py)
	cam:lookAt(px, love.graphics.getHeight() / 2)

	local colliders = world:queryCircleArea(flagX, flagY, 10, { "Player" })
	if #colliders > 0 then
		if saveData.currentLevel == "level-1" then
			print(saveData.currentLevel)
			loadMap("level-2")
		elseif saveData.currentLevel == "level-2" then
			loadMap("level-1")
		end
	end
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
	world:draw()
	playerDraw()
	drawEnemies()
	cam:detach()
end

function destroyAll()
	local i = #platforms
	while i > -1 do
		if platforms[i] ~= nil then
			platforms[i]:destroy()
		end
		table.remove(platforms, i)
		i = i - 1
	end
	local i = #enemies
	while i > -1 do
		if enemies[i] ~= nil then
			enemies[i]:destroy()
		end
		table.remove(enemies, i)
		i = i - 1
	end
end

function loadMap(mapName)
	saveData.currentLevel = mapName
	love.filesystem.write("data.lua", table.show(saveData, "saveData"))

	destroyAll()
	player:setPosition(300, 100)
	gameMap = sti("map/" .. mapName .. ".lua")

	for i, obj in ipairs(gameMap.layers["Platform"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end

	for i, obj in ipairs(gameMap.layers["Enemy"].objects) do
		spawnEnemy(obj.x, obj.y)
	end

	for i, obj in ipairs(gameMap.layers["Flag"].objects) do
		flagX = obj.x
		flagY = obj.y
	end
end
