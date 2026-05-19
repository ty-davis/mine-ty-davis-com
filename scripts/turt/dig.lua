local fuel = require("turt.fuel")
local mod = {}

function mod.digf()
    fuel.checknfuel()
    while turtle.detect() do
        if not turtle.dig() then
            return false
        end
    end
    return true
end

function mod.digu()
    fuel.checknfuel()
    while turtle.detectUp() do
        if not turtle.digUp() then
            return false
        end
    end
    return true
end

function mod.digd()
    fuel.checknfuel()
    while turtle.detectDown() do
        if not turtle.digDown() then
            return false
        end
    end
    return true
end

return mod
