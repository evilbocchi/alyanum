local fs = require("@lune/fs")

local tests = {}

for _, file in fs.readDir("test") do
	if file:match("%.luau$") then
		require("./test/" .. file)
	end
end
