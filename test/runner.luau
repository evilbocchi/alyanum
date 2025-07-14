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

return {
	addTest = addTest,
	assertEqual = assertEqual,
	assertClose = assertClose,
	runTests = runTests,
}
