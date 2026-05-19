-- development
if not turtle then
    dofile("dev/mock_turtle.lua")
end

local mod = {}

mod.item = require("turt.item")
mod.dig = require("turt.dig")
mod.fuel = require("turt.fuel")
mod.box = require("turt.box")
mod.stair = require("turt.stair")
mod.line = require("turt.line")
mod.powder = require("turt.powder")

-- the placing files
mod.floor = require("turt.floor")
mod.roof = require("turt.roof")

return mod
