local turt_startup = function()
  local endpoint = "https://mine.ty-davis.com"

  print("Downloading startup.lua...")
  local request = http.get(endpoint .. "/lua/startup.lua")
  if not request then
    print("Error: Failed to download startup.lua")
    return
  end
  local startup_code = request.readAll()
  request.close()

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
