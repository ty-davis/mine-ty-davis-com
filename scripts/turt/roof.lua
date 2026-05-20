fuel = require("turt.fuel")
item = require("turt.item")


mod = {}

function mod.slit(steps, block)
    block = block or 'stair'

    turtle.down()
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
    turtle.forward()
end

function mod.slabslit(steps, block, slab)
    fuel.checknfuel(steps*5)
    for i = 1,steps do
        turtle.down()
        item.placed(slab)
        turtle.up()
        item.placed(slab)
        turtle.forward()
        item.placed(block)
        turtle.up()
        turtle.forward()
    end
end

function mod.slits(steps, w, block)
    fuel.checknfuel(5)
    for i=1,w do
        mod.slit(steps, block)
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
    end
end

function mod.slabslits(steps, w, block, slab)
    fuel.checknfueld(w)
    for i=1,w do
        mod.slabslit(steps, block, slab)
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
    end
end

return mod
