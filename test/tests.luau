local AlyaNum = require("./src/init.luau")
local runner = require("./runner.luau")

runner.addTest("fromNumber: creates from number", function()
	local num = AlyaNum.new(5)
	runner.assertEqual(num:toNumber(), 5)
end)

runner.addTest("fromNumber: creates from negative number", function()
	local num = AlyaNum.new(-10)
	runner.assertEqual(num:toNumber(), -10)
end)

runner.addTest("fromString: creates from string", function()
	local num = AlyaNum.fromString("12345")
	runner.assertEqual(num:toNumber(), 12345)
end)

runner.addTest("fromString: handles negative strings", function()
	local num = AlyaNum.fromString("-67890")
	runner.assertEqual(num:toNumber(), -67890)
end)

runner.addTest("fromString: handles zero string", function()
	local num = AlyaNum.fromString("0")
	runner.assertEqual(num:toNumber(), 0)
end)

runner.addTest("scientificNotation: parses scientific notation", function()
	local num = AlyaNum.fromScientific("1.23e5")
	runner.assertClose(num:toNumber(), 123000)
end)

runner.addTest("scientificNotation: handles negative signs in strings", function()
	local num = AlyaNum.fromScientific("-5.678")
	runner.assertClose(num:toNumber(), -5.678)
end)

runner.addTest("scientificNotation: handles scientific notation in various formats", function()
	local cases = {
		{ input = "1.23e+45", expected = 1.23e45 },
		{ input = "1.23e-5", expected = 1.23e-5 },
		{ input = "1e10", expected = 1e10 }
	}
	for _, case in ipairs(cases) do
		local num = AlyaNum.fromScientific(case.input)
		runner.assertClose(num:toNumber() / case.expected, 1)
	end
end)

runner.runTests()