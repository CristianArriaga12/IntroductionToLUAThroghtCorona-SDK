-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )


local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local tapCount = 0
local ifCount ="hola"


local background = display.newImageRect( "Space.jpg", display.contentWidth, display.contentHeight )
background.x = display.contentCenterX
background.y = display.contentCenterY

local tapText = display.newText( tapCount, display.contentCenterX, 100, native.systemFont, 100 )
tapText:setFillColor( 0, 0, 0 )

local ifText = display.newText( ifCount, display.contentCenterX, 200, native.systemFont, 100 )
tapText:setFillColor( 0, 0, 0 )
local uiGroup = display.newGroup() 

livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

local Namekussei = display.newImageRect( "namek.png", 1500, 1500 )
Namekussei.x = display.contentCenterX
Namekussei.y = display.contentHeight+150

display.setStatusBar( display.HiddenStatusBar )

local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end


local function createAsteroid()

	local newAsteroid = display.newImageRect( "asteroide.png", 200, 200 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
	newAsteroid.myName = "asteroid"
	

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		newAsteroid.x = -60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	newAsteroid:applyTorque( math.random( -6,6 ) )
end

local function gameLoop()

	-- Create new asteroid
	createAsteroid()
	
	

	-- Remove asteroids which have drifted off screen
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]

		if ( thisAsteroid.x < -100 or
			 thisAsteroid.x > display.contentWidth + 100 or
			 thisAsteroid.y < -100 or
			 thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )
		end
	end
end

gameLoopTimer = timer.performWithDelay( 50, gameLoop, 1 )

-- physics.setDrawMode("hybrid")

--physics.addBody( suelo, "static", {friction=1.0})
--physics.addBody( pared_izq, "static" , {friction=1.0})
--physics.addBody( pared_der, "static", {friction=1.0})
--physics.addBody( techo, "static", {friction=1.0})
physics.addBody( Namekussei, "static", { radius=430, friction = 1.0} )




local function pushAsteroid(event)
--print("Si entre al listener")
	--if (event.phase == "began") then
	--print("El evento ha comenzado")
		local obj1 = event.object1
		
		--if(obj1.myName=="asteroid") then
		--obj1:applyLinearImpulse( 0, -0.75, event.x, event.y )
		tapCount = tapCount + 1
		if tapCount == 5 then
			print("Ya destruiste el asteriode")
			ifCount = "Booom"
			display.remove( obj1 )
			

			-- Increase score
			
		end
		score = score + 100
		scoreText.text = "Score: " .. score
		tapText.text = tapCount
	--end
end

Runtime:addEventListener( "tap", pushAsteroid )


--local function addAsteroid()
--	asteroid = display.newImageRect( "asteroide.png", 200, 200 )
--	asteroid.x = math.random(1000)
--	asteroid.y = 10
--	asteroid.rotation = 1
--	physics.addBody(asteroid, "dynamic",{radius=70, bounce=0.5, friction=1.0})
--	asteroid:addEventListener( "tap", pushAsteroid )
	
--end

--timer.performWithDelay(999,addAsteroid, 5)


