function love.load()
	anim8 = require("libraries/anim8/anim8")

	sti = require("libraries/Simple-Tiled-Implementation/sti")

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

	platform = world:newRectangleCollider(250, 400, 300, 100, { collision_class = "Platform" })
	platform:setType("static")

	danzerZone = world:newRectangleCollider(0, 550, 800, 50, { collision_class = "Danger" })
	danzerZone:setType("static")

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

function love.update(dt)
	world:update(dt)
	gameMap:update(dt)
	playerUpdate(dt)
end

function love.draw()
	gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
	world:draw()
	playerDraw()
end

function loadMap()
	gameMap = sti("map/level-1.lua")
end
