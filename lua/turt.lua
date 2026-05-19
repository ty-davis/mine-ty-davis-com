local turt_startup = function()
  local startup_code = [[
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

local options = {
  "Dig box (fullbox)",
  "Dig line",
  "Dig staircase",
  "Lay floor / ceiling",
  "Convert powder",
  "Check fuel",
}

print("=== Turt Menu ===")
for k, v in pairs(options) do
  print(k .. " - " .. v)
end

local choice
repeat
  io.write("> ")
  choice = tonumber(io.read())
until choice and choice >= 1 and choice <= #options

if choice == 1 then
  local l = promptNum("Length?", 10)
  local w = promptNum("Width?", 10)
  local h = promptNum("Height?", 3)
  turt.box.fullbox(l, w, h)

elseif choice == 2 then
  local len = promptNum("Length?", 10)
  local height = promptNum("Dig height (1-3)?", 3)
  turt.line.line(len, height)

elseif choice == 3 then
  local dir = prompt("Direction (up/down)?", "down")
  local amt = promptNum("Steps?", 16)
  turt.stair.stair(dir, amt)

elseif choice == 4 then
  local l = promptNum("Length?", 10)
  local w = promptNum("Width?", 10)
  local ceil = prompt("Ceiling mode? (y/n)", "n")
  ceil = (ceil == "y")
  local block = prompt("Block name (leave blank to use block below/above turtle)?", "")
  if block == "" then block = nil end
  turt.floor.floor(l, w, ceil, block)

elseif choice == 5 then
  turt.powder.convert()

elseif choice == 6 then
  local level = turtle.getFuelLevel()
  print("Fuel level: " .. tostring(level))
end

print("Done.")
]]

  if fs.exists("/startup.lua") then
    print("Moving current startup.lua to startup_old.lua")
    fs.move("/startup.lua", "/startup_old.lua")
  end
  local f = fs.open("/startup.lua", "w")
  f.write(startup_code)
  f.close()
  print("startup.lua written. Reboot to launch the turt menu.")
end

local install_turt = function()
  print("Turt mode initializing")
  print("")

  print("Checking if /turt already exists...")
  local root_files = fs.list("/")
  local turt_installed = false
  for i = 1, #root_files do
    if root_files[i] == "turt" then
      turt_installed = true
    end
  end

  if turt_installed then
    print("/turt already exists, do you want to overwrite it [Y/n]?")
    local response
    first_time = true

    repeat
      if first_time == false then
        print("Invalid response, try again.")
      end
      first_time = false
      io.write("> ")
      response = io.read()
      if string.lower(response) == "n" then
        print("exiting...")
        return false
      elseif string.lower(response) == "y" or string.lower(response) == "" then
        print("Overwriting /turt")
      end
    until string.lower(response) == "y" or string.lower(response) == "" or string.lower(response) == "n"
  else
    print("Installing turt into /turt")
  end

  -- the actaul installing part
  shell.setDir("/")
  fs.makeDir("/turttemp")
  shell.setDir("/turttemp")
  print("Installing unbundle...")
  local endpoint = "https://mine.ty-davis.com"
  local request = http.get(endpoint .. "/lua/unbundle.lua")
  local bundle_f = fs.open("/turttemp/unbundle.lua", "w")
  bundle_f.write(request.readAll())
  bundle_f.close()

  print("Downloading turt...")
  request = http.get(endpoint .. "/bundles/turt.bundle")
  local turt_bundle_f = fs.open("/turttemp/turt.bundle", "w")
  turt_bundle_f.write(request.readAll())
  turt_bundle_f.close()

  print("Unbundling turt...")
  shell.run("unbundle", "/turttemp/turt.bundle", "/")

  print("Turt successfully unbundled")
  shell.setDir("/")
  fs.delete("/turttemp")
end

local menu = function()
  print("Welcome to the turt installer.")
  print("What would you like to do?")
  local options = {
    "Install turt",
    "Uninstall turt",
    "Create startup.lua script"
  }
  for k, v in pairs(options) do
    print(k, "-", v)
  end
  local choice = ""
  local choice_num = 0
  repeat
    io.write("> ")
    local choice = io.read()
    choice_num = tonumber(choice)
  until choice_num >= 1 and choice_num <= #options

  if options[choice_num] == "Install turt" then
    install_turt()
  elseif options[choice_num] == "Uninstall turt" then
    print("Uninstalling")
  elseif options[choice_num] == "Create startup.lua script" then
    print("Creating startup script")
    turt_startup()
  end
end


menu()
