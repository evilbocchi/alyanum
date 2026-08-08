--!optimize 2
--!native
--!nocheck

-- Benchmark tests for AlyaNum vs number and EternityNum performance

local AlyaNum = require("./AlyaNum")
local EternityNum = require("./bench/EternityNum")

-- Benchmark configuration
local ITERATIONS = 200000 -- 200K operations as mentioned in the chart
local WARMUP_ITERATIONS = 1000

-- Test data setup
local testNumbers = {
	small = { 123.456, 789.012, 345.678 },
	medium = { 1.23e15, 4.56e20, 7.89e25 },
	large = { 1.23e100, 4.56e200, 7.89e300 },
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

local function benchmark(func: () -> (), iterations: number): (number, number)
	-- Warmup
	for i = 1, WARMUP_ITERATIONS do
		func()
	end

	-- Actual benchmark
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

local function createNativeBenchmarks(data)
	local left = data.medium[1]
	local right = data.medium[2]
	local smallValue = data.small[1]
	local power = 2.5

	return {
		addition = function()
			return function()
				local _ = left + right
			end
		end,
		multiplication = function()
			return function()
				local _ = left * right
			end
		end,
		exponentiation = function()
			return function()
				local _ = smallValue ^ power
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

local function createEternityBenchmarks(data)
	local left = data.medium[1]
	local right = data.medium[2]
	local smallValue = data.small[1]
	local power = 2.5

	return {
		addition = function()
			return function()
				local _ = EternityNum.add(left, right)
			end
		end,
		multiplication = function()
			return function()
				local _ = EternityNum.mul(left, right)
			end
		end,
		exponentiation = function()
			return function()
				local _ = EternityNum.pow(smallValue, power)
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

local operationOrder = {
	{ key = "addition", label = "Addition" },
	{ key = "multiplication", label = "Multiplication" },
	{ key = "exponentiation", label = "Exponentiation" },
	{ key = "comparison", label = "Comparison" },
}

local competitors = {
	{ key = "number", label = "number", benchmarks = createNativeBenchmarks(testNumbers) },
	{ key = "alya", label = "AlyaNum", benchmarks = createNativeBenchmarks(testAlyaNum) },
	{ key = "eternity", label = "EternityNum", benchmarks = createEternityBenchmarks(testEternityNum) },
}

local BASELINE_KEY = "number"
local OPERATION_COLUMN_WIDTH = 18
local COMPETITOR_COLUMN_WIDTH = 22

-- Main benchmark execution
local function runAllBenchmarks()
	print(
		string.format("Running %dK iterations per test with %d warmup iterations", ITERATIONS / 1000, WARMUP_ITERATIONS)
	)
	print(string.rep("=", 60))

	local allResults = {}
	for _, operation in operationOrder do
		local operationResults = {}
		for _, competitor in competitors do
			local createBenchmark = competitor.benchmarks[operation.key]
			assert(createBenchmark, string.format("Missing %s benchmark for %s", operation.key, competitor.label))

			local time, ops = benchmark(createBenchmark(), ITERATIONS)
			operationResults[competitor.key] = { time = time, ops = ops }
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
	print("BENCHMARK RESULTS (time/op | throughput)")
	printTableSeparator("=", #competitors)
	printTableRow("Operation", competitorLabels)
	printTableSeparator("-", #competitors)
	for _, operation in operationOrder do
		local results = allResults[operation.key]
		local values = {}
		for _, competitor in competitors do
			table.insert(values, formatResult(results[competitor.key]))
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
			table.insert(values, calculateSpeedRatio(baselineResult.ops, results[competitor.key].ops))
		end
		printTableRow(operation.label, values)
	end
end

-- Execute benchmarks
runAllBenchmarks()
