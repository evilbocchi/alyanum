--!optimize 2
--!native
--!nocheck

-- Benchmark tests for AlyaNum vs number and EternityNum performance

local AlyaNum = require("./src")
local EternityNum = require("./bench/EternityNum")
local OmegaNum = require("./bench/OmegaNum")

-- Benchmark configuration
local ITERATIONS = 200000 -- 200K operations as mentioned in the chart
local WARMUP_ITERATIONS = 1000
local EXPENSIVE_ITERATIONS = 5000
local EXPENSIVE_WARMUP_ITERATIONS = 100

-- Test data setup
local testNumbers = {
	small = { 123.456, 789.012, 345.678 },
	medium = { 1.23e15, 4.56e20, 7.89e25 },
	large = { 1.23e100, 4.56e200, 7.89e300 },
}

local negativeTestNumbers = {
	small = { -123.456, -789.012, -345.678 },
	medium = { -1.23e15, -4.56e20, -7.89e25 },
	large = { -1.23e100, -4.56e200, -7.89e300 },
}

local testNumberStrings = {
	small = { "123.456", "789.012", "345.678" },
	medium = { "1.23e15", "4.56e20", "7.89e25" },
	large = { "1.23e100", "4.56e200", "7.89e300" },
}

-- Convert test numbers to AlyaNum format
local testAlyaNum = {}
for category, numbers in testNumbers do
	testAlyaNum[category] = {}
	for i, num in numbers do
		testAlyaNum[category][i] = AlyaNum.new(num)
	end
end

-- Convert test numbers to EternityNum format
local testEternityNum = {}
for category, numbers in testNumbers do
	testEternityNum[category] = {}
	for i, num in numbers do
		testEternityNum[category][i] = EternityNum.fromNumber(num)
	end
end

local negativeTestAlyaNum = {}
for category, numbers in negativeTestNumbers do
	negativeTestAlyaNum[category] = {}
	for i, num in numbers do
		negativeTestAlyaNum[category][i] = AlyaNum.new(num)
	end
end

local negativeTestEternityNum = {}
for category, numbers in negativeTestNumbers do
	negativeTestEternityNum[category] = {}
	for i, num in numbers do
		negativeTestEternityNum[category][i] = EternityNum.fromNumber(num)
	end
end

local testOmegaNum = {}
for category, numbers in testNumbers do
	testOmegaNum[category] = {}
	for i, num in numbers do
		testOmegaNum[category][i] = OmegaNum.fromNumber(num)
	end
end

local negativeTestOmegaNum = {}
for category, numbers in negativeTestNumbers do
	negativeTestOmegaNum[category] = {}
	for i, num in numbers do
		negativeTestOmegaNum[category][i] = OmegaNum.fromNumber(num)
	end
end

-- Utility functions
local function formatTime(ns: number): string
	if ns < 1000 then
		return string.format("%.2f ns", ns)
	elseif ns < 1000000 then
		return string.format("%.2f μs", ns / 1000)
	else
		return string.format("%.2f ms", ns / 1000000)
	end
end

local function formatOpsPerSecond(ops: number): string
	if ops >= 1000000 then
		return string.format("%.2f M/s", ops / 1000000)
	elseif ops >= 1000 then
		return string.format("%.2f K/s", ops / 1000)
	else
		return string.format("%.2f /s", ops)
	end
end

local function warmup(func: () -> (), iterations: number?)
	for i = 1, iterations or WARMUP_ITERATIONS do
		func()
	end
end

local function benchmark(func: () -> (), iterations: number): (number, number)
	local startTime = os.clock()
	for i = 1, iterations do
		func()
	end
	local endTime = os.clock()

	local totalTime = (endTime - startTime) * 1000000000 -- Convert to nanoseconds
	local avgTime = totalTime / iterations
	local opsPerSecond = 1000000000 / avgTime

	return avgTime, opsPerSecond
end

local function createNativeBenchmarks(data, power: number?, scale: string?)
	local benchmarkScale = scale or "medium"
	local values = data[benchmarkScale]
	local left = values[1]
	local right = values[2]
	local smallValue = data.small[1]
	local inputString = testNumberStrings[benchmarkScale][1]
	power = power or 2.5

	return {
		addition = function()
			return function()
				local _ = left + right
			end
		end,
		subtraction = function()
			return function()
				local _ = right - left
			end
		end,
		multiplication = function()
			return function()
				local _ = left * right
			end
		end,
		division = function()
			return function()
				local _ = right / left
			end
		end,
		exponentiation = function()
			return function()
				local _ = smallValue ^ power
			end
		end,
		root = function()
			return function()
				local _ = smallValue ^ (1 / power)
			end
		end,
		modulo = function()
			return function()
				local _ = smallValue % 17
			end
		end,
		logarithm = function()
			return function()
				local _ = math.log(smallValue) / math.log(10)
			end
		end,
		log10 = function()
			return function()
				local _ = math.log(smallValue) / math.log(10)
			end
		end,
		stringParsing = function()
			return function()
				local _ = tonumber(inputString)
			end
		end,
		toString = function()
			return function()
				local _ = tostring(left)
			end
		end,
		comparison = function()
			return function()
				local _ = left < right
				local _ = left > right
				local _ = left == right
			end
		end,
	}
end

local function createAlyaBenchmarks(data, power: number?, scale: string?)
	local benchmarks = createNativeBenchmarks(data, power, scale)
	local benchmarkScale = scale or "medium"
	local values = data[benchmarkScale]
	local left = values[1]
	local smallValue = data.small[1]
	local inputString = testNumberStrings[benchmarkScale][1]
	local hyperBase = AlyaNum.new(2)
	power = power or 2.5

	benchmarks.root = function()
		return function()
			local _ = AlyaNum.root(smallValue, power)
		end
	end
	benchmarks.logarithm = function()
		return function()
			local _ = AlyaNum.log(smallValue, 10)
		end
	end
	benchmarks.log10 = function()
		return function()
			local _ = AlyaNum.log10(smallValue)
		end
	end
	benchmarks.lambertw = function()
		return function()
			local _ = AlyaNum.lambertw(smallValue)
		end
	end
	benchmarks.slog = function()
		return function()
			local _ = AlyaNum.slog(left, 10)
		end
	end
	benchmarks.tetration = function()
		return function()
			local _ = AlyaNum.tet(hyperBase, 3)
		end
	end
	benchmarks.pentation = function()
		return function()
			local _ = AlyaNum.pent(hyperBase, 2)
		end
	end
	benchmarks.stringParsing = function()
		return function()
			local _ = AlyaNum.fromString(inputString)
		end
	end
	benchmarks.toString = function()
		return function()
			local _ = AlyaNum.toString(left)
		end
	end

	return benchmarks
end

local function createEternityBenchmarks(data, power: number?, scale: string?)
	local benchmarkScale = scale or "medium"
	local values = data[benchmarkScale]
	local left = values[1]
	local right = values[2]
	local smallValue = data.small[1]
	local inputString = testNumberStrings[benchmarkScale][1]
	power = power or 2.5

	return {
		addition = function()
			return function()
				local _ = EternityNum.add(left, right)
			end
		end,
		subtraction = function()
			return function()
				local _ = EternityNum.sub(right, left)
			end
		end,
		multiplication = function()
			return function()
				local _ = EternityNum.mul(left, right)
			end
		end,
		division = function()
			return function()
				local _ = EternityNum.div(right, left)
			end
		end,
		exponentiation = function()
			return function()
				local _ = EternityNum.pow(smallValue, power)
			end
		end,
		root = function()
			return function()
				local _ = EternityNum.root(smallValue, power)
			end
		end,
		logarithm = function()
			return function()
				local _ = EternityNum.log(smallValue, 10)
			end
		end,
		log10 = function()
			return function()
				local _ = EternityNum.log10(smallValue)
			end
		end,
		stringParsing = function()
			return function()
				local _ = EternityNum.fromString(inputString)
			end
		end,
		toString = function()
			return function()
				local _ = EternityNum.toString(left)
			end
		end,
		comparison = function()
			return function()
				local _ = EternityNum.le(left, right)
				local _ = EternityNum.me(left, right)
				local _ = EternityNum.eq(left, right)
			end
		end,
	}
end

local function createOmegaBenchmarks(data, power: number?, scale: string?)
	local benchmarkScale = scale or "medium"
	local values = data[benchmarkScale]
	local left = values[1]
	local right = values[2]
	local smallValue = data.small[1]
	local inputString = testNumberStrings[benchmarkScale][1]
	local hyperBase = OmegaNum.fromNumber(2)
	power = power or 2.5

	return {
		addition = function()
			return function()
				local _ = OmegaNum.add(left, right)
			end
		end,
		subtraction = function()
			return function()
				local _ = OmegaNum.sub(right, left)
			end
		end,
		multiplication = function()
			return function()
				local _ = OmegaNum.mul(left, right)
			end
		end,
		division = function()
			return function()
				local _ = OmegaNum.div(right, left)
			end
		end,
		exponentiation = function()
			return function()
				local _ = OmegaNum.pow(smallValue, power)
			end
		end,
		root = function()
			return function()
				local _ = OmegaNum.root(smallValue, power)
			end
		end,
		modulo = function()
			return function()
				local _ = OmegaNum.mod(smallValue, 17)
			end
		end,
		logarithm = function()
			return function()
				local _ = OmegaNum.log(smallValue, 10)
			end
		end,
		log10 = function()
			return function()
				local _ = OmegaNum.log10(smallValue)
			end
		end,
		lambertw = function()
			return function()
				local _ = OmegaNum.lambertw(smallValue)
			end
		end,
		slog = function()
			return function()
				local _ = OmegaNum.slog(left, 10)
			end
		end,
		tetration = function()
			return function()
				local _ = OmegaNum.tetrate(hyperBase, 3)
			end
		end,
		pentation = function()
			return function()
				local _ = OmegaNum.pentate(hyperBase, 2)
			end
		end,
		stringParsing = function()
			return function()
				local _ = OmegaNum.fromString(inputString)
			end
		end,
		toString = function()
			return function()
				local _ = OmegaNum.toScientific(left)
			end
		end,
		comparison = function()
			return function()
				local _ = OmegaNum.le(left, right)
				local _ = OmegaNum.me(left, right)
				local _ = OmegaNum.eq(left, right)
			end
		end,
	}
end

local function createScaleBenchmarks(factory, data, power: number?)
	return {
		medium = factory(data, power, "medium"),
		large = factory(data, power, "large"),
	}
end

local operationOrder = {
	{ key = "addition", label = "Addition", dataset = "positive", benchmarkKey = "addition" },
	{ key = "subtraction", label = "Subtraction", dataset = "positive", benchmarkKey = "subtraction" },
	{ key = "multiplication", label = "Multiplication", dataset = "positive", benchmarkKey = "multiplication" },
	{ key = "division", label = "Division", dataset = "positive", benchmarkKey = "division" },
	{ key = "exponentiation", label = "Exponentiation", dataset = "positive", benchmarkKey = "exponentiation" },
	{ key = "root", label = "Root", dataset = "positive", benchmarkKey = "root" },
	{ key = "modulo", label = "Modulo", dataset = "positive", benchmarkKey = "modulo" },
	{ key = "logarithm", label = "Logarithm (base 10)", dataset = "positive", benchmarkKey = "logarithm" },
	{ key = "log10", label = "Log10", dataset = "positive", benchmarkKey = "log10" },
	{
		key = "lambertw",
		label = "Lambert W",
		dataset = "positive",
		benchmarkKey = "lambertw",
		iterations = EXPENSIVE_ITERATIONS,
		warmupIterations = EXPENSIVE_WARMUP_ITERATIONS,
	},
	{
		key = "slog",
		label = "Super-log (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "slog",
		iterations = EXPENSIVE_ITERATIONS,
		warmupIterations = EXPENSIVE_WARMUP_ITERATIONS,
	},
	{
		key = "tetration",
		label = "Tetration",
		dataset = "positive",
		benchmarkKey = "tetration",
		iterations = EXPENSIVE_ITERATIONS,
		warmupIterations = EXPENSIVE_WARMUP_ITERATIONS,
	},
	{
		key = "pentation",
		label = "Pentation",
		dataset = "positive",
		benchmarkKey = "pentation",
		iterations = EXPENSIVE_ITERATIONS,
		warmupIterations = EXPENSIVE_WARMUP_ITERATIONS,
	},
	{
		key = "stringParsing",
		label = "String parsing (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "stringParsing",
	},
	{
		key = "toString",
		label = "String formatting (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "toString",
	},
	{ key = "comparison", label = "Comparison", dataset = "positive", benchmarkKey = "comparison" },
	{
		key = "largeAddition",
		label = "Addition (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "addition",
	},
	{
		key = "largeMultiplication",
		label = "Multiplication (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "multiplication",
	},
	{
		key = "largeDivision",
		label = "Division (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "division",
	},
	{
		key = "largeComparison",
		label = "Comparison (large)",
		dataset = "positive",
		scale = "large",
		benchmarkKey = "comparison",
	},
	{ key = "negativeAddition", label = "Addition (negative)", dataset = "negative", benchmarkKey = "addition" },
	{
		key = "negativeSubtraction",
		label = "Subtraction (negative)",
		dataset = "negative",
		benchmarkKey = "subtraction",
	},
	{
		key = "negativeMultiplication",
		label = "Multiplication (negative)",
		dataset = "negative",
		benchmarkKey = "multiplication",
	},
	{ key = "negativeDivision", label = "Division (negative)", dataset = "negative", benchmarkKey = "division" },
	{
		key = "negativeExponentiation",
		label = "Exponentiation (negative)",
		dataset = "negative",
		benchmarkKey = "exponentiation",
	},
	{ key = "negativeModulo", label = "Modulo (negative)", dataset = "negative", benchmarkKey = "modulo" },
	{ key = "negativeComparison", label = "Comparison (negative)", dataset = "negative", benchmarkKey = "comparison" },
}

local competitors = {
	{
		key = "number",
		label = "number",
		benchmarks = {
			positive = createScaleBenchmarks(createNativeBenchmarks, testNumbers),
			negative = createScaleBenchmarks(createNativeBenchmarks, negativeTestNumbers, 3),
		},
	},
	{
		key = "alya",
		label = "AlyaNum",
		benchmarks = {
			positive = createScaleBenchmarks(createAlyaBenchmarks, testAlyaNum),
			negative = createScaleBenchmarks(createAlyaBenchmarks, negativeTestAlyaNum, 3),
		},
	},
	{
		key = "eternity",
		label = "EternityNum",
		benchmarks = {
			positive = createScaleBenchmarks(createEternityBenchmarks, testEternityNum),
			negative = createScaleBenchmarks(createEternityBenchmarks, negativeTestEternityNum, 3),
		},
	},
	{
		key = "omega",
		label = "OmegaNum",
		benchmarks = {
			positive = createScaleBenchmarks(createOmegaBenchmarks, testOmegaNum),
			negative = createScaleBenchmarks(createOmegaBenchmarks, negativeTestOmegaNum, 3),
		},
	},
}

local BASELINE_KEY = "number"
local OPERATION_COLUMN_WIDTH = 28
local COMPETITOR_COLUMN_WIDTH = 22

-- Main benchmark execution
local function runAllBenchmarks()
	print(
		string.format(
			"Preparing %dK standard iterations, %d expensive iterations, and %d warmup iterations",
			ITERATIONS / 1000,
			EXPENSIVE_ITERATIONS,
			WARMUP_ITERATIONS
		)
	)
	local allBenchmarks = {}
	for _, operation in operationOrder do
		local operationBenchmarks = {}
		for _, competitor in competitors do
			local scale = operation.scale or "medium"
			local createBenchmark = competitor.benchmarks[operation.dataset][scale][operation.benchmarkKey]
			if createBenchmark then
				operationBenchmarks[competitor.key] = createBenchmark()
			end
		end
		allBenchmarks[operation.key] = operationBenchmarks
	end

	print("Warming up benchmarks...")
	for _, operation in operationOrder do
		for _, competitor in competitors do
			local benchmarkFunction = allBenchmarks[operation.key][competitor.key]
			if benchmarkFunction then
				warmup(benchmarkFunction, operation.warmupIterations)
			end
		end
	end

	print("Running timed benchmarks...")
	local allResults = {}
	for _, operation in operationOrder do
		local operationResults = {}
		for _, competitor in competitors do
			local benchmarkFunction = allBenchmarks[operation.key][competitor.key]
			if benchmarkFunction then
				local time, ops = benchmark(benchmarkFunction, operation.iterations or ITERATIONS)
				operationResults[competitor.key] = { time = time, ops = ops }
			end
		end
		allResults[operation.key] = operationResults
	end

	local function calculateSpeedRatio(baseline: number, target: number): string
		local ratio = baseline / target
		if ratio > 1 then
			return string.format("%.1fx slower", ratio)
		else
			return string.format("%.1fx faster", target / baseline)
		end
	end

	local function formatResult(result): string
		return string.format("%s | %s", formatTime(result.time), formatOpsPerSecond(result.ops))
	end

	local function printTableSeparator(character: string, competitorCount: number)
		local width = OPERATION_COLUMN_WIDTH + competitorCount * COMPETITOR_COLUMN_WIDTH + competitorCount
		print(string.rep(character, width))
	end

	local function printTableRow(operationLabel: string, values)
		local columns = { string.format("%-" .. OPERATION_COLUMN_WIDTH .. "s", operationLabel) }
		for _, value in values do
			table.insert(columns, string.format("%-" .. COMPETITOR_COLUMN_WIDTH .. "s", value))
		end
		print(table.concat(columns, " "))
	end

	local competitorLabels = {}
	for _, competitor in competitors do
		table.insert(competitorLabels, competitor.label)
	end

	print()
	printTableSeparator("=", #competitors)
	print("BENCHMARK RESULTS (time/op | throughput; expensive rows use fewer iterations)")
	printTableSeparator("=", #competitors)
	printTableRow("Operation", competitorLabels)
	printTableSeparator("-", #competitors)
	for _, operation in operationOrder do
		local results = allResults[operation.key]
		local values = {}
		for _, competitor in competitors do
			local result = results[competitor.key]
			table.insert(values, result and formatResult(result) or "n/a")
		end
		printTableRow(operation.label, values)
	end

	local baselineCompetitor
	local relativeCompetitors = {}
	for _, competitor in competitors do
		if competitor.key == BASELINE_KEY then
			baselineCompetitor = competitor
		else
			table.insert(relativeCompetitors, competitor)
		end
	end
	assert(baselineCompetitor, string.format("Missing baseline competitor: %s", BASELINE_KEY))

	print("\nRELATIVE PERFORMANCE VS NUMBER")
	printTableSeparator("-", #relativeCompetitors)
	local relativeLabels = {}
	for _, competitor in relativeCompetitors do
		table.insert(relativeLabels, competitor.label)
	end
	printTableRow("Operation", relativeLabels)
	printTableSeparator("-", #relativeCompetitors)
	for _, operation in operationOrder do
		local results = allResults[operation.key]
		local baselineResult = results[baselineCompetitor.key]
		local values = {}
		for _, competitor in relativeCompetitors do
			local result = results[competitor.key]
			if baselineResult and result then
				table.insert(values, calculateSpeedRatio(baselineResult.ops, result.ops))
			else
				table.insert(values, "n/a")
			end
		end
		printTableRow(operation.label, values)
	end
end

-- Execute benchmarks
runAllBenchmarks()
