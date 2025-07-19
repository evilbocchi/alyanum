local fs = require("@lune/fs")
local luau = require("@lune/luau")
local bytecode = luau.compile(fs.readFile("src/init.luau"))
local AlyaNum = luau.load(bytecode)()