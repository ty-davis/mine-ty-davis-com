-- Turtle Self-tracking System created by Latias1290.

local xPos, yPos, zPos = nil
local locationFile = "/my_api/pos/location.txt"
local face = 1
cal = false

function setLocation() -- get gps using other computers
    xPos, yPos, zPos = gps.locate()
    cal = true
end

function readLocation()
    local file = fs.open(locationFile, "r")
    if file then
        position = textutils.unserialize(file.readAll())
        xPos = position["x"]
        yPos = position["y"]
        zPos = position["z"]
        face = position["face"]
        cal = true
        print(xPos, yPos, zPos, face)
        file.close()
    else
        print("No location file found at ", locationFile)
    end

end

function saveLocation()
    local file = fs.open(locationFile, "w")
    if file then
        local position = { x = xPos,
            y = yPos,
            z = zPos,
            face = face
        }
        file.write(textutils.serialize(position))
        file.close()
    end
end

function manSetLocation(x, y, z, f) -- manually set location
    xPos = x
    yPos = y
    zPos = z
    face = f
    cal = true
end

function getLocation() -- return the location
    if xPos ~= nil then
        local position = {
            x=xPos,
            y=yPos,
            z=zPos,
            face=face
        }
        print(xPos, yPos, zPos, face)
        return position
    else
        return nil
    end
end

function turnLeft() -- turn left
    turtle.turnLeft()
    if face == 0 then
        face = 1
    elseif face == 1 then
        face = 2
    elseif face == 2 then
        face = 3
    elseif face == 3 then
        face = 0
    end
end

function turnRight() -- turn right
    turtle.turnRight()
    if face == 0 then
        face = 3
    elseif face == 1 then
        face = 0
    elseif face == 2 then
        face = 1
    elseif face == 3 then
        face = 2
    end
end

function forward() -- go forward
    local move = turtle.forward()
    if cal == true and move then
        if face == 0 then
            zPos = zPos - 1
        elseif face == 1 then
            xPos = xPos - 1
        elseif face == 2 then
            zPos = zPos + 1
        elseif face == 3 then
            xPos = xPos + 1
        end
    else
    print("Not Calibrated.")
    end
end

function back() -- go back
    local move = turtle.back()
    if cal == true and move then
        if face == 0 then
            zPos = zPos + 1
        elseif face == 1 then
            xPos = xPos + 1
        elseif face == 2 then
            zPos = zPos - 1
        elseif face == 2 then
            xPos = xPos - 1
        end
    else
    print("Not Calibrated.")
    end
end

function up() -- go up
    local move = turtle.up()
    if cal == true and move then
        yPos = yPos + 1
    else
        print("Not Calibrated.")
    end
end

function down() -- go down
    local move = turtle.down()
    if cal == true and move then
        yPos = yPos - 1
    else
        print("Not Calibrated.")
    end
end

function jump() -- perform a jump. useless? yup!
    turtle.up()
    turtle.down()
end

-- Section of my own functions that allow me to use my turtle specifically

function toTheMines()
    turnRight()
    forward()
    turnLeft()
    down()
    forward()
    forward()
    turnLeft()
    forward()
    while (yPos > 0) do
        down()
    end
end