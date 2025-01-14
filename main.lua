function love.load()
	anim8 = require("libraries/anim8/anim8")

	sti = require("libraries/Simple-Tiled-Implementation/sti")
	cameraFile = require("libraries/hump/camera")
	cam = cameraFile()

	sprites = {}
	sprites.playerSheet = love.graphics.newImage("sprites/playerSheet.png")

	local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

	animations = {}
	animations.idle = anim8.newAnimation(grid("1-15", 1), 0.05)
	animations.jump = anim8.newAnimation(grid("1-5", 2), 0.05)
	animations.run = anim8.newAnimation(grid("1-15", 3), 0.05)

	wf = require("libraries/windfield")
	world = wf.newWorld(0, 800, false)
	world:setQueryDebugDrawing(true)

	world:addCollisionClass("Platform")
	world:addCollisionClass("Danger")
	world:addCollisionClass("Player")

	require("player")

	-- danzerZone = world:newRectangleCollider(0, 550, 800, 50, { collision_class = "Danger" })
	-- danzerZone:setType("static")

	platforms = {}

	loadMap()
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

	local px, py = player:getPosition()
	-- cam:lookAt(px, py)
	cam:lookAt(px, love.graphics.getHeight() / 2)
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
	-- world:draw()
	playerDraw()
	cam:detach()
end

function loadMap()
	gameMap = sti("map/level-1.lua")

	for i, obj in ipairs(gameMap.layers["Platform"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end
end
