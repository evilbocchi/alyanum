local AlyaNum = require("../src")
local harness = require("./harness")
local describe = harness.describe
local test = harness.test
local expect = harness.expect

describe("Construction", function()
	test("fromNumber: creates from number", function()
		local num = AlyaNum.new(5)
		expect(num:toNumber()):toBe(5)
	end)

	test("fromNumber: creates from negative number", function()
		local num = AlyaNum.new(-10)
		expect(num:toNumber()):toBe(-10)
	end)

	test("fromString: creates from string", function()
		local num = AlyaNum.fromString("12345")
		expect(num:toNumber()):toBe(12345)
	end)

	test("fromString: handles negative strings", function()
		local num = AlyaNum.fromString("-67890")
		expect(num:toNumber()):toBe(-67890)
	end)

	test("fromString: handles zero string", function()
		local num = AlyaNum.fromString("0")
		expect(num:toNumber()):toBe(0)
	end)

	test("scientificNotation: parses scientific notation", function()
		local num = AlyaNum.fromScientific("1.23e5")
		expect(num:toNumber()):toBeCloseTo(123000, 9)
	end)

	test("scientificNotation: handles negative signs in strings", function()
		local num = AlyaNum.fromScientific("-5.678")
		expect(num:toNumber()):toBeCloseTo(-5.678, 9)
	end)

	test("scientificNotation: handles scientific notation in various formats", function()
		local cases = {
			{ input = "1.23e+45", expected = 1.23e45 },
			{ input = "1.23e-5", expected = 1.23e-5 },
			{ input = "1e10", expected = 1e10 },
		}
		for _, case in ipairs(cases) do
			local num = AlyaNum.fromScientific(case.input)
			expect(num:toNumber() / case.expected):toBeCloseTo(1, 9)
		end
	end)

	test("scientificNotation: accepts uppercase E", function()
		expect(AlyaNum.fromScientific("1.25E3"):toNumber()):toBeCloseTo(1250, 9)
		expect(AlyaNum.fromString("-2.5E-2"):toNumber()):toBeCloseTo(-0.025, 9)
	end)
end)

describe("Arithmetic", function()
	test("add: simple addition", function()
		local a = AlyaNum.new(2)
		local b = AlyaNum.new(3)
		expect((a + b):toNumber()):toBe(5)
	end)

	test("sub: simple subtraction", function()
		local a = AlyaNum.new(10)
		local b = AlyaNum.new(4)
		expect((a - b):toNumber()):toBe(6)
	end)

	test("mul: simple multiplication", function()
		local a = AlyaNum.new(7)
		local b = AlyaNum.new(6)
		expect((a * b):toNumber()):toBe(42)
	end)

	test("div: simple division", function()
		local a = AlyaNum.new(20)
		local b = AlyaNum.new(5)
		expect((a / b):toNumber()):toBe(4)
	end)

	test("pow: simple power", function()
		local a = AlyaNum.new(2)
		local b = AlyaNum.new(8)
		expect((a ^ b):toNumber()):toBe(256)
	end)

	test("mod: simple modulo", function()
		local a = AlyaNum.new(17)
		local b = AlyaNum.new(5)
		expect((a % b):toNumber()):toBe(2)
	end)

	test("unary minus", function()
		local a = AlyaNum.new(9)
		expect((-a):toNumber()):toBe(-9)
	end)

	test("reciprocal", function()
		local a = AlyaNum.new(4)
		expect(a:reciprocal():toNumber()):toBeCloseTo(0.25, 9)
	end)
end)

describe("Negative numbers", function()
	test("construction: preserves negative signs across representations", function()
		expect(AlyaNum.new(-42):toNumber()):toBe(-42)
		expect(AlyaNum.fromString("-42.5"):toNumber()):toBeCloseTo(-42.5, 9)
		expect(AlyaNum.fromScientific("-1.25e3"):toNumber()):toBeCloseTo(-1250, 9)
		expect(AlyaNum.fromOnoe({ mantissa = -2.5, exponent = 3 }):toNumber()):toBeCloseTo(-2500, 9)
		expect(AlyaNum.fromOmega({ -1, { 42, 0, 0, 0, 0, 0 } }):toNumber()):toBe(-42)
	end)

	test("construction: parses negative suffixes", function()
		expect(AlyaNum.fromString("-2.5K"):toNumber()):toBeCloseTo(-2500, 9)
		expect(AlyaNum.fromString("-1.2M"):toNumber()):toBeCloseTo(-1200000, 9)
	end)

	test("addition: handles two negative operands", function()
		expect(AlyaNum.new(-12):add(-8):toNumber()):toBe(-20)
		expect((AlyaNum.new(-12) + AlyaNum.new(-8)):toNumber()):toBe(-20)
	end)

	test("subtraction: handles negative operands", function()
		expect(AlyaNum.new(-12):sub(-8):toNumber()):toBe(-4)
		expect(AlyaNum.new(12):sub(-8):toNumber()):toBe(20)
	end)

	test("multiplication: covers both sign combinations", function()
		expect(AlyaNum.new(-12):mul(-8):toNumber()):toBe(96)
		expect(AlyaNum.new(-12):mul(8):toNumber()):toBe(-96)
		expect((AlyaNum.new(-12) * AlyaNum.new(-8)):toNumber()):toBe(96)
	end)

	test("division: covers both sign combinations", function()
		expect(AlyaNum.new(-12):div(-4):toNumber()):toBe(3)
		expect(AlyaNum.new(-12):div(4):toNumber()):toBe(-3)
		expect((AlyaNum.new(-12) / AlyaNum.new(-4)):toNumber()):toBe(3)
	end)

	test("power: preserves parity for negative bases", function()
		expect(AlyaNum.new(-2):pow(3):toNumber()):toBeCloseTo(-8, 12)
		expect((AlyaNum.new(-2) ^ AlyaNum.new(4)):toNumber()):toBeCloseTo(16, 12)
		expect(AlyaNum.new(-2):pow(-3):toNumber()):toBeCloseTo(-0.125, 9)
	end)

	test("modulo: preserves the dividend sign", function()
		expect(AlyaNum.new(-17):mod(5):toNumber()):toBe(-2)
		expect(AlyaNum.new(17):mod(-5):toNumber()):toBe(2)
		expect((AlyaNum.new(-17) % AlyaNum.new(-5)):toNumber()):toBe(-2)
	end)

	test("unary and reciprocal: flip and retain negative signs", function()
		expect(AlyaNum.new(-9):unary():toNumber()):toBe(9)
		expect((-AlyaNum.new(-9)):toNumber()):toBe(9)
		expect(AlyaNum.new(-4):reciprocal():toNumber()):toBeCloseTo(-0.25, 9)
	end)

	test("root: supports odd roots of negative values", function()
		expect(AlyaNum.new(-8):root(3):toNumber()):toBeCloseTo(-2, 9)
		expect(AlyaNum.new(-32):root(5):toNumber()):toBeCloseTo(-2, 9)
	end)

	test("comparison: orders negative, zero, and positive values", function()
		local negativeFive = AlyaNum.new(-5)
		local negativeThree = AlyaNum.new(-3)
		local zero = AlyaNum.new(0)

		expect(negativeFive:eq(-5)):toBe(true)
		expect(negativeFive:compare(negativeThree)):toBe(-1)
		expect(negativeThree:compare(negativeFive)):toBe(1)
		expect(negativeFive:lt(negativeThree)):toBe(true)
		expect(negativeFive:le(negativeThree)):toBe(true)
		expect(negativeThree:mt(negativeFive)):toBe(true)
		expect(negativeThree:me(negativeFive)):toBe(true)
		expect(negativeFive:lt(zero)):toBe(true)
		expect(zero:mt(negativeFive)):toBe(true)
	end)

	test("absolute value and extrema: use magnitudes correctly", function()
		local negativeFive = AlyaNum.new(-5)
		local negativeThree = AlyaNum.new(-3)

		expect(negativeFive:abs()):toEqual(AlyaNum.new(5))
		expect(negativeFive:min(negativeThree)):toEqual(negativeFive)
		expect(negativeFive:max(negativeThree)):toEqual(negativeThree)
		local minValue, maxValue = negativeFive:minmax(negativeThree)
		expect(minValue):toEqual(negativeFive)
		expect(maxValue):toEqual(negativeThree)
	end)

	test("rounding and integer checks: handle negative fractions", function()
		expect(AlyaNum.new(-3.7):floor():toNumber()):toBe(-4)
		expect(AlyaNum.new(-3.7):round():toNumber()):toBe(-4)
		expect(AlyaNum.new(-3.7):ceil():toNumber()):toBe(-3)
		expect(AlyaNum.new(-4):isInteger()):toBe(true)
		expect(AlyaNum.new(-3.7):isInteger()):toBe(false)
	end)

	test("logarithms: use the negative-domain sentinels", function()
		expect(AlyaNum.new(-100):log10()):toEqual(AlyaNum.new(0))
		expect(AlyaNum.new(-100):log(10)):toEqual(AlyaNum.new(0))
		expect(AlyaNum.new(-100):slog(10)):toEqual(AlyaNum.new(-1))
		expect(AlyaNum.new(-100):pentlog(10)):toEqual(AlyaNum.new(-1))
		expect(AlyaNum.new(-100):hextlog(10)):toEqual(AlyaNum.new(-1))
	end)

	test("hyperoperations: retain negative bases at height one", function()
		local negativeTwo = AlyaNum.new(-2)

		expect(negativeTwo:tet(1)):toEqual(negativeTwo)
		expect(negativeTwo:pent(1)):toEqual(negativeTwo)
		expect(negativeTwo:hext(1)):toEqual(negativeTwo)
	end)

	test("hyperoperations: handle negative heights", function()
		local two = AlyaNum.new(2)

		expect(two:tet(-1)):toEqual(AlyaNum.new(0))
		expect(two:pent(-1)):toEqual(AlyaNum.new(0))
		expect(two:hext(-1)):toEqual(AlyaNum.new(0))
	end)

	test("lambertw: computes a valid negative-domain value", function()
		expect(AlyaNum.new(-0.1):lambertw():toNumber()):toBeCloseTo(-0.111832559, 8)
	end)

	test("string conversion: keeps negative signs in every notation", function()
		expect(AlyaNum.new(-0.25):toString()):toBe("-0.25")
		expect(AlyaNum.new(-1e6):toSuffix()):toBe("-1M")
		expect(AlyaNum.new(-1e12):toScientific()):toBe("-1e12")
		expect(AlyaNum.new(-1e100):toEChain()):toBe("-e100")
	end)

	test("serialization: preserves negative signs", function()
		local negative = AlyaNum.new(-20)
		local mantissa, exponent = negative:toSerika()
		local single = negative:toSingle()
		local base = AlyaNum.new(-20):toBaseAlya()

		expect(mantissa):toBe(-2)
		expect(exponent):toBe(1)
		expect(base.sign):toBe(-1)
		expect(AlyaNum.fromSingle(single)):toEqual(negative)
	end)

	test("aliases and metamethods: remain negative-aware", function()
		local negative = AlyaNum.new(-7)

		expect(negative:unm():toNumber()):toBe(7)
		expect(negative:recip():toNumber()):toBeCloseTo(-1 / 7, 9)
		expect(negative:revert()):toBe(-7)
		expect((negative .. "x")):toBe("-7x")
	end)
end)

describe("Comparison", function()
	test("equals: equal numbers", function()
		local a = AlyaNum.new(123)
		local b = AlyaNum.new(123)
		expect(a:eq(b)):toBe(true)
	end)

	test("lessThan: true", function()
		local a = AlyaNum.new(1)
		local b = AlyaNum.new(2)
		expect(a:lt(b)):toBe(true)
	end)

	test("moreThan: true", function()
		local a = AlyaNum.new(5)
		local b = AlyaNum.new(3)
		expect(a:mt(b)):toBe(true)
	end)

	test("lessEquals: equal", function()
		local a = AlyaNum.new(7)
		local b = AlyaNum.new(7)
		expect(a:le(b)):toBe(true)
	end)

	test("moreEquals: equal", function()
		local a = AlyaNum.new(8)
		local b = AlyaNum.new(8)
		expect(a:me(b)):toBe(true)
	end)
end)

describe("String conversion", function()
	test("toString: small number", function()
		local a = AlyaNum.new(42)
		expect(a:toString()):toBe("42")
	end)

	test("toString: negative number", function()
		local a = AlyaNum.new(-123)
		expect(a:toString()):toBe("-123")
	end)

	test("toSuffix: large number", function()
		local a = AlyaNum.new(1e6)
		expect(a:toSuffix():find("M")):toBeTruthy()
	end)

	test("toScientific: large number", function()
		local a = AlyaNum.new(1e12)
		expect(a:toScientific():find("e")):toBeTruthy()
	end)

	test("toEChain: very large number", function()
		local a = AlyaNum.fromScientific("1e100")
		local b = AlyaNum.fromScientific("1e100")
		local c = a ^ b
		expect(c:toEChain():sub(1, 2)):toBe("ee")
	end)
end)

describe("Edge cases", function()
	test("zero: addition", function()
		local a = AlyaNum.new(0)
		local b = AlyaNum.new(5)
		expect((a + b):toNumber()):toBe(5)
	end)

	test("zero: multiplication", function()
		local a = AlyaNum.new(0)
		local b = AlyaNum.new(123)
		expect((a * b):toNumber()):toBe(0)
	end)

	test("negative: multiplication", function()
		local a = AlyaNum.new(-3)
		local b = AlyaNum.new(7)
		expect((a * b):toNumber()):toBe(-21)
	end)

	test("negative: division", function()
		local a = AlyaNum.new(-12)
		local b = AlyaNum.new(3)
		expect((a / b):toNumber()):toBe(-4)
	end)

	test("isInteger: integer", function()
		local a = AlyaNum.new(10)
		expect(a:isInteger()):toBe(true)
	end)

	test("isInteger: not integer", function()
		local a = AlyaNum.new(3.14)
		expect(a:isInteger()):toBe(false)
	end)

	test("root: square root", function()
		local a = AlyaNum.new(16)
		local b = AlyaNum.new(2)
		expect(a:root(b):toNumber()):toBeCloseTo(4, 9)
	end)

	test("pow: negative exponent", function()
		local a = AlyaNum.new(2)
		local b = AlyaNum.new(-3)
		expect((a ^ b):toNumber()):toBeCloseTo(0.125, 9)
	end)

	test("fromString: suffix", function()
		local num = AlyaNum.fromString("1M")
		expect(num:toNumber()):toBe(1e6)
	end)

	test("fromString: scientific", function()
		local num = AlyaNum.fromString("2.5e3")
		expect(num:toNumber()):toBeCloseTo(2500, 9)
	end)

	test("fromString: negative scientific", function()
		local num = AlyaNum.fromString("-1.2e2")
		expect(num:toNumber()):toBeCloseTo(-120, 9)
	end)

	test("fromString: zero", function()
		local num = AlyaNum.fromString("0")
		expect(num:toNumber()):toBe(0)
	end)

	test("fromString: fallback", function()
		local num = AlyaNum.fromString("999")
		expect(num:toNumber()):toBe(999)
	end)
end)

describe("Mathematical properties", function()
	test("identity: additive identity", function()
		local a = AlyaNum.new(42)
		local zero = AlyaNum.new(0)
		expect(a:add(zero)):toEqual(a, "a + 0 should equal a")
		expect(zero:add(a)):toEqual(a, "0 + a should equal a")
	end)

	test("identity: multiplicative identity", function()
		local a = AlyaNum.new(42)
		local one = AlyaNum.new(1)
		expect(a:mul(one)):toEqual(a, "a * 1 should equal a")
		expect(one:mul(a)):toEqual(a, "1 * a should equal a")
	end)

	test("identity: exponentiation identity", function()
		local a = AlyaNum.new(42)
		local one = AlyaNum.new(1)
		local zero = AlyaNum.new(0)
		expect(a:pow(one)):toEqual(a, "a^1 should equal a")
		expect(a:pow(zero)):toEqual(one, "a^0 should equal 1")
	end)

	test("commutativity: addition", function()
		local a = AlyaNum.new(13)
		local b = AlyaNum.new(27)
		expect(a:add(b)):toEqual(b:add(a), "a + b should equal b + a")
	end)

	test("commutativity: multiplication", function()
		local a = AlyaNum.new(7)
		local b = AlyaNum.new(11)
		expect(a:mul(b)):toEqual(b:mul(a), "a * b should equal b * a")
	end)

	test("commutativity: large numbers", function()
		local a = AlyaNum.new(1e100)
		local b = AlyaNum.new(1e150)
		expect(a:add(b)):toEqual(b:add(a), "large a + b should equal b + a")
		expect(a:mul(b)):toEqual(b:mul(a), "large a * b should equal b * a")
	end)

	test("associativity: addition", function()
		local a = AlyaNum.new(5)
		local b = AlyaNum.new(8)
		local c = AlyaNum.new(12)
		local left = a:add(b):add(c)
		local right = a:add(b:add(c))
		expect(left):toEqual(right, "(a + b) + c should equal a + (b + c)")
	end)

	test("associativity: multiplication", function()
		local a = AlyaNum.new(3)
		local b = AlyaNum.new(4)
		local c = AlyaNum.new(5)
		local left = a:mul(b):mul(c)
		local right = a:mul(b:mul(c))
		expect(left):toEqual(right, "(a * b) * c should equal a * (b * c)")
	end)

	test("distributivity: multiplication over addition", function()
		local a = AlyaNum.new(3)
		local b = AlyaNum.new(5)
		local c = AlyaNum.new(7)
		local left = a:mul(b:add(c))
		local right = a:mul(b):add(a:mul(c))
		expect(left):toEqual(right, "a * (b + c) should equal (a * b) + (a * c)")
	end)

	test("inverse: addition and subtraction", function()
		local a = AlyaNum.new(42)
		local b = AlyaNum.new(17)
		local result = a:add(b):sub(b)
		expect(result):toEqual(a, "(a + b) - b should equal a")
	end)

	test("inverse: multiplication and division", function()
		local a = AlyaNum.new(84)
		local b = AlyaNum.new(7)
		local result = a:mul(b):div(b)
		expect(result):toEqual(a, "(a * b) / b should equal a")
	end)

	test("inverse: power and root", function()
		local a = AlyaNum.new(8)
		local b = AlyaNum.new(3)
		local result = a:pow(b):root(b)
		expect(result:toNumber()):toBeCloseTo(a:toNumber(), 10, "a^b root b should equal a")
	end)
end)

describe("Large numbers", function()
	test("large: basic operations with googol", function()
		local googol = AlyaNum.new(10):pow(AlyaNum.new(100))
		local two = AlyaNum.new(2)

		local doubled = googol:mul(two)
		local halved = doubled:div(two)
		expect(halved):toEqual(googol, "Large number multiplication/division should be reversible")
	end)

	test("large: tetration basic", function()
		local two = AlyaNum.new(2)
		local three = AlyaNum.new(3)
		local four = AlyaNum.new(4)

		-- 2^^3 = 2^(2^2) = 2^4 = 16
		local tet_result = two:tet(three)
		local expected = AlyaNum.new(16)
		expect(tet_result):toEqual(expected, "2^^3 should equal 16")

		-- 2^^4 = 2^(2^(2^2)) = 2^16 = 65536
		local tet4_result = two:tet(four)
		local expected4 = AlyaNum.new(65536)
		expect(tet4_result):toEqual(expected4, "2^^4 should equal 65536")
	end)

	test("large: pentation basic", function()
		local two = AlyaNum.new(2)
		local three = AlyaNum.new(3)

		-- 2^^^3 = 2^^(2^^2) = 2^^4 = 65536
		local pent_result = two:pent(three)
		local expected = AlyaNum.new(65536)
		expect(pent_result):toEqual(expected, "2^^^3 should equal 65536")
	end)

	test("large: hexation basic", function()
		local two = AlyaNum.new(2)
		local three = AlyaNum.new(3)

		-- 2^^^^3 = 2^^^(2^^^2) = 2^^^4, which should be a very large number
		local hex_result = two:hext(three)
		expect(hex_result):toBeGreaterThan(AlyaNum.new(65536), "2^^^^3 should be larger than 65536")
	end)

	test("large: extreme numbers within safe limit", function()
		-- Test numbers approaching the safe limits mentioned in the code
		local large_exp = AlyaNum.new({
			sign = 1,
			multiplicand = 100,
			exponent = 1,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local larger_exp = AlyaNum.new({
			sign = 1,
			multiplicand = 101,
			exponent = 1,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})

		-- Test basic operations
		expect(larger_exp):toBeGreaterThan(large_exp, "Larger exponent number should be greater")

		local sum = large_exp:add(larger_exp)
		expect(sum):toBeGreaterThan(larger_exp, "Sum should be greater than either addend")
	end)

	test("large: tetration with moderate values", function()
		-- Test tetration with values that stay within reasonable bounds
		local base = AlyaNum.new(3)
		local height = AlyaNum.new(3)

		-- 3^^3 = 3^(3^3) = 3^27 = 7625597484987
		local result = base:tet(height)
		expect(result):toBeGreaterThan(AlyaNum.new(1e12), "3^^3 should be very large")
	end)

	test("large: operations with scientific notation", function()
		local huge1 = AlyaNum.fromScientific("1e1000")
		local huge2 = AlyaNum.fromScientific("2e1000")

		-- Test that operations work with very large numbers
		local sum = huge1:add(huge2)
		expect(sum):toBeGreaterThan(huge2, "Sum of huge numbers should be larger")

		local product = huge1:mul(huge2)
		expect(product):toBeGreaterThan(sum, "Product should be much larger than sum")
	end)

	test("large: hyperoperations maintain properties", function()
		local a = AlyaNum.new(2)
		local b = AlyaNum.new(3)
		local c = AlyaNum.new(2)

		-- Test that tetration with same base and height gives same result
		local tet1 = a:tet(b)
		local tet2 = c:tet(b)
		expect(tet1):toEqual(tet2, "Same tetration should give same result")
	end)

	test("large: numbers approaching 10^^^^10 limit", function()
		-- Test numbers with significant hyperoperation levels but within safe bounds
		local near_limit1 = AlyaNum.new({
			sign = 1,
			multiplicand = 100,
			exponent = 10,
			tetrate = 5,
			pentate = 3,
			hexate = 2,
			heptate = 0,
		})

		local near_limit2 = AlyaNum.new({
			sign = 1,
			multiplicand = 400,
			exponent = 10,
			tetrate = 5,
			pentate = 3,
			hexate = 2,
			heptate = 0,
		})

		-- Test basic operations work
		local doubled = near_limit1:mul(near_limit2)
		expect(doubled):toBeGreaterThanOrEqual(near_limit2, "Operations should work on extreme numbers")

		-- Test string conversion works
		local str = near_limit1:toString()
		expect(type(str) == "string" and #str > 0):toBeTruthy("Should convert to string")
	end)
end)

describe("Boundary conditions", function()
	test("edge: zero in various operations", function()
		local zero = AlyaNum.new(0)
		local nonzero = AlyaNum.new(42)

		-- Test zero behavior
		expect(zero:mul(nonzero)):toEqual(zero, "0 * a should equal 0")
		expect(zero:pow(nonzero)):toEqual(zero, "0^a should equal 0 (for positive a)")
		expect(nonzero:pow(zero)):toEqual(AlyaNum.new(1), "a^0 should equal 1")
	end)

	test("edge: one in hyperoperations", function()
		local one = AlyaNum.new(1)
		local any = AlyaNum.new(42)

		-- Test one behavior in hyperoperations
		expect(one:tet(any)):toEqual(one, "1^^a should equal 1")
		expect(one:pent(any)):toEqual(one, "1^^^a should equal 1")
		expect(one:hext(any)):toEqual(one, "1^^^^a should equal 1")
	end)

	test("edge: negative numbers", function()
		local neg = AlyaNum.new(-5)
		local pos = AlyaNum.new(3)

		-- Test negative number operations
		local sum = neg:add(pos)
		expect(sum:toNumber()):toBe(-2)

		local product = neg:mul(pos)
		expect(product:toNumber()):toBe(-15)

		-- Test absolute value
		expect(neg:abs()):toEqual(AlyaNum.new(5), "abs(-5) should equal 5")
	end)

	test("edge: very small numbers", function()
		local tiny = AlyaNum.new(1e-100)
		local small = AlyaNum.new(1e-50)

		-- Test operations with very small numbers
		local sum = tiny:add(small)
		expect(sum):toBeGreaterThanOrEqual(small, "Sum should be dominated by larger number")

		local product = tiny:mul(small)
		expect(product):toBeLessThan(tiny, "Product should be smaller")
	end)

	test("edge: comparison edge cases", function()
		local a = AlyaNum.new(1)
		local b = AlyaNum.new(1)
		local c = AlyaNum.new(2)

		-- Test equality and comparison
		expect(a):toEqual(b, "Equal numbers should be equal")
		expect(a:equals(c)):toBe(false, "Different numbers should not be equal")
		expect(a):toBeLessThan(c, "1 should be less than 2")
		expect(c):toBeGreaterThan(a, "2 should be greater than 1")
		expect(a):toBeLessThanOrEqual(b, "Equal numbers satisfy <=")
		expect(a):toBeGreaterThanOrEqual(b, "Equal numbers satisfy >=")
	end)

	test("edge: string parsing edge cases", function()
		-- Test various string formats
		local cases = {
			"0",
			"1",
			"-1",
			"123.456",
			"-123.456",
			"1e5",
			"-1e5",
			"1.5e10",
			"-2.3e-5",
		}

		for _, case in ipairs(cases) do
			local num = AlyaNum.fromString(case)
			expect(num):toBeDefined("Should parse string: " .. case)
			local expected = tonumber(case)
			if expected and math.abs(expected) < 1e308 then
				expect(num:toNumber()):toBeCloseTo(expected, 5, "Parsed value should match for: " .. case)
			end
		end
	end)

	test("edge: min/max operations", function()
		local a = AlyaNum.new(5)
		local b = AlyaNum.new(10)

		expect(a:min(b)):toEqual(a, "min(5,10) should equal 5")
		expect(a:max(b)):toEqual(b, "max(5,10) should equal 10")

		local min_val, max_val = a:minmax(b)
		expect(min_val):toEqual(a, "minmax should return min first")
		expect(max_val):toEqual(b, "minmax should return max second")
	end)

	test("edge: lbencode/lbdecode precision", function()
		local a = AlyaNum.new(1)
		expect(AlyaNum.lbdecode(a:lbencode())):toEqual(a, "lbencode/decode should preserve value at this scale")

		local b = AlyaNum.new(5.24)
		expect(AlyaNum.lbdecode(b:lbencode())):toEqual(b, "lbencode/decode should preserve value for small decimals")

		local c = AlyaNum.new(0)
		expect(AlyaNum.lbdecode(c:lbencode())):toEqual(c, "lbencode/decode should preserve zero")

		local d = AlyaNum.new(-20)
		expect(AlyaNum.lbdecode(d:lbencode())):toEqual(d, "lbencode/decode should preserve negative numbers")
	end)

	test("edge: 0e0", function()
		local a = AlyaNum.fromString("0e0")
		expect(a:toNumber()):toBe(0)

		local b = AlyaNum.toSuffix(a)
		expect("0"):toBe(b)
	end)

	test("edge: 1e6 + 50k", function()
		local a = AlyaNum.new(1000000)
		local b = AlyaNum.new(5000)
		local c = a
		for i = 1, 10 do
			c = c:add(b)
		end
		expect(c:toNumber()):toBe(1050000)
	end)

	test("edge: lbdecode(lbencode(0))", function()
		local a = AlyaNum.lbencode(AlyaNum.new(0))
		expect(AlyaNum.lbdecode(a)):toEqual(AlyaNum.new(0))
	end)

	test("format: changeDecimalPoints updates precision", function()
		local value = AlyaNum.new(1009000)
		AlyaNum.changeDecimalPoints(3)
		expect(value:toSuffix()):toBe("1.009M")
		AlyaNum.changeDecimalPoints(2)
		expect(value:toSuffix()):toBe("1.01M")
	end)

	test("googol is 10^100", function()
		expect(AlyaNum.GOOGOL):toEqual(AlyaNum.new(10):pow(100))
	end)
end)
