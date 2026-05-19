fuel = require("turt.fuel")
item = require("turt.item")


mod = {}

function mod.slit(steps, block)
    block = block or 'stair'
    
    turtle.turnRight()
    turtle.turnRight()
    fuel.checknfuel(steps*3)
    for i = 1,steps do
        item.placed(block)
        if i ~= steps then
            turtle.up()
            turtle.back()
        end
    end
    turtle.up()
    turtle.turnRight()
    turtle.turnRight()
    fuel.checknfuel(steps*3)
    for i = 1,steps do
        item.placed(block)
        turtle.back()
        turtle.down()
    end
    turtle.up()
    turtle.forward()
    
end

function mod.slits(steps, w, block)
    fuel.checknfuel(5)
    for i=1,w do
        mod.slit(steps, block)
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        turtle.down()
    end
end

return mod
