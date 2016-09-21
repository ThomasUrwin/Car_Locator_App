-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require( "widget" )

local viewingCar = false

local locationData = {}
locationData.latitude = 0
locationData.longitude = 0
locationData.altitude = 0
locationData.accuracy = 0

local background = display.newImage("assets/background_city.png")
background.anchorX, background.anchorY =0, 0.5
background.x, background.y = 0, display.contentHeight/2
background:scale(display.contentHeight/background.height, display.contentHeight/background.height)

local myMap = native.newMapView(0,0, display.contentWidth*0.9, display.contentHeight*0.5)
myMap.x = display.contentCenterX
myMap.y = display.contentHeight*0.3
myMap.mapType = "standard"

local saveLocButtonPress = function( event )
    if locationData.latitude ~= 0 then
        local saveData = ""..locationData.latitude.."\n"..locationData.longitude.."\n"..locationData.altitude.."\n"..locationData.accuracy
        -- Path for the file to write
        local path = system.pathForFile( "parK_location.txt", system.DocumentsDirectory )
        print(path)

        -- Open the file handle
        os.remove(path)
        local file, errorString = io.open( path, "w" )

        if not file then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
            native.showAlert("Error", "File not found.")
        else
            -- Write data to file
            file:write( saveData )
            -- Close the file handle
            io.close( file )
            native.showAlert("Success", "Location Saved: "..path.."   DATA: "..locationData.latitude..", "..locationData.longitude)
            viewingCar = false
            myMap:removeAllMarkers()
        end

        file = nil
    else
        native.showAlert("Error!", "No Location Data Available")
    end
end

local button1 = widget.newButton(
{
	defaultFile = "assets/button_1.png",
	overFile = "assets/button_1_over.png",
	label = "Save My Car's Location",
	labelColor = 
	{ 
		default = { 0/255, 0/255, 0/255, 1}, 
		over = { 0/255, 0/255, 0/255, 0/255 }
	},
	font = native.systemFontBold,
	fontSize = 22,
	emboss = true,
	onPress = saveLocButtonPress,
})
button1.x, button1.y = display.contentWidth/2, 7*(display.contentHeight/10)
button1:scale((display.contentWidth/button1.contentWidth)*0.9, (display.contentWidth/button1.contentWidth)*0.9)



local showLocButtonPress = function( event )
	-- Show location on map
    local lat, lon, alt, acc

    local path = system.pathForFile( "parK_location.txt", system.DocumentsDirectory )
    local file, errorString = io.open(path, "r")
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        native.showAlert("Error", "File not found.")
    else
        lat = tonumber(file:read("*l"))
        lon = tonumber(file:read("*l"))
        alt = tonumber(file:read("*l"))
        acc = tonumber(file:read("*l"))

        -- Close the file handle
        io.close( file )
    end

    file = nil

    if lon ~= 0 then
	    --mapURL = "https://maps.google.com/maps?q=Your,+Car@" .. locationData.latitude .. "," .. locationData.longitude 
	    --system.openURL( mapURL )
        viewingCar = true
        native.showAlert("Location", lat..", "..lon..","..alt..", "..acc)
        myMap:setCenter(lat, lon)
        myMap:addMarker(lat, lon, "assets/car_icon.png")
    else
        native.showAlert("Error", "locationData.longitude == 0")
    end
end

local button2 = widget.newButton
{
	defaultFile = "assets/button_2.png",
	overFile = "assets/button_2_over.png",
	label = "Find My Car!",
	labelColor = 
	{ 
		default = { 0/255, 0/255, 0/255, 1}, 
		over = { 0/255, 0/255, 0/255, 0/255 } 
	},
	font = native.systemFontBold,
	fontSize = 22,
	emboss = true,
	onPress = showLocButtonPress,
}
button2.x, button2.y = display.contentWidth/2, 9*(display.contentHeight/10)
button2:scale((display.contentWidth/button2.contentWidth)*0.9, (display.contentWidth/button2.contentWidth)*0.9)



local locationHandler = function( event )
    --native.showAlert("Success", "Location data received: "..event.latitude..", "..event.longitude.."  \\")
	-- Check for error (user may have turned off Location Services)
	if event.errorCode then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
		print( "Location error: " .. tostring( event.errorMessage ) )
	else
    
        locationData.latitude = event.latitude

        locationData.longitude = event.longitude

        locationData.altitude = event.altitude

        locationData.accuracy = event.accuracy

        if not viewingCar then
            myMap:setCenter(event.latitude, event.longitude)
        end

        --[[locationData.latitude = event.accuracy
		local latitudeText = string.format( '%.4f', event.latitude )
		currentLatitude = latitudeText
		latitude.text = latitudeText
		
		local longitudeText = string.format( '%.4f', event.longitude )
		currentLongitude = longitudeText
		longitude.text = longitudeText
		
		local altitudeText = string.format( '%.3f', event.altitude )
		altitude.text = altitudeText
	
		local accuracyText = string.format( '%.3f', event.accuracy )
		accuracy.text = accuracyText
		
		local speedText = string.format( '%.3f', event.speed )
		speed.text = speedText
	
		local directionText = string.format( '%.3f', event.direction )
		direction.text = directionText
	
		-- Note: event.time is a Unix-style timestamp, expressed in seconds since Jan. 1, 1970
		local timeText = string.format( '%.0f', event.time )
		time.text = timeText ]]
		
	end
end
Runtime:addEventListener( "location", locationHandler )
