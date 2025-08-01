local fs = require("@lune/fs")
local luau = require("@lune/luau")

for i, name in pairs(fs.readDir("test")) do
    if name:match("%.lua$") or name:match("%.luau$") then
        local bytecode = luau.compile(fs.readFile("test/" .. name))
        local callableFn = luau.load(bytecode)
        callableFn()
    end
end