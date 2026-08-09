--!nocheck
local process = require("@lune/process")

local harness = {}
local tests = {}
local suiteNames = {}

local function formatValue(value)
	if type(value) == "table" and type(value.toString) == "function" then
		return value:toString()
	end

	return tostring(value)
end

local function valuesEqual(actual, expected)
	if type(actual) == "table" and type(actual.equals) == "function" then
		return actual:equals(expected)
	end

	if type(expected) == "table" and type(expected.equals) == "function" then
		return expected:equals(actual)
	end

	if type(actual) ~= "table" or type(expected) ~= "table" then
		return actual == expected
	end

	for key, value in pairs(actual) do
		if not valuesEqual(value, expected[key]) then
			return false
		end
	end

	for key in pairs(expected) do
		if actual[key] == nil then
			return false
		end
	end

	return true
end

local function compareValues(actual, expected, matcher)
	if type(actual) == "table" then
		return actual[matcher](actual, expected)
	end

	return matcher == "moreThan" and actual > expected
		or matcher == "lessThan" and actual < expected
		or matcher == "moreEquals" and actual >= expected
		or actual <= expected
end

local function expectationError(matcher, actual, expected, message)
	error(message or ("Expected " .. formatValue(actual) .. " " .. matcher .. " " .. formatValue(expected)), 3)
end

local function expect<T>(actual: T)
	local expectation = {}

	function expectation:toBe(expected: unknown, message)
		if actual ~= expected then
			expectationError("to be", actual, expected, message)
		end
	end

	function expectation:toEqual(expected: T?, message)
		if not valuesEqual(actual, expected) then
			expectationError("to equal", actual, expected, message)
		end
	end

	function expectation:toBeCloseTo(expected: T?, precision: number, message)
		precision = precision or 2
		local epsilon = 10 ^ -precision
		if math.abs(actual - expected) >= epsilon then
			expectationError("to be close to", actual, expected, message)
		end
	end

	function expectation:toBeGreaterThan(expected: T?, message)
		if not compareValues(actual, expected, "moreThan") then
			expectationError("to be greater than", actual, expected, message)
		end
	end

	function expectation:toBeLessThan(expected: T?, message)
		if not compareValues(actual, expected, "lessThan") then
			expectationError("to be less than", actual, expected, message)
		end
	end

	function expectation:toBeGreaterThanOrEqual(expected: T?, message)
		if not compareValues(actual, expected, "moreEquals") then
			expectationError("to be greater than or equal to", actual, expected, message)
		end
	end

	function expectation:toBeLessThanOrEqual(expected: T?, message)
		if not compareValues(actual, expected, "lessEquals") then
			expectationError("to be less than or equal to", actual, expected, message)
		end
	end

	function expectation:toBeTruthy(message)
		if not actual then
			expectationError("to be truthy", actual, true, message)
		end
	end

	function expectation:toBeFalsy(message)
		if actual then
			expectationError("to be falsy", actual, false, message)
		end
	end

	function expectation:toBeDefined(message)
		if actual == nil then
			expectationError("to be defined", actual, "a value", message)
		end
	end

	return expectation
end

local function describe(name, callback)
	table.insert(suiteNames, name)
	callback()
	table.remove(suiteNames)
end

local function test(name, callback)
	local fullName = table.concat(suiteNames, " > ")
	if fullName ~= "" then
		fullName ..= " > "
	end

	table.insert(tests, {
		name = fullName .. name,
		fn = callback,
	})
end

local function run()
	local passed, failed = 0, 0

	for _, registeredTest in ipairs(tests) do
		local ok, err = pcall(registeredTest.fn)
		if ok then
			--print("[PASS]", registeredTest.name)
			passed += 1
		else
			print("[FAIL]", registeredTest.name, err)
			failed += 1
		end
	end

	print("Tests finished. Passed:", passed, "Failed:", failed)
	process.exit(if failed > 0 then 1 else 0)
end

harness.describe = describe
harness.test = test
harness.expect = expect
harness.run = run

return harness
