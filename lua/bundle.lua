local args = {...}
if #args < 1 then
  print("Usage: bundle <sourceDir> [outputFile]")
  return
end

local sourceDir = shell.resolve(args[1])
local outputFile = shell.resolve(args[2] or (fs.getName(sourceDir) .. ".bundle"))

if not fs.exists(sourceDir) then
  error("Source path does not exist: " .. sourceDir)
end

if not fs.isDir(sourceDir) then
  error("Source path must be a directory: " .. sourceDir)
end

local function normalize(path)
  path = fs.combine(path, "")
  if path == "" or path == "/" then
    return ""
  end
  return path:gsub("/+$", "")
end

local function escape_value(value)
  return string.format("%q", value)
end

local entries = {}
local sourceName = fs.getName(sourceDir)

local function walk(absPath, relPath)
  relPath = normalize(relPath)

  if relPath ~= "" then
    if fs.isDir(absPath) then
      table.insert(entries, { type = "dir", path = relPath })
    else
      local handle = fs.open(absPath, "rb")
      if not handle then
        error("Failed to open file for reading: " .. absPath)
      end
      local content = handle.readAll() or ""
      handle.close()
      table.insert(entries, { type = "file", path = relPath, content = content })
      return
    end
  end

  local children = fs.list(absPath)
  table.sort(children)
  for _, child in ipairs(children) do
    local childAbs = fs.combine(absPath, child)
    local childRel = relPath == "" and child or fs.combine(relPath, child)
    walk(childAbs, childRel)
  end
end

walk(sourceDir, "")

local out = fs.open(outputFile, "w")
if not out then
  error("Failed to open output file for writing: " .. outputFile)
end

out.writeLine("return {")
out.writeLine("  root = " .. escape_value(sourceName) .. ",")
out.writeLine("  version = 1,")
out.writeLine("  entries = {")

for _, entry in ipairs(entries) do
  if entry.type == "dir" then
    out.writeLine("    { type = \"dir\", path = " .. escape_value(entry.path) .. " },")
  else
    out.writeLine("    { type = \"file\", path = " .. escape_value(entry.path) .. ", content = " .. escape_value(entry.content) .. " },")
  end
end

out.writeLine("  }")
out.writeLine("}")
out.close()

print("Bundled " .. sourceDir .. " -> " .. outputFile .. " (" .. tostring(#entries) .. " entries)")
