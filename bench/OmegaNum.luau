--!nocheck
-- Making OmegaNum
-- By: FoundForces (CommanderSalty#4975)
-- Limit will be 10↑↑↑...↑↑↑10 with 1e3? ↑'s
-- Big thanks / Credits to [REDACTED] for help with errorcorrect and for lbencode and lbdecode!

--Config--
local NAN = 0 / 0 -- NAN constant.
local INF = 2e308 -- INF constant.
local paraForCorrect = 2 -- Amount of loops in errorcorrect (keep 2).
local maxInt = 2 ^ 53 - 1 -- Max integer thats allowed in a array.
local maxADD = "e" .. maxInt
local maxMUL = "ee" .. maxInt -- Max Diff for mul
local maxPOW = { 1, { 1, maxInt } } -- Max Diff for pow
local maxH = math.log10(maxInt) -- Lowest integer thats for first number.
local signif = 2 ^ 53 -- Recommended to keep on 2^53 (consant of if x is bigger then signif dont do -1).
local amoes = 5 -- Constant where eee..eex goes to e[y]x.
local PrecisionDisplay = 3 -- Amount of digits of ouput display.
local toScientific = 1e306 -- Point where X gets converted to XeN in Display, must be less or equal to maxInt.
local signifDiff = 20 -- Difference where sub, add returns biggest value, recommended to keep on 20.
local ZERO = { 1, { 0 } } -- Zero constant
local ONE = { 1, { 1 } }
local maxAllowed = 1.797693015e308
local maxSuffix = { 1, { 3000000, 1 } } -- max value to return suffix at short
local maxScientific = "eeee300008"
local maxEs = 10
local INF = 2e308
local ArrowLimit = 1e308 --254
local formatArrowLimit = 3
local pi = 3.14159265358979323846
-----------

--[[
Functions,

correct: corrects a omeganum
fromNumber: converts a number to omeganum
toNumber: converts a omeganum to number
toDisplay: displays in arrow notation
toString: converts a omeganum to string (USE THIS FOR STORING VALUES)
fromString: converts a string to omeganum
toOmega
eq
le
me
meeq
leeq
abs
neg
cmp
max
min
log10
isint
recip
pow
mod
root
mul
floor
ceil
div
add
sub
sqrt
log
exp
maxabs
eternitytoOmega
pow10
gamma
fact
rand
exporand
toBigNum
toScientific
toShortScientific
short
toEnt
toShortEnt
toEs
toShortEs
toHyperE
toShortHyperE
lambertw
slog
tetrate
pentate
lbencode
lbdecode

]]

trunc = function(n) -- math function
	if math.ceil(n) == n then
		return n
	end
	if n < 0 then
		return -(math.floor(n))
	end
	return math.floor(n)
end

function fgamma(n)
	local C = {
		0.99999999999980993,
		676.5203681218851,
		-1259.1392167224028,
		771.32342877765313,
		-176.61502916214059,
		12.507343278686905,
		-0.13857109526572012,
		9.9843695780195716e-6,
		1.5056327351493116e-7,
	}
	if math.floor(n) == n then
		return fact(n - 1)
	end
	if n > 0.5 then
		n -= 1
		local x = C[1]
		for i = 1, 7 do
			x += C[i + 1] / (n + i)
		end
		local t = n + 7.5
		return x * t ^ (n + 0.5 - 36) * math.exp(-t) * t ^ 36 * 2.50662827463100050241576528
	end
	return 3.141592653589793238 / (math.sin(3.141592653589793238 * n) * fgamma(1 - n))
end

function f_lambertw(z)
	local tol = 1e-10
	local w, wn = nil
	if z > 1.79e308 then
		return z
	end
	if z == 0 then
		return z
	end
	if z == 1 then
		return 0.56714329040978387299997
	end
	if z < 10 then
		w = 0
	else
		w = math.log(z) - math.log(math.log(z))
	end
	for i = 1, 100 do
		wn = (z * math.exp(-w) + w * w) / (w + 1)
		if math.abs(wn - w) < tol * math.abs(wn) then
			return wn
		else
			w = wn
		end
	end
	warn("Failed at W")
	return 0 / 0
end

function Hlambertw(n)
	local tol = 1e-10
	n = ree.correct(n)
	local wn
	local w = ree.log(n)
	for i = 1, 100 do
		wn = ree.div(ree.add(ree.mul(n, ree.exp(ree.neg(w))), ree.mul(w, w)), ree.add(w, 1))
		if ree.le(ree.abs(ree.sub(wn, w)), ree.mul(tol, ree.abs(wn))) then
			return wn
		end
		w = wn
	end
	warn("Failed at hlam")
	return NAN
end

ree = {}

function ree.correct(val)
	if val == nil then
		return ZERO
	end
	if val ~= val then
		return NAN
	end
	if type(val) ~= "table" then
		return ree.toOmega(val)
	end
	if type(val[2]) ~= "table" and #val == 2 then
		val = { math.sign(val[1]), { val[2] + math.log10(math.abs(val[1])), 1 } }
	end
	if type(val[2]) ~= "table" then
		val = { 1, val }
	end
	if #val[2] == 0 then
		return ZERO
	end
	if
		(val[1] == 1 or val[1] == -1) and #val[2] == 1 and val[2][1] == 0
		or #val[2] == 2 and val[2][1] == 0 and val[2][2] == 0
	then
		return { val[1], { 0 } }
	end
	-- {sign, {}}
	local qq = copytab(val)
	local sign = qq[1]
	local array = qq[2]
	array = array or { 0 }
	sign = sign or 1
	local len = #array
	-- Handle bullshit correctly
	for i = len, 1, -1 do
		if array[i] == 0 then
			table.remove(array)
			len -= 1
		else
			break
		end
	end
	if array[1] > maxInt then
		array[1] = math.log10(array[1])
		if len > 1 then
			array[2] += 1
		else
			table.insert(array, 1)
			len += 1
		end
	end
	-- handle 1,0,0,0,x
	if len > 2 then
		if array[2] < 3 then
			for i = 1, array[2] do
				if array[i] >= math.log10(maxInt) then
					break
				elseif array[2] == 0 then
					break
				end
				array[i] = 10 ^ array[i]
				array[2] -= 1
			end
		end
		if array[2] == 0 then
			if array[1] == 1 then
				for i = 2, len do
					if array[i] == 0 then
						continue
					elseif array[i] > 1 then
						break
					elseif array[i] == 1 and i == len then
						return { sign, { 10 } }
					end
				end
			end
			local LastZero = 2
			local OneEncountered = false
			for i = 3, #array do
				if array[i] == 0 then
					LastZero = i
				elseif array[i] == 0 and OneEncountered then
					continue
				elseif array[i] == 1 and OneEncountered then
					break
				elseif array[i] == 1 then
					OneEncountered = true
				else
					break
				end
			end
			if LastZero == len then
				return { sign, { array[1] } }
			else
				local Mode = 1
				if array[1] == 1 then
					Mode = OneEncountered and 1 or 2
					array[1] = 10
				end
				array[LastZero] = array[1] - 2
				array[1] = 1e10
				for i = 2, LastZero - 1 do
					array[i] = 8
				end
				array[LastZero + 1] -= Mode
				for i = #array, 2, -1 do
					if array[i] == 0 then
						array[i] = nil
					else
						break
					end
				end
				-- Loop through LastZero
				--return {sign, array}
			end
		end
	end
	len = #array
	for i = len, 1, -1 do
		if array[i] == 0 then
			table.remove(array)
			len -= 1
		else
			break
		end
	end
	if len > 1 then
		if array[1] < math.log10(maxInt) and array[2] > 0 then
			array[2] -= 1
			array[1] = 10 ^ array[1]
			array[2] = (array[2] == 0) and nil or array[2]
		end
		if array[1] < math.log10(maxInt) and array[2] > 0 then
			array[2] -= 1
			array[1] = 10 ^ array[1]
			array[2] = (array[2] == 0) and nil or array[2]
		end
	end
	for i = 2, len do
		if array[i] > maxInt then
			array[1] = array[i]
			array[i + 1] = (array[i + 1] or 0) + 1
			array[i] += 1
			for j = 2, i do
				array[j] = 0
			end
			if array[1] > maxInt then
				array[1] = math.log10(array[1])
				array[2] += 1
			end
		end
	end
	-- Convert trailing zeros
	-- Remove trailing zeros
	-- loop until
	if qq[1] == 0 then
		return ZERO
	end
	for i = 1, #array do
		local cur = array[i]
		if cur == NAN then
			warn("correct() returning NAN")
			return qq
		end
		if cur == INF then
			return qq
		end
		if cur % 1 ~= 0 and i ~= 1 then
			array[i] = math.floor(cur)
		end
	end
	if not #array then
		qq[2] = { 0 }
	end
	return qq
end

function ree.fromNumber(val)
	if type(val) ~= "number" then
		error("NAN input at fromNumber()")
	end
	if val == 0 then
		return ZERO
	end
	return ree.correct({ math.sign(val), { math.abs(val) } })
end

function ree.toNumber(val)
	val = ree.correct(val)
	local array = val[2]
	local sign = val[1]
	if #array >= 2 and (array[2] >= 2 or (array[2] == 1 and array[1] > math.log10(maxAllowed))) then
		return INF * sign
	end
	return array[2] == 1 and 10 ^ array[1] * sign or array[1] * sign
end

local function formatarrow(val)
	if type(val) == "number" then
		local t = ""
		if val > formatArrowLimit then
			t = "10{" .. ree.toDisplay(val) .. "}"
		else
			t = "10"
			for i = 1, val do
				t ..= "^"
			end
		end
		return t
	end
end

function ree.toDisplay(val, short)
	local val1 = ree.correct(val)
	local array = val1[2]
	local sign = val1[1]
	if short then
		if array[1] == NAN then
			return "NaN"
		end
		if array[1] > INF then
			return "Infinity"
		end
		if #array == 2 then
			local es = ""
			local esign = ""
			if sign == 0 then
				return "0"
			end
			if sign < 0 then
				esign = "-"
			end
			local base = 1
			if math.fmod(array[1], 1) ~= 0 then
				base = 10 ^ (array[1] - math.floor(array[1]))
				array[1] = math.floor(array[1])
			end
			if array[2] > amoes then
				return esign .. "10^^" .. ree.short(array[2] - 1) .. " " .. base .. "e" .. ree.short(array[1])
			end
			for i = 1, array[2] - 1 do
				es = es .. "e"
			end
			return esign .. es .. ree.short(base) .. "e" .. ree.short(array[1])
		end
		local function Decimal(val, amo)
			local a = math.floor(val * 10 ^ amo)
			a = a / 10 ^ amo
			return a
		end
		if #array == 1 then
			if array[1] > toScientific then
				local esign = ""
				if sign == 0 then
					return "0"
				end
				if sign < 0 then
					esign = "-"
				end
				local exponent = math.floor(math.log10(array[1]))
				local base = array[1] / 10 ^ exponent
				return esign .. ree.short(Decimal(base, PrecisionDisplay)) .. "e" .. ree.short(exponent)
			else
				return ree.short(array[1] * sign)
			end
		end
		if #array > 2 then
			local str = ""
			for i = #array, 1, -1 do
				if i == 1 then
					str = str .. "e" .. ree.short(array[i])
					break
				end
				if array[i] ~= 0 then
					--str = str .. '(10↑[' .. i-1 .. '])' .. array[i]
					str = str .. formatarrow(i) .. ree.short(array[i]) .. " "
				end
			end
			return str
		end
	else
		if array[1] == NAN then
			return "NaN"
		end
		if array[1] > INF then
			return "Infinity"
		end
		if #array == 2 then
			local es = ""
			local esign = ""
			if sign == 0 then
				return "0"
			end
			if sign < 0 then
				esign = "-"
			end
			local base = 1
			if math.fmod(array[1], 1) ~= 0 then
				base = 10 ^ (array[1] - math.floor(array[1]))
				array[1] = math.floor(array[1])
			end
			if array[2] > amoes then
				return esign .. "10^^" .. array[2] - 1 .. " " .. base .. "e" .. array[1]
			end
			for i = 1, array[2] - 1 do
				es = es .. "e"
			end
			return esign .. es .. base .. "e" .. array[1]
		end
		local function Decimal(val, amo)
			local a = math.floor(val * 10 ^ amo)
			a = a / 10 ^ amo
			return a
		end
		if #array == 1 then
			if array[1] > toScientific then
				local esign = ""
				if sign == 0 then
					return "0"
				end
				if sign < 0 then
					esign = "-"
				end
				local exponent = math.floor(math.log10(array[1]))
				local base = array[1] / 10 ^ exponent
				return esign .. Decimal(base, PrecisionDisplay) .. "e" .. exponent
			else
				return array[1] * sign
			end
		end
		if #array > 2 then
			local str = ""
			for i = #array, 1, -1 do
				if i == 1 then
					str = str .. "e" .. array[i]
					break
				end
				if array[i] ~= 0 then
					--str = str .. '(10↑[' .. i-1 .. '])' .. array[i]
					str = str .. formatarrow(i) .. array[i] .. " "
				end
			end
			return str
		end
	end
end

function ree.toString(val)
	val = ree.correct(val)
	val[2][1] *= val[1]
	return game.HttpService:JSONEncode(val[2])
end

function ree.fromString(str)
	if str == "[0]" then
		return ZERO
	end
	if (string.find(str, "e") or string.find(str, "E")) and not string.find(str, "%[") then
		local subs = string.split(str, "e")
		-- Fix problem with tetrate
		if subs[1] == "" then
			table.insert(subs, 1, "1")
			if subs[2] == "" then
				table.remove(subs, 2)
			end
		end
		if #subs == 2 then
			-- its scientific yk
			local n = false

			if subs[1]:find("-") then
				subs[1] = math.abs(subs[1])
				n = true
			end
			local first = subs[2] + math.log10(subs[1])
			if n then
				first = -first
			end
			local second = 1
			local sign = math.sign(first)
			first = math.abs(first)
			return ree.correct({ sign, { first, second } })
		else
			-- its a e chain!
			local second = #subs - 1
			local first = subs[#subs]
			local sign = 1
			if subs[1] == "-" then
				sign = -1
			end
			return ree.correct({ sign, { tonumber(first), second } })
		end
	end
	if string.find(str, ",") or string.find(str, "%[") then
		str = game.HttpService:JSONDecode(str)
		str = { math.sign(str[1] or 1), str }
		str[2][1] = math.abs(str[2][1] or 0)
		return ree.correct(str)
	else
		return ree.fromNumber(tonumber(str))
	end
end

function ree.toOmega(val)
	if type(val) == "table" then
		-- Assuming its Omega type..
		-- For converting other Bnums please use assigned function.
		if #val < 2 then
			val = { 1, val }
		end
		return val
	end
	if type(val) == "number" then
		-- convert number to omega
		return ree.fromNumber(val)
	end
	if type(val) == "string" then
		-- convert str to omega
		return ree.fromString(val)
	end
end

function ree.eq(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	return ree.cmp(val, val2) == 0
end

function ree.le(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	return ree.cmp(val, val2) == -1
end

function ree.me(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	return ree.cmp(val, val2) == 1
end

function ree.meeq(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	return ree.cmp(val, val2) >= 0
end

function ree.leeq(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	return ree.cmp(val, val2) <= 0
end

function ree.abs(val)
	val = ree.correct(val)
	return { 1, val[2] }
end

function ree.neg(val)
	val = ree.correct(val)
	return { val[1] * -1, val[2] }
end

function ree.cmp(val, val2) -- 0 = eq, -1 = le, 1 = me
	val = ree.correct(val)
	val2 = ree.correct(val2)
	local V1Nan = val ~= val
	if V1Nan and val2 ~= val2 then
		return 0
	elseif V1Nan or val2 ~= val2 then
		return 1
	end
	if val[1] == INF and val2[1] ~= INF then
		return val[1]
	end
	if val[1] ~= INF and val2[1] == INF then
		return -val2[1]
	end
	if #val[2] == 1 and val[2][1] == 0 and #val2[2] == 1 and val2[2][1] == 0 then
		return 0
	end
	if val[1] ~= val2[1] then
		return val[1]
	end
	local a = val[1]
	local z
	if #val[2] > #val2[2] then
		z = 1
	elseif #val[2] < #val2[2] then
		z = -1
	else
		for i = #val[2], 1, -1 do
			if val[2][i] > val2[2][i] then
				z = 1
				break
			elseif val[2][i] < val2[2][i] then
				z = -1
				break
			end
		end
		z = z or 0
	end
	return z * a
end

--[[function ree.sub(val, val2)
	return ree.add(val, ree.neg(val2))
end]]

function ree.max(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	if ree.me(val, val2) then
		return val
	else
		return val2
	end
end

function ree.min(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	if ree.me(val, val2) then
		return val2
	else
		return val
	end
end

function copytab(v)
	local new = {}
	new[1] = v[1]
	new[2] = {}
	for i, v in next, v[2] do
		new[2][i] = v
	end
	return new
end

function ree.log10(val)
	val = ree.correct(val)
	if ree.eq(val, ZERO) then
		return ZERO
	end
	local val1 = copytab(val)
	if ree.le(val1, 0) then
		return NAN
	end
	if ree.eq(val1, 0) then
		return -INF
	end
	if ree.leeq(val1, maxInt) then
		return ree.fromNumber(math.log10(ree.toNumber(val1)))
	end
	val1[2][2] -= 1
	return ree.correct(val1)
end

function ree.isint(val)
	val = ree.correct(val)
	if val[1] == -1 then
		return ree.isint(ree.abs(val))
	end
	if ree.meeq(val, maxInt) then
		return true
	end
	return math.fmod(ree.toNumber(val), 1) == 1
end

function ree.recip(val)
	val = ree.correct(val)
	if ree.me(ree.abs(val), "2e323") then
		return ZERO
	end
	return ree.div(1, val)
end

function ree.pow(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	local sign, sign2 = val[1], val2[1]
	local array, array2 = val[2], val2[2]
	if ree.eq(val2, 0) then
		return { 1, { 1 } }
	end
	if ree.eq(val2, 1) then
		return val
	end
	if ree.le(val2, 0) then
		return ree.recip(ree.pow(val, ree.neg(val2)))
	end
	if ree.le(val, 0) and ree.isint(val2) then
		if ree.le(ree.mod(val2, 2), 1) then
			return ree.pow(ree.abs(val), val2)
		end
		return ree.neg(ree.pow(ree.abs(val), val2))
	end
	if ree.le(val, ZERO) then
		return NAN
	end
	if ree.eq(val, 1) then
		return { 1, { 1 } }
	end
	if ree.eq(val, ZERO) then
		return ZERO
	end
	if ree.meeq(ree.max(val, val2), maxPOW) then
		return ree.max(val, val2)
	end
	if ree.eq(val, 10) then
		if ree.me(val2, 0) then
			if array2[2] then
				array2[2] = array2[2] + 1
			else
				array2[2] = 1
			end
			return ree.correct(val2)
		else
			return ree.fromNumber(10 ^ ree.toNumber(val2))
		end
	end
	if ree.le(val2, 1) then
		ree.root(val, ree.recip(val2))
	end
	local ni = ree.toNumber(val) ^ ree.toNumber(val2)
	if ni <= maxInt then
		return ree.fromNumber(ni)
	end
	local f = ree.log10(val)
	local exporrrrrrrrrr = ree.mul(f, val2)
	return ree.pow(10, exporrrrrrrrrr)
end

function ree.mod(val, val2)
	val = ree.correct(val)
	val2 = ree.correct(val2)
	local sign, sign2 = val[1], val2[1]
	if ree.eq(val, ZERO) then
		return ZERO
	end
	if sign * sign2 == -1 then
		return ree.neg(ree.mod(ree.abs(val), ree.abs(val2)))
	end
	if sign == -1 then
		return ree.mod(ree.abs(val), ree.abs(val2))
	end
	return ree.sub(val, ree.mul(ree.floor(ree.div(val, val2)), val2))
end

function ree.root(val, val2)
	val, val2 = ree.correct(val), ree.correct(val2)
	if ree.eq(val2, 1) then
		return val
	end
	if ree.le(val2, ZERO) then
		return ree.recip(ree.root(val, ree.neg(val2)))
	end
	if ree.le(val2, 1) then
		return ree.pow(val, ree.recip(val2))
	end
	if ree.le(val, ZERO) and ree.isint(val2) and ree.eq(ree.mod(val2, 2), 1) then
		return ree.neg(ree.root(ree.neg(val), val2))
	end
	if ree.le(val, ZERO) then
		return NAN
	end
	if ree.eq(val, 1) then
		return { 1, { 1 } }
	end
	if ree.eq(val, ZERO) then
		return ZERO
	end
	if ree.me(ree.max(val, val2), maxPOW) then
		if ree.me(val, val2) then
			return val
		else
			return ZERO
		end
	end
	return ree.pow(10, ree.div(ree.log10(val), val2))
end

function ree.mul(val, val1)
	local x = ree.correct(val)
	local y = ree.correct(val1)
	if x[1] * y[1] == -1 then
		return ree.neg(ree.mul(ree.abs(x), ree.abs(y)))
	end
	if x[1] == -1 then
		return ree.mul(ree.abs(x), ree.abs(y))
	end
	if ree.eq(x, ZERO) or ree.eq(y, ZERO) then
		return ZERO
	end
	if ree.eq(y, { 1, { 1 } }) then
		return x
	end
	if ree.me(ree.max(x, y), maxMUL) then
		return ree.max(x, y)
	end
	local n = ree.toNumber(x) * ree.toNumber(y)
	if n <= maxAllowed then
		return ree.correct(n)
	end
	return ree.pow(10, ree.add(ree.log10(x), ree.log10(y)))
end

function ree.floor(x)
	if ree.isint(x) then
		return x
	end
	return ree.correct(math.floor(ree.toNumber(x)))
end

function ree.ceil(x)
	if ree.isint(x) then
		return x
	end
	return ree.correct(math.ceil(ree.toNumber(x)))
end

function ree.div(val, val1)
	local x = ree.correct(val)
	local y = ree.correct(val1)
	if x[1] * y[1] == -1 then
		return ree.neg(ree.div(ree.abs(x), ree.abs(y)))
	end
	if x[1] == -1 then
		return ree.div(ree.abs(x), ree.abs(y))
	end
	if ree.eq(y, ZERO) then
		return NAN
	end
	if ree.eq(y, { 1, { 1 } }) then
		return x
	end
	if ree.eq(x, ZERO) then
		return ZERO
	end
	if ree.me(ree.max(x, y), maxMUL) then
		if ree.me(x, y) then
			return x
		end
		return ZERO
	end
	local FILTER1 = ree.toNumber(x) / ree.toNumber(y)
	if FILTER1 <= maxAllowed then
		return ree.correct(FILTER1)
	end
	local qq = ree.pow(10, ree.sub(ree.log10(x), ree.log10(y)))
	local qqw = ree.floor(qq)
	if ree.le(ree.sub(qq, qqw), 1e-9) then
		return qqw
	end
	return qq
end

function ree.add(x, y)
	x = ree.correct(x)
	y = ree.correct(y)
	if x[1] == -1 then
		return ree.neg(ree.add(ree.neg(x), ree.neg(y)))
	end
	if y[1] == -1 then
		return ree.sub(x, ree.neg(y))
	end
	if ree.eq(x, ZERO) then
		return y
	end
	if ree.eq(y, ZERO) then
		return x
	end
	local p = ree.min(x, y)
	local q = ree.max(x, y)
	local a = nil
	if ree.me(q, maxADD) or ree.me(ree.div(q, p), maxInt) then
		a = q
	elseif q[2][2] == nil then
		a = ree.correct(ree.toNumber(x) + ree.toNumber(y))
	elseif q[2][2] == 1 then
		local b = nil
		if p[2][2] then
			b = p[2][1]
		else
			b = math.log10(p[2][1])
		end
		a = ree.correct({ 1, { b + math.log10(math.pow(10, q[2][1] - b) + 1), 1 } })
	end
	return a
end

function ree.sub(x, y)
	x = ree.correct(x)
	y = ree.correct(y)
	if x[1] == -1 then
		return ree.neg(ree.sub(ree.neg(x), ree.neg(y)))
	end
	if y[1] == -1 then
		return ree.add(x, ree.neg(y))
	end
	if ree.eq(x, y) then
		return ZERO
	end
	if ree.eq(y, ZERO) then
		return x
	end
	local p = ree.min(x, y)
	local q = ree.max(x, y)
	local FILTER2 = ree.me(y, x)
	local FILTER1
	if ree.me(q, maxADD) or ree.me(ree.div(q, p), maxADD) then
		FILTER1 = q
		if FILTER2 then
			FILTER1 = ree.neg(FILTER1)
		end
	elseif q[2][2] == nil then
		FILTER1 = ree.correct(ree.toNumber(x) - ree.toNumber(y))
	elseif q[2][2] == 1 then
		local b = nil
		if p[2][2] then
			b = p[2][1]
		else
			b = math.log10(p[2][1])
		end
		local DIFF = q[2][1] - b
		if DIFF > 20 then
			FILTER1 = ree.max(x, y)
			if FILTER2 then
				return ree.neg(FILTER1)
			end
			return FILTER1
		end
		FILTER1 = ree.correct({ 1, { b + math.log10(math.pow(10, q[2][1] - b) - 1), 1 } })
		if FILTER2 then
			FILTER1 = ree.neg(FILTER1)
		end
	end
	return FILTER1
end

function ree.sqrt(x)
	return ree.root(x, 2)
end

function ree.log(x, y)
	y = y or 2.7182818284590452353602874
	return ree.div(ree.log10(x), ree.log10(y))
end

function ree.exp(x)
	return ree.pow(2.7182818284590452353602874, x)
end

function ree.maxabs(x, y)
	return ree.max(ree.abs(x), ree.abs(y))
end

function ree.eternitytoOmega(num)
	local new = { num[1], {} }
	new[2][1] = num[3]
	new[2][2] = (num[2] >= 1) and num[2] or nil
	return new
end

function ree.pow10(x)
	return ree.pow(10, x)
end

function ree.gamma(x)
	x = ree.correct(x)
	if ree.me(x, maxPOW) then
		return x
	end
	if ree.me(x, maxADD) then
		return ree.exp(x)
	end
	if ree.me(x, maxInt) then
		return ree.exp(ree.mul(x, ree.sub(ree.log(x), 1)))
	end
	if ree.leeq(x, 171) then
		return ree.correct(fgamma(ree.toNumber(x)))
	end
	local q = x[2][1]
	if q > 1 then
		local t = q - 1
		local l = 0.9189385332046727
		l += (t + 0.5) * math.log(t)
		l -= t
		local n2 = t ^ 2
		local np = t
		local lm = 12 * np
		local adj = 1 / lm
		local l2 = l + adj
		if l2 == l then
			return ree.exp(l)
		end
		l = l2
		np *= 2
		lm = 360 * np
		adj = 1 / lm
		l2 = l - adj
		if l2 == l then
			return ree.exp(l)
		end
		l = l2
		np *= n2
		lm = 1260 * np
		local lt = 1 / lm
		l += lt
		np *= n2
		lm = 1680 * np
		lt = 1 / lm
		l -= lt
		return ree.exp(l)
	end
	return ree.recip(x)
end

function fact(x) -- x!
	local amo = 1
	for i = 1, x do
		amo *= i
	end
	return amo
end

function ree.fact(x)
	x = ree.correct(x)
	if ree.leeq(x, 170) then
		x = ree.toNumber(x)
		if x == math.floor(x) then
			return ree.correct(fact(x))
		end
		return ree.correct(fgamma(ree.toNumber(x) + 1))
	end
	return ree.gamma(ree.add(x, 1))
end

function ree.rand(min, max)
	local seed = math.random()
	local even = ree.sub(max, min)
	even = ree.mul(even, seed)
	return ree.add(even, min)
end

function ree.exporand(min, max)
	return ree.exp(ree.rand(ree.log(min), ree.log(max)))
end

function ree.toBigNum(val)
	val = ree.correct(val)
	local b = {}
	if #val[2] == 1 then
		return errorcorrection({ val[2][1] * val[1], 0 })
	end
	if val[2][2] == 1 then
		return errorcorrection({ 1 * val[1], val[2][1] })
	end
	if val[2][2] == 2 and math.log10(val[2][1]) <= 308 then
		return { 1 * val[1], 10 ^ val[2][1] }
	end
	return { 1 * val[1], 3e308 }
end

function ree.toScientific(x)
	x = ree.correct(x)
	if ree.le(x, 1000) then
		return ree.toNumber(x)
	end
	if ree.me(x, maxScientific) then
		return ree.toEs(x)
	end
	if ree.me(x, "ee13.9") then
		return "1e" .. ree.toScientific(ree.log10(x))
	end
	local function Decimal(val, amo)
		local a = math.floor(val * 10 ^ amo)
		a = a / 10 ^ amo
		return a
	end
	local array = x[2]
	if array[2] == nil then
		local exp = math.log10(array[1])
		local b = 10 ^ (exp - math.floor(exp))
		return Decimal(b, PrecisionDisplay) .. "e" .. math.floor(exp)
	end
	if array[2] == 1 then
		local exp = array[1]
		local b = 10 ^ (exp - math.floor(exp))
		return Decimal(b, PrecisionDisplay) .. "e" .. math.floor(exp)
	end
end

function ree.toShortScientific(x)
	x = ree.correct(x)
	if ree.le(x, 1000) then
		return ree.toNumber(x)
	end
	if ree.me(x, maxScientific) then
		return ree.toEs(x)
	end
	local x1 = x[1]
	local x2 = x[2]

	return string.rep("e", x2[2]) .. short(ree.toBigNum(x2[1]))
end

function ree.short(x)
	x = ree.correct(x)
	if ree.me(x, maxSuffix) then
		return ree.toShortScientific(x)
	end
	return short(ree.toBigNum(x))
end

function ree.toEnt(x)
	x = ree.correct(x)
	if x[2][3] then
		if x[2][3] > 1 or x[2][1] > 308 or x[2][2] > 1 then
			return ree.toShortHyperE(x)
		end
		x[2][2] = 10 ^ x[2][1]
		x[2][3] = nil
	end
	local part = "E(" .. x[2][2] .. ")"
	if x[1] == -1 then
		part = "-" .. part
	end
	return part .. x[2][1]
end

function ree.toShortEnt(x)
	x = ree.correct(x)
	if x[2][3] then
		if x[2][3] > 1 or x[2][1] > 308 or x[2][2] > 1 then
			return ree.toShortHyperE(x)
		end
		x[2][2] = 10 ^ x[2][1]
		x[2][3] = nil
	end
	local part = "E(" .. ree.short(x[2][2]) .. ")"
	if x[1] == -1 then
		part = "-" .. part
	end
	return part .. ree.short(x[2][1])
end

function ree.toEs(x)
	x = ree.correct(x)
	if #x[2] > 2 then
		return ree.toEnt(x)
	end
	if x[2][2] == nil then
		return ree.short(x)
	end
	if x[2][2] > maxEs then
		return ree.toEnt(x)
	end
	if x[1] == -1 then
		return "-" .. ree.toEs(ree.abs(x))
	end
	local function Decimal(val, amo)
		local a = math.floor(val * 10 ^ amo)
		a = a / 10 ^ amo
		return a
	end
	local estring = string.rep("e", x[2][2])
	return estring .. Decimal(x[2][1], 4)
end

function ree.toShortEs(x)
	x = ree.correct(x)
	if #x[2] > 2 then
		return ree.toShortEnt(x)
	end
	if x[2][2] == nil then
		return ree.short(x)
	end
	if x[2][2] > maxEs then
		return ree.toShortEnt(x)
	end
	if x[1] == -1 then
		return "-" .. ree.toShortEs(ree.abs(x))
	end
	local function Decimal(val, amo)
		local a = math.floor(val * 10 ^ amo)
		a = a / 10 ^ amo
		return a
	end
	local estring = string.rep("e", x[2][2])
	return estring .. ree.short(Decimal(x[2][1], 4))
end

function ree.toHyperE(x)
	x = ree.correct(x)
	if x[1] == -1 then
		return "-" .. ree.toHyperE(ree.abs(x))
	end
	if ree.le(x, maxInt) then
		return ree.short(x)
	end
	if ree.le(x, maxADD) then
		return "E" .. x[2][1]
	end
	local function Decimal(val, amo)
		local a = math.floor(val * 10 ^ amo)
		a = a / 10 ^ amo
		return a
	end
	local str = "E" .. Decimal(x[2][1], PrecisionDisplay) .. "#" .. x[2][2]
	for i = 3, #x[2] do
		str ..= "#" .. x[2][i] + 1
	end
	return str
end

function ree.toShortHyperE(x)
	x = ree.correct(x)
	if x[1] == -1 then
		return "-" .. ree.toShortHyperE(ree.abs(x))
	end
	if ree.le(x, maxInt) then
		return ree.short(x)
	end
	if ree.le(x, maxADD) then
		return "E" .. ree.short(x[2][1])
	end
	local function Decimal(val, amo)
		local a = math.floor(val * 10 ^ amo)
		a = a / 10 ^ amo
		return a
	end
	local str = "E" .. ree.short(Decimal(x[2][1], PrecisionDisplay)) .. "#" .. ree.short(x[2][2])
	for i = 3, #x[2] do
		str ..= "#" .. ree.short(x[2][i] + 1)
	end
	return str
end

function ree.lambertw(x)
	x = ree.correct(x)
	if ree.leeq(x, 1e308) then
		return f_lambertw(ree.toNumber(x))
	end
	if ree.me(x, maxPOW) then
		return x
	end
	if ree.me(x, maxMUL) then
		return ree.log10(x)
	end
	return Hlambertw(x)
end

function ree.slog(r, base)
	local x = copytab(ree.correct(r))
	base = ree.toOmega(base)
	if ree.le(x, ZERO) then
		return { -1, { 1 } }
	end
	if ree.eq(x, ONE) then
		return ZERO
	end
	if ree.eq(x, base) then
		return ONE
	end
	if ree.le(base, math.exp(1 / 2.7182818284)) then
		return x
	end
	if ree.me(ree.max(x, base), { 1, { 10000000000, 8, maxInt } }) then
		if ree.me(x, base) then
			return x
		end
		return ZERO
	end
	if ree.me(ree.max(x, base), maxPOW) then
		if ree.me(x, base) then
			x[2][3] -= 1
			return ree.sub(x, x[2][2])
		end
		return ZERO
	end
	local q = 0
	local t = (x[2][2] or 0) - (base[2][2] or 0)
	if t > 3 then
		local p = t - 3
		q += p
		x[2][2] -= p
	end
	for i = 1, 99 do
		if ree.le(x, ZERO) then
			x = ree.pow(base, x)
			q -= 1
		else
			if ree.leeq(x, 1) then
				return ree.toOmega(q + ree.toNumber(x) - 1)
			else
				q += 1
				x = ree.log(x, base)
			end
		end
	end
	if ree.me(x, 10) then
		return q
	end
end

function ree.tetrate(x, y)
	x = ree.correct(x)
	y = ree.correct(y)
	if ree.le(y, -2) then
		return NAN
	end
	if ree.eq(x, ZERO) then
		if ree.eq(y, 0) then
			return NAN
		end
		if ree.eq(ree.mod(y, 2), 0) then
			return ZERO
		end
		return { 1, { 1 } }
	end
	if ree.eq(x, { 1, { 1 } }) then
		if ree.eq(y, { -1, { 1 } }) then
			return NAN
		end
		return { 1, { 1 } }
	end
	if ree.eq(y, { -1, { 1 } }) then
		return ZERO
	end
	if ree.eq(y, 0) then
		return { 1, { 1 } }
	end
	if ree.eq(y, 1) then
		return x
	end
	if ree.eq(y, 2) then
		return ree.pow(x, x)
	end
	if ree.eq(x, 2) then
		if ree.eq(y, 3) then
			return ree.fromNumber(16)
		end
		if ree.eq(y, 4) then
			return ree.fromNumber(65536)
		end
	end
	local max = ree.max(x, y)
	if ree.me(max, { 1, { 10000000000, 8, maxInt } }) then
		return max
	end
	if ree.me(x, maxPOW) or ree.me(y, maxInt) then
		if ree.le(x, math.exp(1 / 2.7182818284)) then
			local nel = ree.neg(ree.log(x))
			return ree.div(ree.lambertw(nel), nel)
		end
		local q = copytab(ree.add(ree.slog(x, 10), y))
		q[2][3] = (y[2][3] or 0) + 1
		return ree.correct(q)
	end
	local yo = ree.toNumber(y)
	local fo = math.floor(yo)
	local ro = ree.pow(x, yo - fo)
	local mo = maxADD
	local lo = NAN
	local count = 0
	for i = 1, 100 do
		if not (fo ~= 0 and ree.le(ro, mo)) then
			break
		end
		count += 1
		if fo > 0 then
			ro = ree.pow(x, ro)
			if ree.eq(lo, ro) then
				fo = 0
				break
			end
			lo = ro
			fo -= 1
		else
			ro = ree.log(ro, x)
			if ree.eq(lo, ro) then
				fo = 0
				break
			end
			lo = ro
			fo += 1
		end
	end
	if count == 100 or ree.le(x, math.exp(1 / 2.7182818284)) then
		fo = 0
	end
	ro[2][2] = ro[2][2] and ro[2][2] + fo or fo
	return ree.correct(ro)
end

function ree.pentate(x, y)
	x = ree.correct(x)
	y = ree.correct(y)
	if ree.le(y, -2) then
		return NAN
	end
	if ree.eq(x, ZERO) then
		if ree.eq(y, 0) then
			return NAN
		end
		if ree.eq(ree.mod(y, 2), 0) then
			return ZERO
		end
		return { 1, { 1 } }
	end
	if ree.eq(x, { 1, { 1 } }) then
		if ree.eq(y, { -1, { 1 } }) then
			return NAN
		end
		return { 1, { 1 } }
	end
	if ree.eq(y, { -1, { 1 } }) then
		return ZERO
	end
	if ree.eq(y, 0) then
		return { 1, { 1 } }
	end
	if ree.eq(y, 1) then
		return x
	end
	if ree.eq(y, 2) then
		return ree.tetrate(x, x)
	end
	if ree.eq(x, 2) then
		if ree.eq(y, 3) then
			return ree.fromNumber(65536)
		end
	end
	local max = ree.max(x, y)
	if ree.me(max, { 1, { 10000000000, 8, maxInt } }) then
		return max
	end
	if ree.me(x, maxPOW) or ree.me(y, maxInt) then
		if ree.le(x, math.exp(1 / 2.7182818284)) then
			local nel = ree.neg(ree.log(x))
			return ree.div(ree.lambertw(nel), nel)
		end
		local q = copytab(ree.add(ree.slog(x, 10), y))
		q[2][3] = (y[2][3] or 0)
		q[2][4] = (y[2][4] or 0) + 1
		return ree.correct(q)
	end
	local yo = ree.toNumber(y)
	local fo = math.floor(yo)
	local ro = ree.pow(x, yo - fo)
	local mo = maxADD
	local lo = NAN
	local count = 0
	for i = 1, 100 do
		if not (fo ~= 0 and ree.le(ro, mo)) then
			break
		end
		count += 1
		if fo > 0 then
			ro = ree.tetrate(x, ro)
			if ree.eq(lo, ro) then
				fo = 0
				break
			end
			lo = ro
			fo -= 1
		else
			ro = ree.log(ro, x)
			if ree.eq(lo, ro) then
				fo = 0
				break
			end
			lo = ro
			fo += 1
		end
	end
	if count == 100 or ree.le(x, math.exp(1 / 2.7182818284)) then
		fo = 0
	end
	ro[2][3] = ro[2][3] and ro[2][3] + fo or fo
	return ree.correct(ro)
end

function ree.arrow(x, y, z) --oh ye
	x = ree.correct(x)
	z = ree.correct(y)
	if y == 0 then
		return ree.mul(x, y)
	end
	if y > ArrowLimit then
		if ree.me(x, 1) and ree.me(z, 1) then
			return INF
		end
	end
	if ree.eq(y, 1) then
		return x
	end
	if ree.eq(x, 0) then
		if y == 2 and ree.eq(y, 0) then
			return NAN
		end
		if y == 1 and ree.eq(y, 0) then
			return ONE
		end
		return ZERO
	end
	if ree.le(x, 0) or ree.le(y, 0) then
		if y >= 2 then
			return NAN
		end
		if y == 1 then
			return ree.pow(x, y)
		end
	end
	if y == 2 then
		return ree.tetrate(x, z)
	end
end

function ree.lbencode(onum)
	onum = ree.correct(onum)
	if ree.eq(onum, 0) then
		return 0
		-- For maximum performance, you do not need to encode 0.
	end
	local sign = onum[1]
	onum = onum[2]
	-- #onum
	local amo = #onum
	-- convert to float rn??
	if amo == 1 then
		-- mode 0: Native Float
		return sign * math.floor(math.log10((onum[1] + 1)) * 6.26775e14)
	elseif amo == 2 and onum[2] < 4 then
		-- mode 1: Native BigNum
		-- mode 2: Native Post-BigNum
		-- mode 3: Native EternityNum
		return sign * (math.floor(math.log10((onum[1] + 1)) * 6.26775e14) + onum[2] * 1e16)
	elseif amo == 2 and onum[2] <= 9999 then
		-- mode 4: Native Big EternityNum Numbers
		local cnum = 4e16
		cnum += math.log10((onum[1] + 1)) * 6.26775e8
		cnum += onum[2] * 1e10
		return sign * cnum
	elseif amo == 2 then
		-- mode 5: Native Extreme EternityNum Numbers
		local cnum = 5e16
		cnum += math.log10((onum[2] + (math.log10(onum[1]) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo == 3 and onum[3] == 1 then
		-- mode 6: Beyond EternityNum
		local cnum = 6e16
		cnum += math.log10((onum[2] + (math.log10(onum[1]) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo == 3 and onum[3] == 2 then
		-- mode 7: Post-EternityNum
		local cnum = 7e16
		cnum += math.log10((onum[2] + (math.log10(onum[1]) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo == 3 and onum[3] < 9999 then
		-- mode 8: Pentation Empire
		local cnum = 8e16
		cnum += math.log10((onum[2] + (math.log10(onum[1]) / 16) + 1)) * 6.26775e8
		cnum += onum[3] * 1e10
		return sign * cnum
	elseif amo == 3 then
		-- mode 9: Ultra Pentation
		local cnum = 9e16
		cnum += math.log10((onum[3] + (math.log10(onum[2] + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo == 4 then
		-- mode 10: Big Number Territory
		local cnum = 1e17
		cnum += math.log10((onum[4] + (math.log10(onum[3] + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo == 5 then
		-- mode 11: I Do Not Konw
		local cnum = 1.1e17
		cnum += math.log10((onum[5] + (math.log10(onum[4] + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif amo > 5 and amo < 917 then
		-- good until 916 arrays
		local cnum = amo * 1e16 + 6e16
		cnum += math.log10((onum[amo] + (math.log10(onum[amo - 1] + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	else
		return sign * 9223372036854775808
	end
end

function ree.lbdecode(int)
	if int == 0 then
		return { 1, { 0 } }
	end
	local sign = math.sign(int)
	int = math.abs(int)
	local mode = math.floor(int / 1e16)
	if mode >= 3 then
		int -= 1
	end
	if mode == 0 then
		return { sign, { 10 ^ (int / 6.26775e14) - 1 } }
	elseif mode < 4 then
		return { sign, { 10 ^ (math.fmod(int, 1e16) / 6.26775e14) - 1, mode } }
	elseif mode == 4 then
		local remainder = math.fmod(int, 1e10)
		return { sign, { 10 ^ (remainder / 6.26775e8) - 1, math.floor((int - 4e16) / 1e10) } }
	elseif mode == 5 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		return { sign, { arg1, math.floor(arrows) } }
	elseif mode == 6 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		return { sign, { arg1, math.floor(arrows), 1 } }
	elseif mode == 7 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		return { sign, { arg1, math.floor(arrows), 2 } }
	elseif mode == 8 then
		local arg3 = math.floor((int - 8e16) / 1e10)
		local remainder = math.fmod(int, 1e10) * 1e6
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		return { sign, { arg1, math.floor(arrows), math.floor(arg3) } }
	elseif mode == 9 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		return { sign, { 1, math.floor(arg1), math.floor(arrows) } }
	elseif mode == 10 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = 10 ^ (math.fmod(arrows, 1) * 16)
		local hixd = { sign, { 1, 0, math.floor(arg1), math.floor(arrows) } }
		if hixd[2][4] == 0 then
			table.remove(hixd[2], 4)
		end
		return hixd
	else
		local zeros = mode - 10
		local remainder = math.fmod(int, 1e16)
		local arrows = 10 ^ (remainder / 6.26775e14) - 1
		local arg1 = maxInt ^ (math.fmod(arrows, 1))
		local xd = { 1, 0 }
		for i = 1, zeros do
			table.insert(xd, 0)
		end
		table.insert(xd, math.floor(arg1))
		table.insert(xd, math.floor(arrows))
		if xd[zeros + 4] == 0 then
			table.remove(xd)
		end
		return { sign, xd }
	end
end

--bignum part ; )
function errorcorrection(bnum)
	local signal = "+"
	if bnum[1] == 0 then
		return { 0, 0 }
	end
	if bnum[1] < 0 then
		signal = "-"
	end
	if signal == "-" then
		bnum[1] = bnum[1] * -1
	end
	local signal2 = "+"
	if bnum[2] < 0 then
		signal2 = "-"
		bnum[2] = bnum[2] * -1
	end
	if math.fmod(bnum[2], 1) > 0 and signal2 == "-" then
		bnum[1] = bnum[1] * (10 ^ (1 - math.fmod(bnum[2], 1)))
		bnum[2] = math.floor(bnum[2]) + 1
	elseif math.fmod(bnum[2], 1) > 0 and signal2 == "+" then
		bnum[1] = bnum[1] * (10 ^ math.fmod(bnum[2], 1))
		bnum[2] = math.floor(bnum[2])
	end
	if signal2 == "-" then
		bnum[2] = bnum[2] * -1
	end
	local DgAmo = math.log10(bnum[1])
	DgAmo = math.floor(DgAmo)
	bnum[1] = bnum[1] / 10 ^ DgAmo
	bnum[2] = bnum[2] + DgAmo
	bnum[2] = math.floor(bnum[2])
	if signal == "-" then
		bnum[1] = bnum[1] * -1
	end
	return bnum
end

function bnumtostr(bnum)
	return tostring(bnum[1]) .. "e" .. tostring(bnum[2])
end

function bnumtofloat(bnum)
	return tonumber(bnumtostr(bnum))
end

function commas(Value)
	if Value < 1e3 then
		return Value
	end
	local Number
	local Formatted = math.floor(Value * 100) / 100
	if Value < 10 ^ 13 then
		while Number ~= 0 do
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		end
		return Formatted
	elseif Value < 10 ^ 26 then
		local Formatted2 = math.floor(Value / 10 ^ 12)
		Formatted = math.fmod(Value, 10 ^ 12)
		while Number ~= 0 do
			Formatted2, Number = string.gsub(Formatted2, "^(-?%d+)(%d%d%d)", "%1,%2")
		end
		Number = nil
		while Number ~= 0 do
			Formatted, Number = string.gsub(Formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		end
		local TpFormatted = math.fmod(Value, 10 ^ 12)
		local String = Formatted2 .. ","
		if TpFormatted == 0 then
			String ..= "000,000,000,000"
		elseif TpFormatted < 10 then
			String ..= "000,000,000,00"
		elseif TpFormatted < 100 then
			String ..= "000,000,000,0"
		elseif TpFormatted < 1000 then
			String ..= "000,000,000,"
		elseif TpFormatted < 10000 then
			String ..= "000,000,00"
		elseif TpFormatted < 100000 then
			String ..= "000,000,0"
		elseif TpFormatted < 1000000 then
			String ..= "000,000,"
		elseif TpFormatted < 10000000 then
			String ..= "000,00"
		elseif TpFormatted < 100000000 then
			String ..= "000,0"
		elseif TpFormatted < 1000000000 then
			String ..= "000,"
		elseif TpFormatted < 10000000000 then
			String ..= "00"
		elseif TpFormatted < 100000000000 then
			String ..= "0"
		end
		if TpFormatted > 0 then
			String ..= Formatted
		end
		return String
	else
		return "9,999,999,999,999,999,999,999,999,999+"
	end
end

function short(bnum)
	local SNumber = bnum[2]
	local SNumber1 = bnum[1]
	local leftover = math.fmod(SNumber, 3)
	SNumber = math.floor(SNumber / 3)
	SNumber = SNumber - 1
	if SNumber <= -1 then
		return math.floor(bnumtofloat(bnum) * 100 + 0.000000001) / 100
	end
	local FirstOnes = { "", "U", "D", "T", "q", "Q", "s", "S", "O", "N" }
	local SecondOnes = { "", "d", "v", "t", "qg", "Qg", "sg", "Sg", "o", "n" }
	local ThirdOnes = { "", "C", "Du", "Tr", "Qa", "Qi", "Se", "Si", "Ot", "Ni" }
	local MultOnes = {
		"",
		"Mi",
		"Mc",
		"Na",
		"Pi",
		"Fm",
		"At",
		"Zp",
		"Yc",
		"Xo",
		"Ve",
		"Me",
		"Due",
		"Tre",
		"Te",
		"Pt",
		"He",
		"Hp",
		"Oct",
		"En",
		"Ic",
		"Mei",
		"Dui",
		"Tri",
		"Teti",
		"Pti",
		"Hei",
		"Hp",
		"Oci",
		"Eni",
		"Tra",
		"TeC",
		"MTc",
		"DTc",
		"TrTc",
		"TeTc",
		"PeTc",
		"HTc",
		"HpT",
		"OcT",
		"EnT",
		"TetC",
		"MTetc",
		"DTetc",
		"TrTetc",
		"TeTetc",
		"PeTetc",
		"HTetc",
		"HpTetc",
		"OcTetc",
		"EnTetc",
		"PcT",
		"MPcT",
		"DPcT",
		"TPCt",
		"TePCt",
		"PePCt",
		"HePCt",
		"HpPct",
		"OcPct",
		"EnPct",
		"HCt",
		"MHcT",
		"DHcT",
		"THCt",
		"TeHCt",
		"PeHCt",
		"HeHCt",
		"HpHct",
		"OcHct",
		"EnHct",
		"HpCt",
		"MHpcT",
		"DHpcT",
		"THpCt",
		"TeHpCt",
		"PeHpCt",
		"HeHpCt",
		"HpHpct",
		"OcHpct",
		"EnHpct",
		"OCt",
		"MOcT",
		"DOcT",
		"TOCt",
		"TeOCt",
		"PeOCt",
		"HeOCt",
		"HpOct",
		"OcOct",
		"EnOct",
		"Ent",
		"MEnT",
		"DEnT",
		"TEnt",
		"TeEnt",
		"PeEnt",
		"HeEnt",
		"HpEnt",
		"OcEnt",
		"EnEnt",
		"Hect",
		"MeHect",
	}
	if bnum[2] == 1 / 0 then
		if bnum[1] < 0 then
			return "-Infinity"
		else
			return "Infinity"
		end
	end
	-- suffix part
	if SNumber == 0 then
		return commas(bnumtofloat(bnum))
	elseif SNumber == 1 then
		return math.floor(SNumber1 * 10 ^ leftover * 100 + 0.000000001) / 100 .. "M"
	elseif SNumber == 2 then
		return math.floor(SNumber1 * 10 ^ leftover * 100 + 0.000000001) / 100 .. "B"
	end
	local txt = ""
	local function suffixpart(n)
		local Hundreds = math.floor(n / 100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n / 10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n / 1)
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	local function suffixpart2(n)
		if n > 0 then
			n = n + 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		local Hundreds = math.floor(n / 100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n / 10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n / 1)
		txt = txt .. FirstOnes[Ones + 1]
		txt = txt .. SecondOnes[Tens + 1]
		txt = txt .. ThirdOnes[Hundreds + 1]
	end
	if SNumber < 1000 then
		suffixpart(SNumber)
		return math.floor(SNumber1 * 10 ^ leftover * 100 + 0.000000001) / 100 .. txt
	end
	for i = #MultOnes, 0, -1 do
		if SNumber >= 10 ^ (i * 3) then
			suffixpart2(math.floor(SNumber / 10 ^ (i * 3)) - 1)
			txt = txt .. MultOnes[i + 1]
			SNumber = math.fmod(SNumber, 10 ^ (i * 3))
		end
	end
	return math.floor(SNumber1 * 10 ^ leftover * 100 + 0.000000001) / 100 .. txt
end

-- Making it easier for SamirDevs to use this for OperatorSim lol.

function ree.onflt(onum)
	return ree.toNumber(onum)
end

function ree.flton(flt)
	return ree.toOmega(flt)
end

function ree.onstr(onum)
	return ree.toString(onum)
end

function ree.stron(str)
	return ree.toOmega(str)
end

function ree.equal(onum1, onum2)
	return ree.eq(onum1, onum2)
end

function ree.moreequal(onum1, onum2)
	return ree.meeq(onum1, onum2)
end

function ree.lessequal(onum1, onum2)
	return ree.leeq(onum1, onum2)
end

function ree.more(onum1, onum2)
	return ree.me(onum1, onum2)
end

function ree.less(onum1, onum2)
	return ree.le(onum1, onum2)
end

function ree.abbreviate(onum)
	onum = ree.correct(onum)
	if ree.eq(onum, { 1, { 0 } }) then
		return "0"
	elseif ree.le(onum, { 1, { 0.000000001 } }) then
		return "1 / " .. ree.short(ree.div(1, onum))
	elseif ree.le(onum, maxSuffix) then
		return ree.short(onum)
	elseif ree.le(onum, maxScientific) then
		return ree.toShortScientific(onum)
	elseif ree.le(onum, { 1, maxEs, 1 }) then
		return ree.toShortEs(onum)
	elseif ree.le(onum, { 1, 1e306, 1 }) then
		return ree.toShortEnt(onum)
	else
		return ree.toShortHyperE(onum)
	end
end

return ree
