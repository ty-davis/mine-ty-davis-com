local item = require("turt.item")

local mod = {}

function mod.checknfuel(amt)
    amt = amt or 10
    local fl = turtle.getFuelLevel()
    if fl < amt then
        -- check each slot for coal
        if item.select_wait("coal") then
            turtle.refuel()
            return true
        end
        return false
    end
    return true
end

return mod
