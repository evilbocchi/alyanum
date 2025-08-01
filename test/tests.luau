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

function assertEquals(actual, expected, msg)
	if not actual:equals(expected) then
		error((msg or "") .. " Expected " .. tostring(expected:toString()) .. ", got " .. tostring(actual:toString()), 2)
	end
end

function assertMoreThan(actual, expected, msg)
	if not actual:moreThan(expected) then
		error((msg or "") .. " Expected " .. tostring(actual:toString()) .. " > " .. tostring(expected:toString()), 2)
	end
end

function assertLessThan(actual, expected, msg)
	if not actual:lessThan(expected) then
		error((msg or "") .. " Expected " .. tostring(actual:toString()) .. " < " .. tostring(expected:toString()), 2)
	end
end

function assertMoreEquals(actual, expected, msg)
	if not actual:moreEquals(expected) then
		error((msg or "") .. " Expected " .. tostring(actual:toString()) .. " >= " .. tostring(expected:toString()), 2)
	end
end

function assertLessEquals(actual, expected, msg)
	if not actual:lessEquals(expected) then
		error((msg or "") .. " Expected " .. tostring(actual:toString()) .. " <= " .. tostring(expected:toString()), 2)
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

--- Mathematical Properties Tests

-- Identity Tests
addTest("identity: additive identity", function()
	local a = AlyaNum.new(42)
	local zero = AlyaNum.new(0)
	assertEquals(a:add(zero), a, "a + 0 should equal a")
	assertEquals(zero:add(a), a, "0 + a should equal a")
end)

addTest("identity: multiplicative identity", function()
	local a = AlyaNum.new(42)
	local one = AlyaNum.new(1)
	assertEquals(a:mul(one), a, "a * 1 should equal a")
	assertEquals(one:mul(a), a, "1 * a should equal a")
end)

addTest("identity: exponentiation identity", function()
	local a = AlyaNum.new(42)
	local one = AlyaNum.new(1)
	local zero = AlyaNum.new(0)
	assertEquals(a:pow(one), a, "a^1 should equal a")
	assertEquals(a:pow(zero), one, "a^0 should equal 1")
end)

-- Commutativity Tests
addTest("commutativity: addition", function()
	local a = AlyaNum.new(13)
	local b = AlyaNum.new(27)
	assertEquals(a:add(b), b:add(a), "a + b should equal b + a")
end)

addTest("commutativity: multiplication", function()
	local a = AlyaNum.new(7)
	local b = AlyaNum.new(11)
	assertEquals(a:mul(b), b:mul(a), "a * b should equal b * a")
end)

addTest("commutativity: large numbers", function()
	local a = AlyaNum.new(1e100)
	local b = AlyaNum.new(1e150)
	assertEquals(a:add(b), b:add(a), "large a + b should equal b + a")
	assertEquals(a:mul(b), b:mul(a), "large a * b should equal b * a")
end)

-- Associativity Tests
addTest("associativity: addition", function()
	local a = AlyaNum.new(5)
	local b = AlyaNum.new(8)
	local c = AlyaNum.new(12)
	local left = a:add(b):add(c)
	local right = a:add(b:add(c))
	assertEquals(left, right, "(a + b) + c should equal a + (b + c)")
end)

addTest("associativity: multiplication", function()
	local a = AlyaNum.new(3)
	local b = AlyaNum.new(4)
	local c = AlyaNum.new(5)
	local left = a:mul(b):mul(c)
	local right = a:mul(b:mul(c))
	assertEquals(left, right, "(a * b) * c should equal a * (b * c)")
end)

-- Distributivity Tests
addTest("distributivity: multiplication over addition", function()
	local a = AlyaNum.new(3)
	local b = AlyaNum.new(5)
	local c = AlyaNum.new(7)
	local left = a:mul(b:add(c))
	local right = a:mul(b):add(a:mul(c))
	assertEquals(left, right, "a * (b + c) should equal (a * b) + (a * c)")
end)

-- Inverse Operation Tests
addTest("inverse: addition and subtraction", function()
	local a = AlyaNum.new(42)
	local b = AlyaNum.new(17)
	local result = a:add(b):sub(b)
	assertEquals(result, a, "(a + b) - b should equal a")
end)

addTest("inverse: multiplication and division", function()
	local a = AlyaNum.new(84)
	local b = AlyaNum.new(7)
	local result = a:mul(b):div(b)
	assertEquals(result, a, "(a * b) / b should equal a")
end)

addTest("inverse: power and root", function()
	local a = AlyaNum.new(8)
	local b = AlyaNum.new(3)
	local result = a:pow(b):root(b)
	assertClose(result:toNumber(), a:toNumber(), 1e-10, "a^b root b should equal a")
end)

--- Large Number Tests

addTest("large: basic operations with googol", function()
	local googol = AlyaNum.new(10):pow(AlyaNum.new(100))
	local two = AlyaNum.new(2)
	
	-- Test basic operations
	local doubled = googol:mul(two)
	local halved = doubled:div(two)
	assertEquals(halved, googol, "Large number multiplication/division should be reversible")
end)

addTest("large: tetration basic", function()
	local two = AlyaNum.new(2)
	local three = AlyaNum.new(3)
	local four = AlyaNum.new(4)
	
	-- 2^^3 = 2^(2^2) = 2^4 = 16
	local tet_result = two:tet(three)
	local expected = AlyaNum.new(16)
	assertEquals(tet_result, expected, "2^^3 should equal 16")
	
	-- 2^^4 = 2^(2^(2^2)) = 2^16 = 65536
	local tet4_result = two:tet(four)
	local expected4 = AlyaNum.new(65536)
	assertEquals(tet4_result, expected4, "2^^4 should equal 65536")
end)

addTest("large: pentation basic", function()
	local two = AlyaNum.new(2)
	local three = AlyaNum.new(3)
	
	-- 2^^^3 = 2^^(2^^2) = 2^^4 = 65536
	local pent_result = two:pent(three)
	local expected = AlyaNum.new(65536)
	assertEquals(pent_result, expected, "2^^^3 should equal 65536")
end)

addTest("large: hexation basic", function()
	local two = AlyaNum.new(2)
	local three = AlyaNum.new(3)
	
	-- 2^^^^3 = 2^^^(2^^^2) = 2^^^4, which should be a very large number
	local hex_result = two:hext(three)
	assertMoreThan(hex_result, AlyaNum.new(65536), "2^^^^3 should be larger than 65536")
end)

addTest("large: extreme numbers within safe limit", function()
	-- Test numbers approaching the safe limits mentioned in the code
	local large_exp = AlyaNum.new({sign = 1, multiplicand = 1000, exponent = 100, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	local larger_exp = AlyaNum.new({sign = 1, multiplicand = 2000, exponent = 100, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	
	-- Test basic operations
	assertMoreThan(larger_exp, large_exp, "Larger exponent number should be greater")
	
	local sum = large_exp:add(larger_exp)
	assertMoreThan(sum, larger_exp, "Sum should be greater than either addend")
end)

addTest("large: tetration with moderate values", function()
	-- Test tetration with values that stay within reasonable bounds
	local base = AlyaNum.new(3)
	local height = AlyaNum.new(3)
	
	-- 3^^3 = 3^(3^3) = 3^27 = 7625597484987
	local result = base:tet(height)
	assertMoreThan(result, AlyaNum.new(1e12), "3^^3 should be very large")
end)

addTest("large: operations with scientific notation", function()
	local huge1 = AlyaNum.fromScientific("1e1000")
	local huge2 = AlyaNum.fromScientific("2e1000")
	
	-- Test that operations work with very large numbers
	local sum = huge1:add(huge2)
	assertMoreThan(sum, huge2, "Sum of huge numbers should be larger")
	
	local product = huge1:mul(huge2)
	assertMoreThan(product, sum, "Product should be much larger than sum")
end)

addTest("large: hyperoperations maintain properties", function()
	local a = AlyaNum.new(2)
	local b = AlyaNum.new(3)
	local c = AlyaNum.new(2)
	
	-- Test that tetration with same base and height gives same result
	local tet1 = a:tet(b)
	local tet2 = c:tet(b)
	assertEquals(tet1, tet2, "Same tetration should give same result")
end)

addTest("large: numbers approaching 10^^^^10 limit", function()
	-- Test numbers with significant hyperoperation levels but within safe bounds
	local near_limit = AlyaNum.new({
		sign = 1, 
		multiplicand = 100, 
		exponent = 10, 
		tetrate = 5, 
		pentate = 3, 
		hexate = 2, 
		heptate = 0
	})
	
	-- Test basic operations work
	local doubled = near_limit:mul(AlyaNum.new(2))
	assertMoreThan(doubled, near_limit, "Operations should work on extreme numbers")
	
	-- Test string conversion works
	local str = near_limit:toString()
	assert(type(str) == "string" and #str > 0, "Should convert to string")
end)

--- Edge Cases and Boundary Conditions

addTest("edge: zero in various operations", function()
	local zero = AlyaNum.new(0)
	local nonzero = AlyaNum.new(42)
	
	-- Test zero behavior
	assertEquals(zero:mul(nonzero), zero, "0 * a should equal 0")
	assertEquals(zero:pow(nonzero), zero, "0^a should equal 0 (for positive a)")
	assertEquals(nonzero:pow(zero), AlyaNum.new(1), "a^0 should equal 1")
end)

addTest("edge: one in hyperoperations", function()
	local one = AlyaNum.new(1)
	local any = AlyaNum.new(42)
	
	-- Test one behavior in hyperoperations
	assertEquals(one:tet(any), one, "1^^a should equal 1")
	assertEquals(one:pent(any), one, "1^^^a should equal 1")
	assertEquals(one:hext(any), one, "1^^^^a should equal 1")
end)

addTest("edge: negative numbers", function()
	local neg = AlyaNum.new(-5)
	local pos = AlyaNum.new(3)
	
	-- Test negative number operations
	local sum = neg:add(pos)
	assertEqual(sum:toNumber(), -2)
	
	local product = neg:mul(pos)
	assertEqual(product:toNumber(), -15)
	
	-- Test absolute value
	assertEquals(neg:abs(), AlyaNum.new(5), "abs(-5) should equal 5")
end)

addTest("edge: very small numbers", function()
	local tiny = AlyaNum.new(1e-100)
	local small = AlyaNum.new(1e-50)
	
	-- Test operations with very small numbers
	local sum = tiny:add(small)
	assertMoreThan(sum, small, "Sum should be dominated by larger number")
	
	local product = tiny:mul(small)
	assertLessThan(product, tiny, "Product should be smaller")
end)

addTest("edge: comparison edge cases", function()
	local a = AlyaNum.new(1)
	local b = AlyaNum.new(1)
	local c = AlyaNum.new(2)
	
	-- Test equality and comparison
	assertEquals(a, b, "Equal numbers should be equal")
	assert(not a:equals(c), "Different numbers should not be equal")
	assertLessThan(a, c, "1 should be less than 2")
	assertMoreThan(c, a, "2 should be greater than 1")
	assertLessEquals(a, b, "Equal numbers satisfy <=")
	assertMoreEquals(a, b, "Equal numbers satisfy >=")
end)

addTest("edge: string parsing edge cases", function()
	-- Test various string formats
	local cases = {
		"0", "1", "-1", "123.456", "-123.456",
		"1e5", "-1e5", "1.5e10", "-2.3e-5"
	}
	
	for _, case in ipairs(cases) do
		local num = AlyaNum.fromString(case)
		assert(num ~= nil, "Should parse string: " .. case)
		local expected = tonumber(case)
		if expected and math.abs(expected) < 1e308 then
			assertClose(num:toNumber(), expected, 1e-10, "Parsed value should match for: " .. case)
		end
	end
end)

addTest("edge: min/max operations", function()
	local a = AlyaNum.new(5)
	local b = AlyaNum.new(10)
	
	assertEquals(a:min(b), a, "min(5,10) should equal 5")
	assertEquals(a:max(b), b, "max(5,10) should equal 10")
	
	local min_val, max_val = a:minmax(b)
	assertEquals(min_val, a, "minmax should return min first")
	assertEquals(max_val, b, "minmax should return max second")
end)

runTests()