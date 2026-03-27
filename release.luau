local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

print("Packaging src into AlyaNum.rbxm...")

if not fs.isDir("src") then
    error("src directory not found")
end

local sourceFile = "src/init.luau"
if not fs.isFile(sourceFile) then
    error("src/init.luau not found")
end

local source = fs.readFile(sourceFile)
local module = roblox.Instance.new("ModuleScript")
module.Name = "AlyaNum"
module.Source = source

local rbxm = roblox.serializeModel({ module })
fs.writeFile("AlyaNum.rbxm", rbxm)
print("Successfully packaged src into AlyaNum.rbxm")
