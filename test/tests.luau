local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")

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
    if failed > 0 then
        process.exit(1)
    else
        process.exit(0)
    end
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

--- Arithmetic

addTest("add: simple addition", function()
	local a = AlyaNum.new(2)
	local b = AlyaNum.new(3)
	assertEqual((a + b):toNumber(), 5)
end)

addTest("sub: simple subtraction", function()
	local a = AlyaNum.new(10)
	local b = AlyaNum.new(4)
	assertEqual((a - b):toNumber(), 6)
end)

addTest("mul: simple multiplication", function()
	local a = AlyaNum.new(7)
	local b = AlyaNum.new(6)
	assertEqual((a * b):toNumber(), 42)
end)

addTest("div: simple division", function()
	local a = AlyaNum.new(20)
	local b = AlyaNum.new(5)
	assertEqual((a / b):toNumber(), 4)
end)

addTest("pow: simple power", function()
	local a = AlyaNum.new(2)
	local b = AlyaNum.new(8)
	assertEqual((a ^ b):toNumber(), 256)
end)

addTest("mod: simple modulo", function()
	local a = AlyaNum.new(17)
	local b = AlyaNum.new(5)
	assertEqual((a % b):toNumber(), 2)
end)

addTest("unary minus", function()
	local a = AlyaNum.new(9)
	assertEqual((-a):toNumber(), -9)
end)

addTest("reciprocal", function()
	local a = AlyaNum.new(4)
	assertClose(a:reciprocal():toNumber(), 0.25)
end)

--- Comparison

addTest("equals: equal numbers", function()
	local a = AlyaNum.new(123)
	local b = AlyaNum.new(123)
	assert(a:eq(b))
end)

addTest("lessThan: true", function()
	local a = AlyaNum.new(1)
	local b = AlyaNum.new(2)
	assert(a:lt(b))
end)

addTest("moreThan: true", function()
	local a = AlyaNum.new(5)
	local b = AlyaNum.new(3)
	assert(a:mt(b))
end)

addTest("lessEquals: equal", function()
	local a = AlyaNum.new(7)
	local b = AlyaNum.new(7)
	assert(a:le(b))
end)

addTest("moreEquals: equal", function()
	local a = AlyaNum.new(8)
	local b = AlyaNum.new(8)
	assert(a:me(b))
end)

--- String conversion

addTest("toString: small number", function()
	local a = AlyaNum.new(42)
	assertEqual(a:toString(), "42")
end)

addTest("toString: negative number", function()
	local a = AlyaNum.new(-123)
	assertEqual(a:toString(), "-123")
end)

addTest("toSuffix: large number", function()
	local a = AlyaNum.new(1e6)
	assert(a:toSuffix():find("M"))
end)

addTest("toScientific: large number", function()
	local a = AlyaNum.new(1e12)
	assert(a:toScientific():find("e"))
end)

addTest("toEChain: very large number", function()
	local a = AlyaNum.fromScientific("1e100")
	local b = AlyaNum.fromScientific("1e100")
	local c = a ^ b
	assert(c:toEChain():sub(1,2) == "ee")
end)

--- Edge cases

addTest("zero: addition", function()
	local a = AlyaNum.new(0)
	local b = AlyaNum.new(5)
	assertEqual((a + b):toNumber(), 5)
end)

addTest("zero: multiplication", function()
	local a = AlyaNum.new(0)
	local b = AlyaNum.new(123)
	assertEqual((a * b):toNumber(), 0)
end)

addTest("negative: multiplication", function()
	local a = AlyaNum.new(-3)
	local b = AlyaNum.new(7)
	assertEqual((a * b):toNumber(), -21)
end)

addTest("negative: division", function()
	local a = AlyaNum.new(-12)
	local b = AlyaNum.new(3)
	assertEqual((a / b):toNumber(), -4)
end)

addTest("isInteger: integer", function()
	local a = AlyaNum.new(10)
	assert(a:isInteger())
end)

addTest("isInteger: not integer", function()
	local a = AlyaNum.new(3.14)
	assert(not a:isInteger())
end)

addTest("root: square root", function()
	local a = AlyaNum.new(16)
	local b = AlyaNum.new(2)
	assertClose(a:root(b):toNumber(), 4)
end)

addTest("pow: negative exponent", function()
	local a = AlyaNum.new(2)
	local b = AlyaNum.new(-3)
	assertClose((a ^ b):toNumber(), 0.125)
end)

addTest("fromString: suffix", function()
	local num = AlyaNum.fromString("1M")
	assertEqual(num:toNumber(), 1e6)
end)

addTest("fromString: scientific", function()
	local num = AlyaNum.fromString("2.5e3")
	assertClose(num:toNumber(), 2500)
end)

addTest("fromString: negative scientific", function()
	local num = AlyaNum.fromString("-1.2e2")
	assertClose(num:toNumber(), -120)
end)

addTest("fromString: zero", function()
	local num = AlyaNum.fromString("0")
	assertEqual(num:toNumber(), 0)
end)

addTest("fromString: fallback", function()
	local num = AlyaNum.fromString("999")
	assertEqual(num:toNumber(), 999)
end)

runTests()