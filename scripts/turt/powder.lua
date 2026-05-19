dig = require("turt.dig")
item = require("turt.item")

local mod = {}

function mod.convert()
    while item.select("powder") do
        turtle.place()
        dig.digf()
    end
end

return mod
