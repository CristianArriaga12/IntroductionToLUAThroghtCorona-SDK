
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions ={
    frames ={
        {   -- 1) asteroid 1
            x = 17,
            y = 0,
            width = 270,
            height = 270
        },
        
		{   -- 2) Millennium_Falcon
            x = 0,
            y = 500,
            width = 280,
            height = 350
        },
        {   -- 3) laser
            x = 125,
            y = 313,
            width = 50,
            height = 160
        },
		
		{   -- 4) Namekusein
            x = 0,
            y = 855,
            width = 280,
            height = 260
        },
		
    },
}
local objectSheet = graphics.newImageSheet( "Imagen1.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local Namekussei
local Millennium_Falcon
local gameLoopTimer
local livesText
local scoreText
local diedText

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the Millennium_Falcon, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for Player points

-- Load the background
local background = display.newImageRect( backGroup, "Space.jpg", display.contentWidth, display.contentHeight )
background.x = display.contentCenterX
background.y = display.contentCenterY

Namekussei = display.newImageRect(  mainGroup, objectSheet,4, 1500, 1500 )
Namekussei.x = display.contentCenterX
Namekussei.y = display.contentHeight+150
physics.addBody( Namekussei, "static", { radius=500, friction = 1.0} )

--Load the Millennium_Falcon

Millennium_Falcon = display.newImageRect( mainGroup, objectSheet, 2, 400, 400 )
Millennium_Falcon.x = display.contentCenterX
Millennium_Falcon.y = display.contentHeight - 200
physics.addBody( Millennium_Falcon, { radius=155, isSensor=true } )
Millennium_Falcon.myName = "Millennium_Falcon"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 80 )
scoreText = display.newText( uiGroup, "Score: " .. score, 700, 80, native.systemFont, 80 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

local function createAsteroid()

	local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 200, 200 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=80, bounce=0.8 } )
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

local function fireLaser()

	local newLaser = display.newImageRect( mainGroup, objectSheet, 3, 20, 100 )
	physics.addBody( newLaser, "dynamic", { isSensor=true } )
	newLaser.isBullet = true
	newLaser.myName = "laser"

	newLaser.x = Millennium_Falcon.x
	newLaser.y = Millennium_Falcon.y
	newLaser:toBack()

	transition.to( newLaser, { y=-40, time=500,
		onComplete = function() display.remove( newLaser ) end
	} )
end

Millennium_Falcon:addEventListener( "tap", fireLaser )

local function dragMillennium_Falcon( event )

	local Millennium_Falcon = event.target
	local phase = event.phase

	if ( "began" == phase ) then
		-- Set touch focus on the Millennium_Falcon
		display.currentStage:setFocus( Millennium_Falcon )
		-- Store initial offset position
		Millennium_Falcon.touchOffsetX = event.x - Millennium_Falcon.x

	elseif ( "moved" == phase ) then
		-- Move the Millennium_Falcon to the new touch position
		Millennium_Falcon.x = event.x - Millennium_Falcon.touchOffsetX

	elseif ( "ended" == phase or "cancelled" == phase ) then
		-- Release touch focus on the Millennium_Falcon
		display.currentStage:setFocus( nil )
	end

	return true  -- Prevents touch propagation to underlying objects
end

Millennium_Falcon:addEventListener( "touch", dragMillennium_Falcon )

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

gameLoopTimer = timer.performWithDelay( 1500, gameLoop, 0 )

local function restoreMillennium_Falcon()

	Millennium_Falcon.isBodyActive = false
	Millennium_Falcon.x = display.contentCenterX
	Millennium_Falcon.y = display.contentHeight - 200

	-- Fade in the Millennium_Falcon
	transition.to( Millennium_Falcon, { alpha=1, time=4000,
		onComplete = function()
			Millennium_Falcon.isBodyActive = true
			died = false
		end
	} )
end

local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "Millennium_Falcon" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "Millennium_Falcon" ) )
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives

				if ( lives == 0 ) then
					display.remove( Millennium_Falcon )
					diedText = display.newText( uiGroup, "You Lost: " .. score, display.contentCenterX, display.contentCenterY, native.systemFont, 150 )
					diedText:setFillColor( 1, 0, 0 )
				else
					Millennium_Falcon.alpha = 0
					timer.performWithDelay( 1000, restoreMillennium_Falcon )
				end
			end
		end
	end
end

Runtime:addEventListener( "collision", onCollision )

-- physics.setDrawMode("hybrid")
