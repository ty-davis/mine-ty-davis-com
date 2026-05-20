local turt = require("turt")

local function prompt(msg, default)
  io.write(msg .. " ")
  local val = io.read()
  if val == "" and default ~= nil then return default end
  return val
end

local function promptNum(msg, default)
  local val
  repeat
    val = tonumber(prompt(msg, tostring(default)))
    if not val then print("Please enter a number.") end
  until val
  return val
end

local function moveTurtle()
  print("\n=== Move Turtle ===")
  print("  f - forward    b - back")
  print("  l - turn left  r - turn right")
  print("  u - up         d - down")
  print("")
  print("Use a number before to repeat command (e.g. 10w)")
  print("(empty to return to menu)")

  while true do
    io.write("> ")
    local input = io.read()
    if input == "" then
      break
    end

    local count_s, command = string.match(input, "^(%d*)%s?(.)")
    if count_s and count_s ~= "" then
      count = tonumber(count_s)
    else
      count = 1
    end

    for i = 1,count do
      if command == "f" then
        if not turtle.forward() then print("Blocked.") end
      elseif command == "b" then
        if not turtle.back() then print("Blocked.") end
      elseif command == "l" then
        turtle.turnLeft()
      elseif command == "r" then
        turtle.turnRight()
      elseif command == "u" then
        if not turtle.up() then print("Blocked.") end
      elseif command == "d" then
        if not turtle.down() then print("Blocked.") end
      else
        print("Unknown input: '" .. input .. "'")
        break
      end
    end
  end
end

local options = {
  "Dig box (fullbox)",
  "Dig line",
  "Dig staircase",
  "Lay floor / ceiling",
  "Convert powder",
  "Check fuel",
  "Move turtle",
}

while true do
  print("\n=== Turt Menu ===")
  for k, v in ipairs(options) do
    print(k .. " - " .. v)
  end
  print("(empty to exit)")

  io.write("> ")
  local input = io.read()

  if input == "" then
    print("Goodbye.")
    break
  end

  local choice = tonumber(input)

  if not choice or choice < 1 or choice > #options then
    print("Invalid choice.")

  elseif choice == 1 then
    local l = promptNum("Length?", 10)
    local w = promptNum("Width?", 10)
    local h = promptNum("Height?", 3)
    turt.box.fullbox(l, w, h)
    print("Done.")

  elseif choice == 2 then
    local len = promptNum("Length?", 10)
    local height = promptNum("Dig height (1-3)?", 3)
    turt.line.line(len, height)
    print("Done.")

  elseif choice == 3 then
    local dir = prompt("Direction (up/down)?", "down")
    local amt = promptNum("Steps?", 16)
    turt.stair.stair(dir, amt)
    print("Done.")

  elseif choice == 4 then
    local l = promptNum("Length?", 10)
    local w = promptNum("Width?", 10)
    local ceil = prompt("Ceiling mode? (y/n)", "n")
    ceil = (ceil == "y")
    local block = prompt("Block name (leave blank to use block below/above turtle)?", "")
    if block == "" then block = nil end
    turt.floor.floor(l, w, ceil, block)
    print("Done.")

  elseif choice == 5 then
    turt.powder.convert()
    print("Done.")

  elseif choice == 6 then
    local level = turtle.getFuelLevel()
    print("Fuel level: " .. tostring(level))

  elseif choice == 7 then
    moveTurtle()

  end
end
