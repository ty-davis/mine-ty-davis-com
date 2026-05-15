local args = {...}
if #args < 1 then
  print("Usage: unbundle <bundleFile> [targetDir]")
  return
end

local bundleFile = shell.resolve(args[1])
local targetDir = shell.resolve(args[2] or ".")

if not fs.exists(bundleFile) then
  error("Bundle file does not exist: " .. bundleFile)
end

if fs.isDir(bundleFile) then
  error("Bundle file must be a file: " .. bundleFile)
end

if not fs.exists(targetDir) then
  fs.makeDir(targetDir)
elseif not fs.isDir(targetDir) then
  error("Target path must be a directory: " .. targetDir)
end

local ok, bundle = pcall(dofile, bundleFile)
if not ok then
  error("Failed to load bundle: " .. tostring(bundle))
end

if type(bundle) ~= "table" or type(bundle.entries) ~= "table" then
  error("Invalid bundle format")
end

local rootName = bundle.root
if type(rootName) ~= "string" or rootName == "" then
  error("Invalid bundle root")
end

local rootPath = fs.combine(targetDir, rootName)
if not fs.exists(rootPath) then
  fs.makeDir(rootPath)
elseif not fs.isDir(rootPath) then
  error("Bundle root path exists and is not a directory: " .. rootPath)
end

for _, entry in ipairs(bundle.entries) do
  if type(entry) ~= "table" or type(entry.type) ~= "string" or type(entry.path) ~= "string" then
    error("Invalid bundle entry")
  end

  local outPath = fs.combine(rootPath, entry.path)

  if entry.type == "dir" then
    if not fs.exists(outPath) then
      fs.makeDir(outPath)
    elseif not fs.isDir(outPath) then
      error("Cannot create directory, file exists: " .. outPath)
    end
  elseif entry.type == "file" then
    local parent = fs.getDir(outPath)
    if parent ~= "" and not fs.exists(parent) then
      fs.makeDir(parent)
    end

    local handle = fs.open(outPath, "wb")
    if not handle then
      error("Failed to open file for writing: " .. outPath)
    end
    handle.write(entry.content or "")
    handle.close()
  else
    error("Unknown entry type: " .. tostring(entry.type))
  end
end

print("Unbundled " .. bundleFile .. " -> " .. rootPath .. " (" .. tostring(#bundle.entries) .. " entries)")
