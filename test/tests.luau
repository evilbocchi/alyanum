local fs = require("@lune/fs")
local luau = require("@lune/luau")

local bytecode = luau.compile(fs.readFile("src/init.luau"))
local AlyaNum = luau.load(bytecode)()

--- Test runner

local tests = {}

function addTest(name, fn)
	table.insert(tests, { name = name, fn = fn })
end

function assertEqual(actual, expected, msg)
	if actual ~= expected then
		error(msg or ("Expected " .. tostring(expected) .. ", got " .. tostring(actual)), 2)
	end
end

function assertClose(actual, expected, epsilon, msg)
	epsilon = epsilon or 1e-9
	if math.abs(actual - expected) >= epsilon then
		error((msg or "") .. " Expected "..tostring(actual).." ≈ "..tostring(expected).." (epsilon="..tostring(epsilon)..")", 2)
	end
end

function runTests()
	local passed, failed = 0, 0
	for _, test in ipairs(tests) do
		local ok, err = pcall(test.fn)
		if ok then
			print("[PASS]", test.name)
			passed += 1
		else
			print("[FAIL]", test.name, err)
			failed += 1
		end
	end
	print("Tests finished. Passed:", passed, "Failed:", failed)
end



--- Construction

addTest("fromNumber: creates from number", function()
	local num = AlyaNum.new(5)
	assertEqual(num:toNumber(), 5)
end)

addTest("fromNumber: creates from negative number", function()
	local num = AlyaNum.new(-10)
	assertEqual(num:toNumber(), -10)
end)

addTest("fromString: creates from string", function()
	local num = AlyaNum.fromString("12345")
	assertEqual(num:toNumber(), 12345)
end)

addTest("fromString: handles negative strings", function()
	local num = AlyaNum.fromString("-67890")
	assertEqual(num:toNumber(), -67890)
end)

addTest("fromString: handles zero string", function()
	local num = AlyaNum.fromString("0")
	assertEqual(num:toNumber(), 0)
end)

addTest("scientificNotation: parses scientific notation", function()
	local num = AlyaNum.fromScientific("1.23e5")
	assertClose(num:toNumber(), 123000)
end)

addTest("scientificNotation: handles negative signs in strings", function()
	local num = AlyaNum.fromScientific("-5.678")
	assertClose(num:toNumber(), -5.678)
end)

addTest("scientificNotation: handles scientific notation in various formats", function()
	local cases = {
		{ input = "1.23e+45", expected = 1.23e45 },
		{ input = "1.23e-5", expected = 1.23e-5 },
		{ input = "1e10", expected = 1e10 }
	}
	for _, case in ipairs(cases) do
		local num = AlyaNum.fromScientific(case.input)
		assertClose(num:toNumber() / case.expected, 1)
	end
end)

runTests()