turtle.refuel()
turtle.turnRight()
turtle.forward()
turtle.turnLeft()

local y = 67
local run = true
while (y > 0 and run) do
    turtle.digDown()
    run = turtle.down()
end

for i=0, 67 do
    turtle.up()
end

turtle.turnLeft()
turtle.forward()
turtle.turnRight()