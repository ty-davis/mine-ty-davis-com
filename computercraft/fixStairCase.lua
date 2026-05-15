turtle.refuel(1)
turtle.turnRight()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.forward()

local run = true
local amount = 0
while run do
    turtle.dig()
    run = turtle.forward()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    run = turtle.down()
    amount = amount + 1
end

turtle.turnRight()
turtle.turnRight()

for i=1, amount do
    turtle.forward()
    turtle.up()   
end