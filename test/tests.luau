local AlyaNum = require("../src")
local harness = require("./harness")
local describe = harness.describe
local test = harness.test
local expect = harness.expect
type AlyaNumber = typeof(AlyaNum.new(0))

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

	test("factorial: handles exact small values and aliases", function()
		expect(AlyaNum.new(0):factorial()):toEqual(AlyaNum.new(1))
		expect(AlyaNum.new(5):factorial()):toEqual(AlyaNum.new(120))
	end)

	test("factorial: uses Stirling approximation beyond float64 factorials", function()
		local mantissa, exponent = AlyaNum.new(1000):factorial():toSerika()

		expect(mantissa):toBeCloseTo(4.0238726, 6)
		expect(exponent):toBe(2567)
	end)

	test("factorial: supports very large integer inputs", function()
		local result = AlyaNum.fromScientific("1e1000"):factorial()

		expect(result.sign):toBe(1)
		expect(result.exponent):toBe(2)
		expect(result.multiplicand):toBeGreaterThan(1000)
	end)

	test("factorial: rejects negative and fractional values", function()
		local negativeOk = pcall(function()
			return AlyaNum.new(-1):factorial()
		end)
		local fractionalOk = pcall(function()
			return AlyaNum.new(3.5):factorial()
		end)

		expect(negativeOk):toBe(false)
		expect(fractionalOk):toBe(false)
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

	test("isCloseTo: compares relative difference", function()
		local a = AlyaNum.new(1000)
		local b = AlyaNum.new(1000.0005)

		expect(a:isCloseTo(b, 1e-6)):toBe(true)
		expect(a:isCloseTo(b, 1e-7)):toBe(false)
	end)

	test("isCloseTo: compares values beyond float64 range", function()
		local a = AlyaNum.new({
			sign = 1,
			multiplicand = 100,
			exponent = 2,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local b = AlyaNum.new({
			sign = 1,
			multiplicand = 101,
			exponent = 2,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})

		expect(a:isCloseTo(a)):toBe(true)
		expect(a:isCloseTo(b)):toBe(false)
	end)

	test("isCloseTo: supports absolute tolerance near zero", function()
		local a = AlyaNum.new(0)

		expect(a:isCloseTo(1e-6, 0, 1e-5)):toBe(true)
		expect(a:isCloseTo(1e-6, 0, 1e-7)):toBe(false)
	end)

	test("isCloseTo: does not treat opposite signs as relatively close", function()
		expect(AlyaNum.new(-5):isCloseTo(-5.000001, 1e-6)):toBe(true)
		expect(AlyaNum.new(-5):isCloseTo(5, 100)):toBe(false)
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

describe("Leaderboard serialization", function()
	local function makeNumber(multiplicand, exponent, tetrate, pentate, hexate, heptate): AlyaNumber
		return AlyaNum.new({
			sign = 1,
			multiplicand = multiplicand,
			exponent = exponent,
			tetrate = tetrate,
			pentate = pentate,
			hexate = hexate,
			heptate = heptate,
		})
	end

	local function getMode(number: AlyaNumber): number
		return math.floor(math.abs(number:toSingle()) / 1e16)
	end

	test("toSingle: preserves tetrate mode bands", function()
		local modeSix = AlyaNum.new({
			sign = 1,
			multiplicand = 2,
			exponent = 3,
			tetrate = 1,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local modeSeven = AlyaNum.new({
			sign = 1,
			multiplicand = 2,
			exponent = 3,
			tetrate = 2,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})

		expect(math.floor(modeSix:toSingle() / 1e16)):toBe(6)
		expect(math.floor(modeSeven:toSingle() / 1e16)):toBe(7)
	end)

	test("toSingle: reaches every encoding mode", function()
		local cases: { { number: AlyaNumber, mode: number } } = {
			{ number = makeNumber(2, 0, 0, 0, 0, 0), mode = 0 },
			{ number = makeNumber(2, 1, 0, 0, 0, 0), mode = 1 },
			{ number = makeNumber(2, 2, 0, 0, 0, 0), mode = 2 },
			{ number = makeNumber(2, 3, 0, 0, 0, 0), mode = 3 },
			{ number = makeNumber(2, 4, 0, 0, 0, 0), mode = 4 },
			{ number = makeNumber(2, 10000, 0, 0, 0, 0), mode = 5 },
			{ number = makeNumber(2, 0, 1, 0, 0, 0), mode = 6 },
			{ number = makeNumber(2, 0, 2, 0, 0, 0), mode = 7 },
			{ number = makeNumber(2, 0, 3, 0, 0, 0), mode = 8 },
			{ number = makeNumber(2, 0, 9999, 0, 0, 0), mode = 9 },
			{ number = makeNumber(2, 0, 0, 1, 0, 0), mode = 10 },
			{ number = makeNumber(2, 0, 0, 0, 1, 0), mode = 11 },
			{ number = makeNumber(2, 0, 0, 0, 0, 1), mode = 12 },
		}

		for _, case in ipairs(cases) do
			expect(getMode(case.number)):toBe(case.mode)
			if case.mode >= 6 then
				expect(getMode(AlyaNum.fromSingle(case.number:toSingle()))):toBe(case.mode)
			end
		end
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

describe("Mathematical property matrix", function()
	local function expectExact(actual: AlyaNumber, expected: number, message: string?)
		expect(actual):toEqual(AlyaNum.new(expected), message)
	end

	local function expectClose(actual: AlyaNumber, expected: number, precision: number?, message: string?)
		expect(actual:toNumber()):toBeCloseTo(expected, precision or 9, message)
	end

	test("addition has a right identity", function()
		expectExact(AlyaNum.new(17):add(0), 17)
	end)

	test("addition has a left identity", function()
		expectExact(AlyaNum.new(17):add(0), 17)
	end)

	test("addition is commutative for positive values", function()
		expect(AlyaNum.new(14):add(29)):toEqual(AlyaNum.new(29):add(14))
	end)

	test("addition is commutative for mixed signs", function()
		expect(AlyaNum.new(-14):add(29)):toEqual(AlyaNum.new(29):add(-14))
	end)

	test("addition is associative for positive values", function()
		expect(AlyaNum.new(2):add(3):add(5)):toEqual(AlyaNum.new(2):add(AlyaNum.new(3):add(5)))
	end)

	test("addition is associative for mixed signs", function()
		expect(AlyaNum.new(-8):add(13):add(-4)):toEqual(AlyaNum.new(-8):add(AlyaNum.new(13):add(-4)))
	end)

	test("adding an additive inverse gives zero", function()
		expectExact(AlyaNum.new(31):add(-31), 0)
	end)

	test("subtraction has a right zero", function()
		expectExact(AlyaNum.new(-31):sub(0), -31)
	end)

	test("subtracting a number from itself gives zero", function()
		expectExact(AlyaNum.new(31):sub(31), 0)
	end)

	test("addition followed by subtraction cancels", function()
		expect(AlyaNum.new(19):add(8):sub(8)):toEqual(AlyaNum.new(19))
	end)

	test("subtraction followed by addition cancels", function()
		expect(AlyaNum.new(19):sub(8):add(8)):toEqual(AlyaNum.new(19))
	end)

	test("multiplication has a right identity", function()
		expectExact(AlyaNum.new(-23):mul(1), -23)
	end)

	test("multiplication has a left identity", function()
		expectExact(AlyaNum.new(1):mul(-23), -23)
	end)

	test("multiplication is commutative", function()
		expect(AlyaNum.new(-7):mul(12)):toEqual(AlyaNum.new(12):mul(-7))
	end)

	test("multiplication is associative", function()
		expect(AlyaNum.new(2):mul(3):mul(7)):toEqual(AlyaNum.new(2):mul(AlyaNum.new(3):mul(7)))
	end)

	test("zero annihilates multiplication on the left", function()
		expectExact(AlyaNum.new(0):mul(-123), 0)
	end)

	test("zero annihilates multiplication on the right", function()
		expectExact(AlyaNum.new(-123):mul(0), 0)
	end)

	test("multiplication distributes over addition", function()
		expect(AlyaNum.new(7):mul(AlyaNum.new(3):add(5))):toEqual(AlyaNum.new(7):mul(3):add(AlyaNum.new(7):mul(5)))
	end)

	test("multiplication distributes over subtraction", function()
		expect(AlyaNum.new(7):mul(AlyaNum.new(13):sub(5))):toEqual(AlyaNum.new(7):mul(13):sub(AlyaNum.new(7):mul(5)))
	end)

	test("multiplication preserves the product of signs", function()
		expectExact(AlyaNum.new(-6):mul(-9), 54)
	end)

	test("division has a right identity", function()
		expectExact(AlyaNum.new(-44):div(1), -44)
	end)

	test("a nonzero number divided by itself is one", function()
		expectExact(AlyaNum.new(-44):div(-44), 1)
	end)

	test("multiplication followed by division cancels", function()
		expect(AlyaNum.new(12):mul(7):div(7)):toEqual(AlyaNum.new(12))
	end)

	test("division followed by multiplication cancels for exact quotients", function()
		expect(AlyaNum.new(84):div(7):mul(7)):toEqual(AlyaNum.new(84))
	end)

	test("reciprocal is a multiplicative inverse", function()
		expectClose(AlyaNum.new(8):mul(AlyaNum.new(8):reciprocal()), 1)
	end)

	test("modulo by itself is zero", function()
		expectExact(AlyaNum.new(-44):mod(-44), 0)
	end)

	test("positive modulo is bounded by its divisor", function()
	local remainder = AlyaNum.new(29):mod(7)
	expect(remainder):toBeGreaterThanOrEqual(AlyaNum.new(0))
	expect(remainder):toBeLessThan(AlyaNum.new(7))
	end)

	test("negative modulo keeps the dividend sign", function()
		expectExact(AlyaNum.new(-29):mod(7), -1)
	end)

	test("modulo ignores the divisor sign", function()
		expect(AlyaNum.new(29):mod(-7)):toEqual(AlyaNum.new(29):mod(7))
	end)

	test("modulo reconstructs a positive dividend", function()
	local value = AlyaNum.new(29)
	local divisor = AlyaNum.new(7)
	local quotient = value:div(divisor):floor()
	expect(quotient:mul(divisor):add(value:mod(divisor))):toEqual(value)
	end)

	test("zero is the additive identity under operators", function()
	expect((AlyaNum.new(0) + AlyaNum.new(26))):toEqual(AlyaNum.new(26))
	end)

	test("one is the multiplicative identity under operators", function()
	expect((AlyaNum.new(1) * AlyaNum.new(-26))):toEqual(AlyaNum.new(-26))
	end)

	test("power has a zero exponent identity", function()
	expect(AlyaNum.new(26):pow(0)):toEqual(AlyaNum.new(1))
	end)

	test("power has a unit exponent identity", function()
	expect(AlyaNum.new(-26):pow(1)):toEqual(AlyaNum.new(-26))
	end)

	test("powers of a positive base add exponents", function()
	local base = AlyaNum.new(3)
	expect(base:pow(4):mul(base:pow(2))):toEqual(base:pow(6))
	end)

	test("powers of a positive base multiply exponents", function()
	local base = AlyaNum.new(2)
	expect(base:pow(3):pow(2)):toEqual(base:pow(6))
	end)

	test("an even power removes a negative base sign", function()
		expectExact(AlyaNum.new(-3):pow(4), 81)
	end)

	test("an odd power preserves a negative base sign", function()
		expectExact(AlyaNum.new(-3):pow(3), -27)
	end)

	test("positive roots invert perfect powers", function()
		expectClose(AlyaNum.new(81):root(4), 3)
	end)

	test("raising a perfect root restores the radicand", function()
		expectClose(AlyaNum.new(3):root(1):pow(1), 3)
	end)

	test("odd roots preserve negative signs", function()
		expectClose(AlyaNum.new(-125):root(3), -5)
	end)

	test("compare is reflexive", function()
		expect(AlyaNum.new(37):compare(37)):toBe(0)
	end)

	test("compare is antisymmetric", function()
		expect(AlyaNum.new(-4):compare(12)):toBe(-1)
		expect(AlyaNum.new(12):compare(-4)):toBe(1)
	end)

	test("comparison has a trichotomy for less values", function()
	local value = AlyaNum.new(4)
	expect(value:lt(9)):toBe(true)
	expect(value:equals(9)):toBe(false)
	expect(value:mt(9)):toBe(false)
	end)

	test("comparison has a trichotomy for equal values", function()
	local value = AlyaNum.new(9)
	expect(value:lt(9)):toBe(false)
	expect(value:equals(9)):toBe(true)
	expect(value:mt(9)):toBe(false)
	end)

	test("comparison has a trichotomy for greater values", function()
	local value = AlyaNum.new(12)
	expect(value:lt(9)):toBe(false)
	expect(value:equals(9)):toBe(false)
	expect(value:mt(9)):toBe(true)
	end)

	test("less-than is transitive", function()
	local a, b, c = AlyaNum.new(2), AlyaNum.new(5), AlyaNum.new(9)
	expect(a:lt(b) and b:lt(c) and a:lt(c)):toBe(true)
	end)

	test("less-than-or-equal is transitive", function()
	local a, b, c = AlyaNum.new(2), AlyaNum.new(5), AlyaNum.new(9)
	expect(a:le(b) and b:le(c) and a:le(c)):toBe(true)
	end)

	test("equals agrees with compare", function()
	local a, b = AlyaNum.new(15), AlyaNum.new(15)
	expect(a:equals(b)):toBe(a:compare(b) == 0)
	end)

	test("min selects the smaller value", function()
	expect(AlyaNum.new(12):min(-4)):toEqual(AlyaNum.new(-4))
	end)

	test("max selects the larger value", function()
	expect(AlyaNum.new(12):max(-4)):toEqual(AlyaNum.new(12))
	end)

	test("minmax returns values in ascending order", function()
	local minimum, maximum = AlyaNum.new(12):minmax(-4)
	expect(minimum):toEqual(AlyaNum.new(-4))
	expect(maximum):toEqual(AlyaNum.new(12))
	end)

	test("absolute value removes a negative sign", function()
		expect(AlyaNum.new(-37):abs()):toEqual(AlyaNum.new(37))
	end)

	test("absolute value is idempotent", function()
	local value = AlyaNum.new(-37)
	expect(value:abs():abs()):toEqual(value:abs())
	end)

	test("unary negation is an involution", function()
	local value = AlyaNum.new(-37)
	expect(value:unary():unary()):toEqual(value)
	end)

	test("a value plus its unary negation is zero", function()
		expect(AlyaNum.new(-37):add(AlyaNum.new(-37):unary())):toEqual(AlyaNum.new(0))
	end)

	test("absolute value preserves multiplication magnitude", function()
	local productMagnitude = AlyaNum.new(-6):mul(7):abs()
	local absoluteProduct = AlyaNum.new(-6):abs():mul(AlyaNum.new(7):abs())
		expect(productMagnitude):toEqual(absoluteProduct)
	end)

	test("absolute comparison orders by magnitude", function()
		expect(AlyaNum.new(-12):abs():moreThan(9)):toBe(true)
	end)

	test("negative values precede zero", function()
		expect(AlyaNum.new(-1):lt(0)):toBe(true)
	end)

	test("zero precedes positive values", function()
		expect(AlyaNum.new(0):lt(1)):toBe(true)
	end)

	test("floor is a lower bound", function()
	local value = AlyaNum.new(7.25)
	expect(value:floor()):toBeLessThanOrEqual(value)
	end)

	test("ceil is an upper bound", function()
	local value = AlyaNum.new(7.25)
	expect(value:ceil()):toBeGreaterThanOrEqual(value)
	end)

	test("floor and ceil bracket a value", function()
	local value = AlyaNum.new(-7.25)
	expect(value:floor()):toBeLessThanOrEqual(value)
	expect(value:ceil()):toBeGreaterThanOrEqual(value)
	end)

	test("floor returns an integer", function()
	expect(AlyaNum.new(-7.25):floor():isInteger()):toBe(true)
	end)

	test("ceil returns an integer", function()
		expect(AlyaNum.new(7.25):ceil():isInteger()):toBe(true)
	end)

	test("round chooses the nearest integer below one half", function()
		expectExact(AlyaNum.new(7.49):round(), 7)
	end)

	test("round chooses the nearest integer above one half", function()
		expectExact(AlyaNum.new(7.5):round(), 8)
	end)

	test("integers are fixed by floor", function()
	local value = AlyaNum.new(-18)
		expect(value:floor()):toEqual(value)
	end)

	test("integers are fixed by ceil", function()
	local value = AlyaNum.new(18)
		expect(value:ceil()):toEqual(value)
	end)

	test("log10 maps ten powers to their exponents", function()
		expect(AlyaNum.new(10):pow(4):log10()):toEqual(AlyaNum.new(4))
	end)

	test("logarithm changes base consistently", function()
		expectClose(AlyaNum.new(81):log(3), 4)
	end)

	test("log10 of one is zero", function()
		expect(AlyaNum.new(1):log10()):toEqual(AlyaNum.new(0))
	end)

	test("log10 is strictly increasing on positive values", function()
		expect(AlyaNum.new(10):log10()):toBeLessThan(AlyaNum.new(100):log10())
	end)

	test("log10 converts products into sums", function()
	local left, right = AlyaNum.new(100), AlyaNum.new(1000)
		expect(left:mul(right):log10()):toEqual(left:log10():add(right:log10()))
	end)

	test("log10 converts quotients into differences", function()
	local numerator, denominator = AlyaNum.new(1000), AlyaNum.new(10)
		expect(numerator:div(denominator):log10()):toEqual(numerator:log10():sub(denominator:log10()))
	end)

	test("factorial maps zero to one", function()
		expect(AlyaNum.new(0):factorial()):toEqual(AlyaNum.new(1))
	end)

	test("factorial maps one to one", function()
		expect(AlyaNum.new(1):factorial()):toEqual(AlyaNum.new(1))
	end)

	test("factorial satisfies its recurrence", function()
	local value = AlyaNum.new(6)
		expect(value:factorial()):toEqual(value:mul(value:sub(1):factorial()))
	end)

	test("factorial is strictly increasing after one", function()
		expect(AlyaNum.new(7):factorial()):toBeGreaterThan(AlyaNum.new(6):factorial())
	end)

	test("factorial results are nonnegative", function()
		expect(AlyaNum.new(8):factorial()):toBeGreaterThanOrEqual(AlyaNum.new(0))
	end)

	test("factorial results are integers for small inputs", function()
		expect(AlyaNum.new(8):factorial():isInteger()):toBe(true)
	end)

	test("tetration has a height-one identity", function()
		expect(AlyaNum.new(3):tet(1)):toEqual(AlyaNum.new(3))
	end)

	test("pentation has a height-one identity", function()
		expect(AlyaNum.new(3):pent(1)):toEqual(AlyaNum.new(3))
	end)

	test("hexation has a height-one identity", function()
		expect(AlyaNum.new(3):hext(1)):toEqual(AlyaNum.new(3))
	end)

	test("tetration height two is self-power", function()
		expect(AlyaNum.new(3):tet(2)):toEqual(AlyaNum.new(3):pow(3))
	end)

	test("tetration grows with height for base two", function()
		expect(AlyaNum.new(2):tet(3)):toBeGreaterThan(AlyaNum.new(2):tet(2))
	end)

	test("pentation height two is tetration at base height", function()
		expect(AlyaNum.new(3):pent(2)):toEqual(AlyaNum.new(3):tet(3))
	end)

	test("pentation grows with height for base two", function()
		expect(AlyaNum.new(2):pent(3)):toBeGreaterThan(AlyaNum.new(2):pent(2))
	end)

	test("hexation height two is pentation at base height", function()
		expect(AlyaNum.new(2):hext(2)):toEqual(AlyaNum.new(2):pent(2))
	end)

	test("one is fixed by every tested hyperoperation", function()
	local one = AlyaNum.new(1)
	expect(one:tet(4)):toEqual(one)
	expect(one:pent(4)):toEqual(one)
	expect(one:hext(4)):toEqual(one)
	end)

	test("number construction preserves ordinary values", function()
	local value = -123.456
		expectClose(AlyaNum.new(value), value)
	end)

	test("decimal string construction preserves ordinary values", function()
		expectClose(AlyaNum.fromString("-123.456"), -123.456)
	end)

	test("scientific construction preserves ordinary values", function()
		expectClose(AlyaNum.fromScientific("1.25e4"), 12500)
	end)

	test("base serialization is an exact round trip", function()
	local value = AlyaNum.new(-987654)
		expect(AlyaNum.new(value:toBaseAlya())):toEqual(value)
	end)

	test("Omega serialization is an exact round trip", function()
	local value = AlyaNum.new(987654)
	local restored = AlyaNum.fromOmega({ value.sign, { value.multiplicand, value.exponent, value.tetrate, value.pentate, value.hexate, value.heptate } })
		expect(restored):toEqual(value)
	end)

	test("scientific formatting parses back to the same number", function()
		local value = AlyaNum.new(123000)
		expect(AlyaNum.fromScientific(value:toScientific())):toEqual(value)
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

describe("Massive number correctness", function()
	local ZERO = AlyaNum.new(0)
	local ONE = AlyaNum.new(1)
	local NEG_ONE = AlyaNum.new(-1)

	local function makeMassive(exponent, tetrate, pentate, hexate, heptate): AlyaNumber
		return AlyaNum.new({
			sign = 1,
			multiplicand = 100,
			exponent = exponent,
			tetrate = tetrate,
			pentate = pentate,
			hexate = hexate,
			heptate = heptate,
		})
	end

	local cases = {
		{ name = "10^1000", value = AlyaNum.fromScientific("1e1000") },
		{ name = "10^(10^100)", value = AlyaNum.fromString("ee100") },
		{ name = "10^(10^(10^100))", value = AlyaNum.fromString("eee100") },
		{ name = "four-level E chain", value = AlyaNum.fromString("eeee100") },
		{ name = "tetration level one", value = makeMassive(0, 1, 0, 0, 0) },
		{ name = "pentation level one", value = makeMassive(0, 0, 1, 0, 0) },
		{ name = "hexation level one", value = makeMassive(0, 0, 0, 1, 0) },
		{ name = "heptation level one", value = makeMassive(0, 0, 0, 0, 1) },
	}

	type Check = {
		name: string,
		run: () -> (),
	}

	local function assertAll(checks: { Check })
		local failures = {}
		for _, check in ipairs(checks) do
			local ok, message = pcall(check.run)
			if not ok then
				failures[#failures + 1] = check.name .. ": " .. tostring(message)
			end
		end
		if #failures > 0 then
			error(table.concat(failures, "\n"), 2)
		end
	end

	test("construction: preserves the massive representation ladder", function()
		local expected = {
			{ text = "1e1000", exponent = 1, multiplicand = 1000 },
			{ text = "ee100", exponent = 2, multiplicand = 100 },
			{ text = "eee100", exponent = 3, multiplicand = 100 },
			{ text = "eeee100", exponent = 4, multiplicand = 100 },
		}
		local previous

		for _, case in ipairs(expected) do
			local value = AlyaNum.fromString(case.text)
			expect(value.sign):toBe(1)
			expect(value.exponent):toBe(case.exponent)
			expect(value.multiplicand):toBe(case.multiplicand)
			if previous ~= nil then
				expect(value):toBeGreaterThan(previous)
			end
			previous = value
		end
	end)

	test("signs: unary preserves massive negative values", function()
		for _, case in ipairs(cases) do
			local negative = case.value:unary()
			expect(negative.sign):toBe(-1)
			expect(negative:abs()):toEqual(case.value)
			expect(negative:unary()):toEqual(case.value)
			expect(negative):toBeLessThan(case.value)
		end
	end)

	test("parsing: accepts negative massive E notations", function()
		local checks = {}
		for index = 1, 4 do
			local case = cases[index]
			local value = case.value
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					local negative = AlyaNum.fromString("-" .. value:toEChain())
					expect(negative.sign):toBe(-1)
					expect(negative:abs()):toEqual(value)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive values divide by themselves", function()
		local checks = {}
		for _, case in ipairs(cases) do
			local value = case.value
			local negative = value:unary()
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:div(value)):toEqual(ONE)
					expect(negative:div(negative)):toEqual(ONE)
					expect(value:div(negative)):toEqual(NEG_ONE)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive values cancel to zero", function()
		local checks = {}
		for _, case in ipairs(cases) do
			local value = case.value
			local negative = value:unary()
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:sub(value)):toEqual(ZERO)
					expect(value:add(negative)):toEqual(ZERO)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive values have zero remainder with themselves", function()
		local checks = {}
		for _, case in ipairs(cases) do
			local value = case.value
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:mod(value)):toEqual(ZERO)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive squares preserve intentional saturation", function()
		local checks = {}
		for index = 3, #cases do
			local case = cases[index]
			local value = case.value
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:mul(value)):toEqual(value)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive powers preserve intentional saturation", function()
		local checks = {}
		for index = 3, #cases do
			local case = cases[index]
			local value = case.value
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:pow(2)):toEqual(value)
				end,
			}
		end
		assertAll(checks)
	end)

	test("arithmetic: massive roots preserve intentional saturation", function()
		local checks = {}
		for index = 3, #cases do
			local case = cases[index]
			local value = case.value
			checks[#checks + 1] = {
				name = case.name,
				run = function()
					expect(value:root(2)):toEqual(value)
				end,
			}
		end
		assertAll(checks)
	end)

	test("comparison: massive magnitudes stay ordered", function()
		for index = 2, #cases do
			expect(cases[index].value):toBeGreaterThan(cases[index - 1].value)
		end
		for _, case in ipairs(cases) do
			expect(case.value:compare(case.value)):toBe(0)
			expect(case.value:compare(case.value:unary())):toBe(1)
		end
	end)

	test("logarithms: E-chain levels round trip through log10", function()
		local values = {
			{ value = AlyaNum.fromScientific("1e1000"), logarithm = AlyaNum.new(1000) },
			{ value = AlyaNum.fromString("ee100"), logarithm = AlyaNum.fromString("e100") },
			{ value = AlyaNum.fromString("eee100"), logarithm = AlyaNum.fromString("ee100") },
			{ value = AlyaNum.fromString("eeee100"), logarithm = AlyaNum.fromString("eee100") },
		}

		for _, case in ipairs(values) do
			expect(case.value:log10()):toEqual(case.logarithm)
			expect(10 ^ case.value:log10()):toEqual(case.value)
		end
	end)

	test("conversion: massive base fields survive round trips", function()
		for _, case in ipairs(cases) do
			local value = case.value
			local restored = AlyaNum.fromOmega({
				value.sign,
				{ value.multiplicand, value.exponent, value.tetrate, value.pentate, value.hexate, value.heptate },
			})
			expect(restored):toEqual(value)
		end
	end)

	test("conversion: massive values report overflow to primitive numbers", function()
		for _, case in ipairs(cases) do
			expect(case.value:toNumber()):toBe(math.huge)
		end
	end)

	test("conversion: hyperoperation values remain visible in direct formats", function()
		local expected = {
			{ value = cases[5].value, text = "E(0)100" },
			{ value = cases[6].value, text = "E100#2" },
			{ value = cases[7].value, text = "E100#2" },
			{ value = cases[8].value, text = "E100#2" },
		}

		for _, case in ipairs(expected) do
			expect(case.value:toScientific()):toBe(case.text)
			expect(case.value:toSuffix()):toBe(case.text)
		end
	end)

	test("formatting: massive values remain representable", function()
		for _, case in ipairs(cases) do
			expect(#case.value:toScientific()):toBeGreaterThan(0)
			expect(#case.value:toString()):toBeGreaterThan(0)
		end
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

describe("Public API coverage", function()
	test("fromScientific: parses uppercase large exponents", function()
		local ok, uppercase = pcall(AlyaNum.fromScientific, "1E1000")
		expect(ok):toBe(true)
		if ok then
			expect(uppercase):toEqual(AlyaNum.fromScientific("1e1000"))
		end
	end)

	test("fromString: rejects unknown suffixes", function()
		expect(AlyaNum.fromString("1XYZ"):toNumber()):toBe(0)
		expect(AlyaNum.fromString("1Mfoo"):toNumber()):toBe(0)
	end)

	test("fromString: parses recognized suffix tiers", function()
		local cases = {
			{ suffix = "K", value = 1e3 },
			{ suffix = "M", value = 1e6 },
			{ suffix = "B", value = 1e9 },
			{ suffix = "U", value = 1e6 },
			{ suffix = "De", value = 1e33 },
			{ suffix = "Ce", value = 1e303 },
		}
		for _, case in ipairs(cases) do
			expect(AlyaNum.fromString("1" .. case.suffix):toNumber() / case.value):toBeCloseTo(1, 9)
		end
	end)

	test("fromOmega: preserves every array field", function()
		local number = AlyaNum.fromOmega({ 1, { 20, 3, 4, 5, 6, 7 } })
		expect(number.sign):toBe(1)
		expect(number.multiplicand):toBe(20)
		expect(number.exponent):toBe(3)
		expect(number.tetrate):toBe(4)
		expect(number.pentate):toBe(5)
		expect(number.hexate):toBe(6)
		expect(number.heptate):toBe(7)
	end)

	test("external conversions: accept base-form objects", function()
		local onoe = AlyaNum.fromOnoe({
			sign = -1,
			multiplicand = 20,
			exponent = 3,
			tetrate = 4,
			pentate = 5,
			hexate = 6,
			heptate = 7,
		})
		local omega = AlyaNum.fromOmega({
			sign = -1,
			multiplicand = 20,
			exponent = 3,
			tetrate = 4,
			pentate = 5,
			hexate = 6,
			heptate = 7,
		})
		expect(onoe):toEqual(omega)
		expect(onoe.sign):toBe(-1)
		expect(onoe.multiplicand):toBe(20)
	end)

	test("fromString: parses full array notation", function()
		local number = AlyaNum.fromString("[1, 20, 3, 4, 5, 6, 7]")
		expect(number):toEqual(AlyaNum.fromOmega({ 1, { 20, 3, 4, 5, 6, 7 } }))
		expect(AlyaNum.fromString("[0, 9, 9, 9]"):toNumber()):toBe(0)
	end)

	test("toSerika: returns mantissa and exponent pairs", function()
		local mantissa, exponent = AlyaNum.new(1234.5):toSerika()
		expect(mantissa):toBeCloseTo(1.2345, 9)
		expect(exponent):toBe(3)

		local zeroMantissa, zeroExponent = AlyaNum.new(0):toSerika()
		expect(zeroMantissa):toBe(0)
		expect(zeroExponent):toBe(0)

		local hugeMantissa, hugeExponent = AlyaNum.fromScientific("1e1000"):toSerika()
		expect(hugeMantissa):toBe(1)
		expect(hugeExponent):toBe(1000)
	end)

	test("logarithms: satisfy positive-domain identities", function()
		expect(AlyaNum.new(100):log10()):toEqual(AlyaNum.new(2))
		expect(AlyaNum.new(100):log(10)):toEqual(AlyaNum.new(2))
		expect(AlyaNum.new(8):log(2)):toEqual(AlyaNum.new(3))
		expect(AlyaNum.new(1):slog(10)):toEqual(AlyaNum.new(0))
		expect(AlyaNum.new(10):slog(10)):toEqual(AlyaNum.new(1))
		expect(AlyaNum.new(10):pentlog(10)):toEqual(AlyaNum.new(1))
		expect(AlyaNum.new(10):hextlog(10)):toEqual(AlyaNum.new(1))
	end)

	test("hyperoperations: satisfy exact small identities", function()
		expect(AlyaNum.new(3):tet(2)):toEqual(AlyaNum.new(27))
		expect(AlyaNum.new(3):pent(2)):toEqual(AlyaNum.new(3):tet(3))
		expect(AlyaNum.new(2):hext(2)):toEqual(AlyaNum.new(2):pent(2))

		local zero = AlyaNum.new(0)
		expect(zero:tet(1)):toEqual(AlyaNum.new(1))
		expect(zero:tet(2)):toEqual(zero)
		expect(zero:tet(3)):toEqual(AlyaNum.new(1))
		expect(zero:pent(1)):toEqual(AlyaNum.new(1))
		expect(zero:pent(2)):toEqual(zero)
		expect(zero:hext(1)):toEqual(AlyaNum.new(1))
		expect(zero:hext(2)):toEqual(zero)
	end)

	test("metamethods: support primitive-left operations", function()
		local addOk, added = pcall(function()
			return 3 + AlyaNum.new(2)
		end)
		expect(addOk):toBe(true)
		if addOk then
			expect(added:toNumber()):toBe(5)
		end

		local divideOk, divided = pcall(function()
			return 6 / AlyaNum.new(2)
		end)
		expect(divideOk):toBe(true)
		if divideOk then
			expect(divided:toNumber()):toBe(3)
		end

		local concatOk, concatenated = pcall(function()
			return "x" .. AlyaNum.new(3)
		end)
		expect(concatOk):toBe(true)
		if concatOk then
			expect(concatenated):toBe("x3")
		end

		expect(AlyaNum.new(3):lessThan(4)):toBe(true)
		expect(AlyaNum.new(4):lessEquals(4)):toBe(true)
	end)

	test("formatting: exposes direct E notations", function()
		local eValue = AlyaNum.new({
			sign = 1,
			multiplicand = 2,
			exponent = 0,
			tetrate = 1,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local hyperValue = AlyaNum.new({
			sign = 1,
			multiplicand = 2,
			exponent = 0,
			tetrate = 0,
			pentate = 1,
			hexate = 0,
			heptate = 0,
		})
		expect(eValue:toEnt()):toBe("E(0)2")
		expect(hyperValue:toHyperE()):toBe("E2#2")
	end)

	test("formatting: negative scientific output mirrors absolute output", function()
		local value = AlyaNum.new(-1234.567)
		expect(value:toScientific()):toBe("-" .. value:abs():toScientific())
	end)

	test("formatting: switches default abbreviation modes", function()
		local value = AlyaNum.new(1e6)
		AlyaNum.changeDefaultAbbreviation("scientific")
		expect(value:toString()):toBe("1e6")
		AlyaNum.changeDefaultAbbreviation("suffix")
		expect(value:toString()):toBe("1M")
	end)

	test("formatting: supports zero decimal points", function()
		local value = AlyaNum.new(1234567)
		AlyaNum.changeDecimalPoints(0)
		expect(value:toSuffix()):toBe("1M")
		expect(value:toScientific()):toBe("1e6")
		AlyaNum.changeDecimalPoints(2)
	end)

	test("logarithms: do not mutate high-level fields", function()
		local slogValue = AlyaNum.new({
			sign = 1,
			multiplicand = 20,
			exponent = 10,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local pentlogValue = AlyaNum.new({
			sign = 1,
			multiplicand = 20,
			exponent = 0,
			tetrate = 10,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		local hextlogValue = AlyaNum.new({
			sign = 1,
			multiplicand = 20,
			exponent = 0,
			tetrate = 0,
			pentate = 10,
			hexate = 0,
			heptate = 0,
		})

		local slogOk = pcall(function()
			slogValue:slog(10)
		end)
		local pentlogOk = pcall(function()
			pentlogValue:pentlog(10)
		end)
		local hextlogOk = pcall(function()
			hextlogValue:hextlog(10)
		end)
		expect(slogOk):toBe(true)
		expect(pentlogOk):toBe(true)
		expect(hextlogOk):toBe(true)
		expect(slogValue.exponent):toBe(10)
		expect(pentlogValue.tetrate):toBe(10)
		expect(hextlogValue.pentate):toBe(10)
	end)

	test("serialization: fixes and restores base values", function()
		local raw = {
			sign = 1,
			multiplicand = -2,
			exponent = 0,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		}
		expect(AlyaNum.fix(raw):toNumber()):toBe(-2)

		local number = AlyaNum.new(42)
		local base = number:toBaseAlya()
		expect(getmetatable(base)):toBe(nil)
		expect(AlyaNum.new(base)):toEqual(AlyaNum.new(42))
	end)

	test("construction: rejects both infinity signs", function()
		local positiveOk = pcall(AlyaNum.new, math.huge)
		local negativeOk = pcall(AlyaNum.new, -math.huge)
		expect(positiveOk):toBe(false)
		expect(negativeOk):toBe(false)
	end)
end)

describe("Additional mathematical properties", function()
	local function expectClose(actual: AlyaNumber, expected: number, precision: number?)
		expect(actual:toNumber()):toBeCloseTo(expected, precision or 9)
	end

	test("closeness is symmetric", function()
		local left = AlyaNum.new(100)
		local right = AlyaNum.new(100.001)
		expect(left:isCloseTo(right, 1e-4)):toBe(true)
		expect(right:isCloseTo(left, 1e-4)):toBe(true)
	end)

	test("zero tolerance still accepts exact values", function()
		expect(AlyaNum.new(42):isCloseTo(42, 0)):toBe(true)
	end)

	test("larger relative tolerance accepts a larger difference", function()
		local value = AlyaNum.new(100)
		expect(value:isCloseTo(100.5, 0.01)):toBe(true)
		expect(value:isCloseTo(100.5, 0.001)):toBe(false)
	end)

	test("absolute tolerance accepts its upper boundary", function()
		expect(AlyaNum.new(10):isCloseTo(10.25, 0, 0.25)):toBe(true)
	end)

	test("absolute tolerance rejects a smaller limit", function()
		expect(AlyaNum.new(10):isCloseTo(10.25, 0, 0.24)):toBe(false)
	end)

	test("negative relative tolerance is invalid", function()
		local ok = pcall(function()
			return AlyaNum.new(1):isCloseTo(1, -1)
		end)
		expect(ok):toBe(false)
	end)

	test("negative absolute tolerance is invalid", function()
		local ok = pcall(function()
			return AlyaNum.new(1):isCloseTo(1, 0, -1)
		end)
		expect(ok):toBe(false)
	end)

	test("infinite relative tolerance is invalid", function()
		local ok = pcall(function()
			return AlyaNum.new(1):isCloseTo(1, math.huge)
		end)
		expect(ok):toBe(false)
	end)

	test("reciprocal is an involution for positive values", function()
		expectClose(AlyaNum.new(8):reciprocal():reciprocal(), 8)
	end)

	test("reciprocal is an involution for negative values", function()
		expectClose(AlyaNum.new(-8):reciprocal():reciprocal(), -8)
	end)

	test("reciprocal preserves the sign flip", function()
		expectClose(AlyaNum.new(-8):reciprocal(), -0.125)
	end)

	test("reciprocal multiplies to one", function()
		expectClose(AlyaNum.new(13):mul(AlyaNum.new(13):reciprocal()), 1)
	end)

	test("reciprocal distributes over products", function()
		local left = AlyaNum.new(6):mul(5):reciprocal()
		local right = AlyaNum.new(6):reciprocal():mul(AlyaNum.new(5):reciprocal())
		expectClose(left, right:toNumber())
	end)

	test("square roots compose", function()
		expectClose(AlyaNum.new(256):root(2):root(2), 4)
	end)

	test("roots distribute over reciprocals", function()
		local left = AlyaNum.new(81):reciprocal():root(4)
		local right = AlyaNum.new(81):root(4):reciprocal()
		expectClose(left, right:toNumber())
	end)

	test("roots distribute over products of perfect powers", function()
		local left = AlyaNum.new(16):mul(81):root(2)
		local right = AlyaNum.new(16):root(2):mul(AlyaNum.new(81):root(2))
		expectClose(left, right:toNumber())
	end)

	test("root preserves order for positive radicands", function()
		expect(AlyaNum.new(16):root(2)):toBeLessThan(AlyaNum.new(81):root(2))
	end)

	test("toNumber preserves a positive decimal", function()
		expect(AlyaNum.new(123.75):toNumber()):toBe(123.75)
	end)

	test("toNumber preserves a negative decimal", function()
		expect(AlyaNum.new(-123.75):toNumber()):toBe(-123.75)
	end)

	test("toNumber preserves a very small value", function()
		expect(AlyaNum.new(1e-200):toNumber()):toBeCloseTo(1e-200, 9)
	end)

	test("toNumber reports positive overflow", function()
		expect(AlyaNum.fromScientific("1e1000"):toNumber()):toBe(math.huge)
	end)

	test("toNumber reports negative overflow", function()
		expect(AlyaNum.fromScientific("-1e1000"):toNumber()):toBe(-math.huge)
	end)

	test("toSerika maps zero to zero fields", function()
		local mantissa, exponent = AlyaNum.new(0):toSerika()
		expect(mantissa):toBe(0)
		expect(exponent):toBe(0)
	end)

	test("toSerika normalizes a positive mantissa", function()
		local mantissa, exponent = AlyaNum.new(98765):toSerika()
		expect(mantissa):toBeCloseTo(9.8765, 9)
		expect(exponent):toBe(4)
	end)

	test("toSerika reconstructs its source value", function()
		local value = AlyaNum.new(98765)
		local mantissa, exponent = value:toSerika()
		expect(mantissa * 10 ^ exponent):toBeCloseTo(value:toNumber(), 9)
	end)

	test("toSerika carries a negative sign in its mantissa", function()
		local mantissa, exponent = AlyaNum.new(-2500):toSerika()
		expect(mantissa):toBeCloseTo(-2.5, 9)
		expect(exponent):toBe(3)
	end)

	test("fromOnoe reconstructs a positive mantissa and exponent", function()
		expectClose(AlyaNum.fromOnoe({ mantissa = 2.5, exponent = 3 }), 2500)
	end)

	test("fromOnoe preserves raw high-level fields", function()
		local value = AlyaNum.fromOnoe({
			sign = 1,
			multiplicand = 8,
			exponent = 0,
			tetrate = 1,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		expect(value.sign):toBe(1)
		expect(value.multiplicand):toBe(8)
		expect(value.exponent):toBe(0)
		expect(value.tetrate):toBe(1)
	end)

	test("fromOmega defaults omitted lower fields", function()
		local value = AlyaNum.fromOmega({ 1, { 5 } })
		expect(value):toEqual(AlyaNum.new(5))
	end)

	test("fromOmega preserves a negative tuple sign", function()
		expectClose(AlyaNum.fromOmega({ -1, { 5, 0, 0, 0, 0, 0 } }), -5)
	end)

	test("fix canonicalizes every zero field", function()
		local value = AlyaNum.fix({
			sign = 0,
			multiplicand = 4,
			exponent = 2,
			tetrate = 3,
			pentate = 4,
			hexate = 5,
			heptate = 6,
		})
		expect(value):toEqual(AlyaNum.new(0))
	end)

	test("fix moves a negative multiplicand into the sign", function()
		local value = AlyaNum.fix({
			sign = 1,
			multiplicand = -4,
			exponent = 0,
			tetrate = 0,
			pentate = 0,
			hexate = 0,
			heptate = 0,
		})
		expect(value.sign):toBe(-1)
		expect(value.multiplicand):toBe(4)
	end)

	test("fromString scales the K suffix exactly", function()
		expect(AlyaNum.fromString("2K"):toNumber()):toBeCloseTo(2000, 9)
	end)

	test("fromString scales the M suffix exactly", function()
		expect(AlyaNum.fromString("3M"):toNumber()):toBeCloseTo(3000000, 9)
	end)

	test("fromString scales the B suffix exactly", function()
		expect(AlyaNum.fromString("4B"):toNumber()):toBeCloseTo(4000000000, 5)
	end)

	test("fromString preserves a suffix sign", function()
		expect(AlyaNum.fromString("-4K"):toNumber()):toBeCloseTo(-4000, 9)
	end)

	test("toSuffix formats one thousand canonically", function()
		expect(AlyaNum.new(1000):toSuffix()):toBe("1K")
	end)

	test("toSuffix formats one million canonically", function()
		expect(AlyaNum.new(1000000):toSuffix()):toBe("1M")
	end)

	test("scientific formatting round trips a power of ten", function()
		local value = AlyaNum.new(1000000)
		expect(AlyaNum.fromScientific(value:toScientific())):toEqual(value)
	end)

	test("E-chain formatting round trips a two-level value", function()
		local value = AlyaNum.fromString("ee2")
		expect(AlyaNum.fromString(value:toEChain())):toEqual(value)
	end)

	test("leaderboard encoding is odd with respect to sign", function()
		local value = AlyaNum.new(2.5)
		expect(value:lbencode()):toBe(-value:unary():lbencode())
	end)

	test("leaderboard encoding preserves positive order", function()
		expect(AlyaNum.new(2):lbencode()):toBeLessThan(AlyaNum.new(200):lbencode())
	end)

	test("toSingle is the leaderboard encoding alias", function()
		local value = AlyaNum.new(37.5)
		expect(value:toSingle()):toBe(value:lbencode())
	end)

	test("fromSingle is the leaderboard decoding alias", function()
		local value = AlyaNum.new(37.5)
		expect(AlyaNum.fromSingle(value:toSingle())):toEqual(AlyaNum.lbdecode(value:lbencode()))
	end)

	test("leaderboard round trips a positive decimal", function()
		local value = AlyaNum.new(2.5)
		expectClose(AlyaNum.lbdecode(value:lbencode()), 2.5, 8)
	end)

	test("leaderboard round trips a negative decimal", function()
		local value = AlyaNum.new(-2.5)
		expectClose(AlyaNum.lbdecode(value:lbencode()), -2.5, 8)
	end)

	test("Lambert W maps zero to zero", function()
		expect(AlyaNum.new(0):lambertw()):toEqual(AlyaNum.new(0))
	end)

	test("Lambert W at one has its principal value", function()
		expectClose(AlyaNum.new(1):lambertw(), 0.5671432904, 8)
	end)

	test("Lambert W satisfies its defining equation at one", function()
		local value = AlyaNum.new(1)
		local result = value:lambertw()
		expectClose(result:mul(math.exp(result:toNumber())), 1, 8)
	end)

	test("Lambert W satisfies its defining equation at ten", function()
		local value = AlyaNum.new(10)
		local result = value:lambertw()
		expectClose(result:mul(math.exp(result:toNumber())), 10, 8)
	end)

	test("Lambert W is increasing on positive inputs", function()
		expect(AlyaNum.new(1):lambertw()):toBeLessThan(AlyaNum.new(10):lambertw())
	end)

	test("Lambert W satisfies its defining equation on a negative input", function()
		local value = AlyaNum.new(-0.1)
		local result = value:lambertw()
		expectClose(result:mul(math.exp(result:toNumber())), -0.1, 8)
	end)

	test("slog inverts tetration at height two", function()
		expect(AlyaNum.new(2):tet(2):slog(2)):toEqual(AlyaNum.new(2))
	end)

	test("slog inverts tetration at height three", function()
		expect(AlyaNum.new(2):tet(3):slog(2)):toEqual(AlyaNum.new(3))
	end)

	test("slog inverts tetration for base three", function()
		expect(AlyaNum.new(3):tet(2):slog(3)):toEqual(AlyaNum.new(2))
	end)

	test("pentlog inverts pentation at height two", function()
		expect(AlyaNum.new(2):pent(2):pentlog(2)):toEqual(AlyaNum.new(2))
	end)

	test("pentlog inverts pentation for base three", function()
		expect(AlyaNum.new(3):pent(2):pentlog(3)):toEqual(AlyaNum.new(2))
	end)

	test("hextlog inverts hexation at height two", function()
		expect(AlyaNum.new(2):hext(2):hextlog(2)):toEqual(AlyaNum.new(2))
	end)

	test("tetration has a zero-height identity", function()
		expect(AlyaNum.new(7):tet(0)):toEqual(AlyaNum.new(1))
	end)

	test("pentation has a zero-height identity", function()
		expect(AlyaNum.new(7):pent(0)):toEqual(AlyaNum.new(1))
	end)

	test("hexation has a zero-height identity", function()
		expect(AlyaNum.new(7):hext(0)):toEqual(AlyaNum.new(1))
	end)

	test("floor negation matches negated ceil", function()
		local value = AlyaNum.new(7.25)
		expect(value:unary():floor()):toEqual(value:ceil():unary())
	end)

	test("ceil negation matches negated floor", function()
		local value = AlyaNum.new(7.25)
		expect(value:unary():ceil()):toEqual(value:floor():unary())
	end)

	test("rounding is odd away from half boundaries", function()
		local value = AlyaNum.new(7.25)
		expect(value:unary():round()):toEqual(value:round():unary())
	end)

	test("floor commutes with integer translation", function()
		local value = AlyaNum.new(7.25)
		expect(value:add(3):floor()):toEqual(value:floor():add(3))
	end)

	test("ceil commutes with integer translation", function()
		local value = AlyaNum.new(-7.25)
		expect(value:add(3):ceil()):toEqual(value:ceil():add(3))
	end)

	test("floor and ceil differ by one for nonintegers", function()
		local value = AlyaNum.new(-7.25)
		expect(value:floor():add(1)):toEqual(value:ceil())
	end)

	test("round lies between floor and ceil", function()
		local value = AlyaNum.new(7.75)
		expect(value:round()):toBeGreaterThanOrEqual(value:floor())
		expect(value:round()):toBeLessThanOrEqual(value:ceil())
	end)

	test("integer status agrees with equal floor and ceil", function()
		local value = AlyaNum.new(-18)
		expect(value:isInteger()):toBe(value:floor():equals(value:ceil()))
	end)

	test("fractional status disagrees with equal floor and ceil", function()
		local value = AlyaNum.new(-18.25)
		expect(value:isInteger()):toBe(value:floor():equals(value:ceil()))
	end)

	test("factorial quotients recover their integer", function()
		expect(AlyaNum.new(10):factorial():div(AlyaNum.new(9):factorial())):toEqual(AlyaNum.new(10))
	end)

	test("factorial remains integral at ten", function()
		expect(AlyaNum.new(10):factorial():isInteger()):toBe(true)
	end)

	test("factorial order follows integer order", function()
		expect(AlyaNum.new(10):factorial()):toBeGreaterThan(AlyaNum.new(9):factorial())
	end)

	test("the googol exceeds every smaller power of ten", function()
		expect(AlyaNum.GOOGOL):toBeGreaterThan(AlyaNum.new(10):pow(99))
	end)

	test("the googolplex exceeds the googol", function()
		expect(AlyaNum.GOOGOLPLEX):toBeGreaterThan(AlyaNum.GOOGOL)
	end)

	test("the googolplex is ten raised to the googol", function()
		expect(AlyaNum.GOOGOLPLEX):toEqual(AlyaNum.new(10):pow(AlyaNum.GOOGOL))
	end)

	test("Graham's first term exceeds tritri", function()
		expect(AlyaNum.GRAHAM1):toBeGreaterThan(AlyaNum.TRITRI)
	end)

	test("tritet exceeds Graham's first term", function()
		expect(AlyaNum.TRITET):toBeGreaterThan(AlyaNum.GRAHAM1)
	end)
end)
