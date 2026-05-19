local mod = {}

function mod.select(name)
    exact = exact or false
    for i = 1, 16 do
        turtle.select(i)
        local ditem = turtle.getItemDetail()
        if ditem and string.match(ditem["name"], name, 1) then
            return true
        end
    end
    return false
end

function mod.select_wait(block)
    while not mod.select(block) do
        print("Waiting for " .. block)
        io.read()
    end
    return true
end

function mod.placed(block)
    mod.select_wait(block)
    turtle.placeDown()
end

function mod.placeu(block)
    mod.select_wait(block)
    turtle.placeUp()
end

function mod.placef(block)
    mod.select_wait(block)
    turtle.place()
end

return mod
