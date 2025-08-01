--!optimize 2
--!native

--[[
AlyaNum: Library for performing mathematical operations on numbers exceeding 2^1024.
Implements a number system with support for hyperoperations (tetration, pentation, etc.) and extremely large values.
]]

--- The number of decimal points to use when formatting numbers.
local DECIMAL_POINTS = 2

--- The default abbreviation style for large numbers.
local DEFAULT_ABBREVIATION: "suffix" | "scientific" = "suffix"

--- The biggest float64 number that can be represented. Equal to 1.797693015e308.
local FLOAT64_LIMIT = 1.797693015e308

--- The logarithm of the biggest float64 number that can be represented. Equal to 308.2547155. 
local LOG10_FLOAT64_LIMIT = math.log10(FLOAT64_LIMIT)

--- The biggest float64 number that can be safely represented without losing precision. Equal to 9.0071993e15.
local FLOAT64_SAFE_LIMIT = math.pow(2, 53) - 1

--- The logarithm of the biggest float64 number that can be safely represented without losing precision. Equal to 15.95458977.
local LOG10_FLOAT64_SAFE_LIMIT = math.log10(FLOAT64_SAFE_LIMIT)

--- Infinity. Equal to math.huge.
local HUGE = math.huge

--- Suffixes used for number formatting. See AlyaNum.changeSuffixes for customization.
--- @see https://googology.fandom.com/wiki/Names_of_large_numbers
local suffixes = {
	beginning = { "K", "M", "B" },
	first = { "U", "D", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No" },
	second = { "De", "Vt", "Tg", "Qdg", "Qng", "Sxg", "Spg", "Ocg", "Nog" },
	third = { "Ce", "Dce", "Tce", "Qdce", "Qnce", "Sxce", "Spce", "Occe", "Noce" },
	mult = {
		"Mi","Mc","Na","Pi","Fm","At","Zp","Yc", "Xo", "Ve", "Me", 
		"Due", "Tre", "Te", "Pt", "He", "Hp", "Oct", "En", "Ic", "Mei", 
		"Dui", "Tri", "Teti", "Pti", "Hei", "Hp", "Oci", "Eni", "Tra","TeC",
		"MTc","DTc","TrTc","TeTc","PeTc","HTc","HpT","OcT","EnT","TetC","MTetc",
		"DTetc","TrTetc","TeTetc","PeTetc","HTetc","HpTetc","OcTetc","EnTetc","PcT",
		"MPcT","DPcT","TPCt","TePCt","PePCt","HePCt","HpPct","OcPct","EnPct","HCt",
		"MHcT","DHcT","THCt","TeHCt","PeHCt","HeHCt","HpHct","OcHct","EnHct","HpCt",
		"MHpcT","DHpcT","THpCt","TeHpCt","PeHpCt","HeHpCt","HpHpct","OcHpct","EnHpct",
		"OCt","MOcT","DOcT","TOCt","TeOCt","PeOCt","HeOCt","HpOct","OcOct","EnOct","Ent","MEnT",
		"DEnT","TEnt","TeEnt","PeEnt","HeEnt","HpEnt","OcEnt","EnEnt","Hect", "MeHect"}
}
local DP_OFFSET = math.pow(10, DECIMAL_POINTS)

--- The base version of an AlyaNum object, stripped of its metatables and metamethods.
--- This type commonly appears when sending AlyaNum objects over the client-server boundary or saving it in datastores.
--- @example
--- {sign: -1, multiplicand: 4, exponent: 2, tetrate: 1, pentate: 0, hexate: 0, heptate: 0}
--- This represents -1 * 10 ^^ (10 ^ (10 ^ 4)).
export type BaseAlyaNum = { sign: number, multiplicand: number, exponent: number, tetrate: number, pentate: number, hexate: number, heptate: number }

--- An object representing a number in this library. This could be a number primitive, BaseAlyaNum or AlyaNum.
export type Number = BaseAlyaNum | number | AlyaNum

--- @class AlyaNum
--- Library for performing mathematical operations on numbers exceeding 2^1024.
local AlyaNum = {}
AlyaNum.__index = AlyaNum


function fix(number: BaseAlyaNum): AlyaNum
	if number.sign == 0 then -- its just 0
		number.multiplicand = 0
		number.exponent = 0
		number.tetrate = 0
		number.pentate = 0
		number.hexate = 0
		number.heptate = 0
		return setmetatable(number, AlyaNum)
	elseif math.sign(number.multiplicand) == -1 then
		number.multiplicand = math.abs(number.multiplicand)
		number.sign = -number.sign
	end
	if number.multiplicand >= FLOAT64_SAFE_LIMIT then
		number.multiplicand = math.log10(number.multiplicand)
		number.exponent += 1
	end

	if number.exponent == 0 then
		local total = number.tetrate + number.pentate + number.hexate + number.heptate
		if number.multiplicand == 0 and total == 0 then -- its just 0
			number.sign = 0
			return setmetatable(number, AlyaNum)
		elseif number.multiplicand == 1 and total == 1 then -- case for 1 * 10^^..^^1
			number.multiplicand = 10
			number.tetrate = 0
			number.pentate = 0
			number.hexate = 0
			number.heptate = 0
		end
	end

	if number.multiplicand < LOG10_FLOAT64_SAFE_LIMIT and number.exponent > 0 then
		number.multiplicand = math.pow(10, number.multiplicand)
		number.exponent -= 1
		if number.multiplicand < LOG10_FLOAT64_SAFE_LIMIT and number.exponent > 0 then -- do it twice for cherry on top(??)
			number.multiplicand = math.pow(10, number.multiplicand)
			number.exponent -= 1
		end
	end

	-- if above safe limit, increment next hyperoperation by 1
	if number.hexate >= FLOAT64_SAFE_LIMIT then
		number.multiplicand = math.log10(number.hexate)
		number.heptate += 1
		number.exponent = 1
		number.tetrate = 0
		number.pentate = 0
		number.hexate = 0
	elseif number.pentate >= FLOAT64_SAFE_LIMIT then
		number.multiplicand = math.log10(number.pentate)
		number.hexate += 1
		number.exponent = 1
		number.tetrate = 0
		number.pentate = 0
	elseif number.tetrate >= FLOAT64_SAFE_LIMIT then
		number.multiplicand = math.log10(number.tetrate)
		number.pentate += 1
		number.exponent = 1
		number.tetrate = 0
	elseif number.exponent >= FLOAT64_SAFE_LIMIT then
		number.multiplicand = math.log10(number.exponent)
		number.tetrate += 1
		number.exponent = 1
	end

	-- floor all hyperoperations
	--number.exponent = math.floor(number.exponent)
	--number.tetrate = math.floor(number.tetrate)
	--number.pentate = math.floor(number.pentate)
	--number.hexate = math.floor(number.hexate)
	--number.heptate = math.floor(number.heptate)

	return setmetatable(number, AlyaNum)
end

--- Create a new AlyaNum object from a primitive number or BaseAlyaNum.
--- @param number number | BaseAlyaNum
--- @returns AlyaNum
function AlyaNum.new(number: number | BaseAlyaNum): AlyaNum
	if type(number) == "number" then
		if number == HUGE then
			error("cannot parse math.huge")
			-- dont use AlyaNum.new for numbers larger than 10^308;
			-- either split it into two smaller numbers e.g. AlyaNum.new(10):pow(900) or use AlyaNum.fromScientific
		end
		return fix({ sign = math.sign(number), multiplicand = math.abs(number), exponent = 0, tetrate = 0, pentate = 0, hexate = 0, heptate = 0 })
	end
	return setmetatable(number :: BaseAlyaNum, AlyaNum)
end

-- cached numbers
local ZERO = AlyaNum.new(0)
local ONE = AlyaNum.new(1)
local TWO = AlyaNum.new(2)
local THREE = AlyaNum.new(3)
local NEG_ONE = AlyaNum.new(-1)
local NEG_TWO = AlyaNum.new(-2)
local TEN = AlyaNum.new(10)
local E = AlyaNum.new(math.exp(1))
local ERECIPE = AlyaNum.new(math.exp(1/math.exp(1)))

local E308 = AlyaNum.new(1e308)
local LAMBERTW_TOL = 1e-10
local H_LAMBERTW_TOL = AlyaNum.new(LAMBERTW_TOL)
local MAX_SAFE = AlyaNum.new(FLOAT64_SAFE_LIMIT)
local MAX_ALLOWED = AlyaNum.new(FLOAT64_LIMIT)
local MAX_ADD = AlyaNum.new({sign = 1, multiplicand = FLOAT64_SAFE_LIMIT, exponent = 1, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
local MAX_MUL = AlyaNum.new({sign = 1, multiplicand = FLOAT64_SAFE_LIMIT, exponent = 2, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
local MAX_POW = AlyaNum.new({sign = 1, multiplicand = 1, exponent = FLOAT64_SAFE_LIMIT, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
local MAX_TETRATE = AlyaNum.new({sign = 1, multiplicand = 10000000000, exponent = 8, tetrate = FLOAT64_SAFE_LIMIT, pentate = 0, hexate = 0, heptate = 0})
local MAX_PENTATE = AlyaNum.new({sign = 1, multiplicand = 10000000000, exponent = 8, tetrate = 8, pentate = FLOAT64_SAFE_LIMIT, hexate = 0, heptate = 0})
local MAX_HEXATE = AlyaNum.new({sign = 1, multiplicand = 10000000000, exponent = 8, tetrate = 8, pentate = 8, hexate = FLOAT64_SAFE_LIMIT, heptate = 0})
local MAX_FRACTIONAL = AlyaNum.new(0.000000001)
local MAX_SUFFIX = AlyaNum.new({sign = 1, multiplicand = 3000000, exponent = 1, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
local MAX_SCIENTIFIC = AlyaNum.new({sign = 1, multiplicand = 300008, exponent = 4, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
local MAX_E_CHAIN = AlyaNum.new({sign = 1, multiplicand = 10000000000, exponent = 8, tetrate = 1, pentate = 0, hexate = 0, heptate = 0})
local MAX_ENT = AlyaNum.new({sign = 1, multiplicand = 306, exponent = 1, tetrate = 2, pentate = 0, hexate = 0, heptate = 0})

--- Add two AlyaNum objects. Macro for AlyaNum + AlyaNum.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function add(self: AlyaNum, number: AlyaNum): AlyaNum
	if self.sign == 0 then
		return number
	elseif number.sign == 0 then
		return self
	end

	local minAbsNum, maxAbsNum = absMinmax(self, number)

	if maxAbsNum.heptate ~= 0 or maxAbsNum.hexate ~= 0 or maxAbsNum.pentate ~= 0 or maxAbsNum.tetrate ~= 0 or maxAbsNum.exponent > 1 then
		-- number too big to matter
		return maxAbsNum
	end
	
	if maxAbsNum.exponent == 0 then
		-- minAbsNum exponent is 0
		-- no need for fancy calculations just add them lol
		return fix({sign = 1, multiplicand = (minAbsNum.sign * minAbsNum.multiplicand) + (maxAbsNum.sign * maxAbsNum.multiplicand), exponent = 0, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	end
	
	local adjMinMult = minAbsNum.exponent == 0 and math.log10(minAbsNum.multiplicand) or minAbsNum.multiplicand
	
	-- both exponents are 1
	if maxAbsNum.multiplicand - adjMinMult >= LOG10_FLOAT64_LIMIT then
		return maxAbsNum
	end
	
	
	local minSign, maxSign, maxMult = minAbsNum.sign, maxAbsNum.sign, maxAbsNum.multiplicand

	-- Handles negatives and addition logic
	if maxSign == minSign then
		
		-- 10^(x+log(10^(y-x)+1)) = 10^x+10^y
		return fix({sign = maxSign, multiplicand = adjMinMult + math.log10(math.pow(10, maxMult - adjMinMult) + 1), exponent = 1, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	end
	
	if adjMinMult == maxMult then -- x + -x = 0
		return ZERO
	end
	
	-- maxMult will always be higher than adjMinMult, so the resulting number is signed in maxSign
	
	-- 10^(x+log(10^(y-x)-1)) = 10^x-10^y
	return fix({sign = maxSign, multiplicand = adjMinMult + math.log10(math.pow(10, maxMult - adjMinMult) - 1), exponent = 1, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
end

--- Multiply two AlyaNum objects. Macro for AlyaNum * AlyaNum.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function mul(self: AlyaNum, number: AlyaNum): AlyaNum
	if self.sign == 0 or number.sign == 0 then
		return ZERO

	elseif equalsOne(number) then
		return self
	end

	local maxNum = absMax(self, number)
	if absMoreThan(maxNum, MAX_MUL) then
		return maxNum -- just dont bother
	end

	if self.exponent < 2 and number.exponent < 2 then
		local reverted = (self.exponent == 1 and math.pow(10, self.multiplicand) or self.multiplicand) * (number.exponent == 1 and math.pow(10, number.multiplicand) or number.multiplicand)
		if reverted < FLOAT64_LIMIT then
			return AlyaNum.new(self.sign * number.sign * reverted)
		end
	end

	local result = mutablePow10(add(mutableLog10(abs(self)), mutableLog10(abs(number)))) -- 10^(log(x)+log(y)) = x*y
	result.sign *= self.sign * number.sign
	return result
end

--- Divide two AlyaNum objects. Macro for AlyaNum / AlyaNum.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function div(self: AlyaNum, number: AlyaNum): AlyaNum
	if self.sign == 0 or number.sign == 0 then
		return ZERO

	elseif equalsOne(number) then
		return self
	end

	local maxNum = absMax(self, number)
	if absMoreThan(maxNum, MAX_MUL) then
		return maxNum -- just dont bother
	end

	if self.exponent < 2 and number.exponent < 2 then
		local reverted = (self.exponent == 1 and math.pow(10, self.multiplicand) or self.multiplicand) / (number.exponent == 1 and math.pow(10, number.multiplicand) or number.multiplicand)
		if reverted < FLOAT64_LIMIT then
			return AlyaNum.new(self.sign * number.sign * reverted)
		end
	end

	local result = mutablePow10(add(mutableLog10(abs(self)), mutableUnary(mutableLog10(abs(number))))) -- 10^(log(x)-log(y)) = x/y
	result.sign *= self.sign * number.sign
	return result
end

--- Raise a AlyaNum to the power of another AlyaNum. Macro for AlyaNum ^ AlyaNum.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function pow(self: AlyaNum, number: AlyaNum): AlyaNum
	if number.sign == 0 or equalsOne(self) then
		return ONE

	elseif equalsOne(number) then
		return self

	elseif number.sign == -1 then
		return reciprocal(pow(self, unary(number)))

	elseif self.sign == -1 and isInteger(number) then
		if lessThan(mod(number, TWO), ONE) then
			return pow(abs(self), number)
		end
		return mutableUnary(pow(abs(self), number))
	elseif self.sign <= 0 then -- produces imaginary numbers, not supported
		return ZERO

	elseif moreEquals(max(self, number), MAX_POW) then
		return max(self, number)

	elseif equals(self, TEN) then
		return pow10(number)

	elseif lessThan(number, ONE) then
		root(self, reciprocal(number))
	end
	return mutablePow10(mul(log10(self), number)) -- 10^(log(x)*y) = x^y
end

function mutablePow10(number: AlyaNum): AlyaNum
	if number.sign == 1 then
		number.exponent += 1
		return number
	else
		return AlyaNum.new(math.pow(10, toNumber(number)))
	end
end

function pow10(number: AlyaNum): AlyaNum
	if number.sign == 1 then
		return fix({
			sign = number.sign,
			multiplicand = number.multiplicand,
			exponent = number.exponent + 1,
			tetrate = number.tetrate,
			pentate = number.pentate,
			hexate = number.hexate,
			heptate = number.heptate,
		})
	else
		return AlyaNum.new(math.pow(10, toNumber(number)))
	end
end

--- Returns the n-th root of the AlyaNum. Macro for AlyaNum ^ (1/AlyaNum).
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function root(self: AlyaNum, number: AlyaNum): AlyaNum
	if equalsOne(number) then
		return self
	elseif number.sign == -1 or self.sign == -1 then
		return reciprocal(root(self, unary(number)))
	elseif lessThan(number, ONE) then
		return pow(self, reciprocal(number))
	elseif number.sign == -1 and isInteger(number) and equals(mod(number, TWO), ONE) then
		return mutableUnary(root(unary(self), number))
	elseif equalsOne(self) then
		return ONE
	elseif self.sign == 0 then
		return ZERO
	elseif moreThan(max(self, number), MAX_POW) then
		if moreThan(self, number)  then
			return self
		else
			return ZERO
		end
	end
	return mutablePow10(div(log10(self), number)) -- 10^(log(x)/y) = x^(1/y)
end

--- Returns the remainder of AlyaNum divided by another. Macro for AlyaNum % AlyaNum.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns AlyaNum
function mod(self: AlyaNum, number: AlyaNum): AlyaNum
	if self.sign == 0 then
		return ZERO
	end
	if self.sign * number.sign == -1 then
		return mutableUnary(mod(abs(self), abs(number)))
	end
	if self.sign == -1 then
		return mod(abs(self), abs(number))
	end
	return add(self, mutableUnary(mul(floor(div(self, number)), number))) -- x - (floor(x / y) * x) = x % y
end

function mutableLog10(self: AlyaNum): AlyaNum
	if self.sign <= 0 then
		return ZERO
	end

	if self.exponent == 0 then
		self.multiplicand = math.log10(self.multiplicand)
	else
		self.exponent -= 1
	end

	return self
end

function log10(self: AlyaNum): AlyaNum
	if self.sign <= 0 then
		return ZERO
	end
	return setmetatable(self.exponent == 0 and {
		sign = self.sign,
		multiplicand = math.log10(self.multiplicand),
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	} or {
		sign = self.sign,
		multiplicand = self.multiplicand,
		exponent = self.exponent - 1, -- literally the only thing this module is good at
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}, AlyaNum)	
end

--- Get the logarithm of the AlyaNum object with the specified number base.
--- @param self AlyaNum
--- @param number Base of the logarithm (AlyaNum)
--- @returns AlyaNum | nil
function log(self: AlyaNum, number: AlyaNum): AlyaNum
	if equals(number, TEN) then
		return log10(self)
	end
	return div(log10(self), log10(number))
end

--- Rounds down the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
--- @returns AlyaNum
function floor(self: AlyaNum): AlyaNum
	if (self.sign == -1 and lessThan(self, -MAX_SAFE)) or moreThan(self, MAX_SAFE) then
		return self
	end
	return AlyaNum.new(math.floor(toNumber(self)))
end

--- Rounds the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
--- @returns AlyaNum
function round(self: AlyaNum): AlyaNum
	if (self.sign == -1 and lessThan(self, -MAX_SAFE)) or moreThan(self, MAX_SAFE) then
		return self
	end
	return AlyaNum.new(math.floor(toNumber(self) + 0.5))
end

--- Rounds up the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
--- @returns AlyaNum
function ceil(self: AlyaNum): AlyaNum
	if (self.sign == -1 and lessThan(self, -MAX_SAFE)) or moreThan(self, MAX_SAFE) then
		return self
	end
	return AlyaNum.new(math.ceil(toNumber(self)))
end

--- Returns if the AlyaNum is an integer.
--- This operation is unsafe for numbers beyond 2^1024.
--- @returns boolean
function isInteger(self: AlyaNum): boolean
    if absMoreThan(self, MAX_SAFE) then
        return true
    end
	return math.fmod(toNumber(self), 1) == 0
end

--- Returns 1/AlyaNum.
--- @returns AlyaNum
function reciprocal(self: AlyaNum): AlyaNum
	if (self.sign == -1 and lessThan(self, -MAX_ALLOWED)) or moreThan(self, MAX_ALLOWED) then
		return ZERO
	end
	return div(ONE, self)
end

function f_lambertw(z: number): number
	local w: number
	local wn: number
	if z > 1.79e308 then
		return z
	elseif z == 0 then
		return z
	elseif z == 1 then
		return 0.56714329040978387299997
	elseif z < 10 then
		w = 0
	else
		w = math.log(z) - math.log(math.log(z))
	end
	for i=1,20 do
		wn = (z * math.exp(-w) + w * w) / (w + 1)
		if math.abs(wn - w) < LAMBERTW_TOL * math.abs(wn) then
			return wn
		else
			w = wn
		end
	end
	return w
end

function Hlambertw(self: AlyaNum): AlyaNum
	local wn: AlyaNum
	local w = log(self, E)
	for i=1,20 do
		wn = div(add(mul(self, pow(E, unary(w))), mul(w, w)), add(w, ONE))
		if lessThan(abs(add(wn, unary(w))), mul(H_LAMBERTW_TOL, abs(wn))) then
			return wn
		end
		w = wn
	end
	return w
end

--- Returns the value of the AlyaNum after going through the Lambert W function.
--- This is a fairly expensive operation.
--- @see https://en.wikipedia.org/wiki/Lambert_W_function
--- @returns AlyaNum
function lambertw(self: AlyaNum): AlyaNum
	if lessEquals(self, E308) then
		return AlyaNum.new(f_lambertw(toNumber(self)))
	elseif moreThan(self, MAX_POW) then
		return self
	elseif moreThan(self, MAX_MUL) then
		return log10(self)
	end
	return Hlambertw(self)
end

--- Returns the super-logarithm of the AlyaNum with the specified base.
--- @param self AlyaNum
--- @param base Base of the logarithm (AlyaNum)
--- @returns AlyaNum | nil
--- @see https://en.wikipedia.org/wiki/Iterated_logarithm
function slog(self: AlyaNum, base: Number): AlyaNum?
	local self = {
		sign = self.sign,
		multiplicand = self.multiplicand,
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}
	local base = AlyaNum.new(base)
	if self.sign == -1 then
		return NEG_ONE

	elseif equalsOne(self)  then
		return ZERO

	elseif equals(self, base) then
		return ONE

	elseif lessThan(base, ERECIPE) then
		return self

	elseif moreThan(max(self, base), MAX_TETRATE) then
		if moreThan(self, base) then
			return self
		end
		return ZERO

	elseif moreThan(max(self, base), MAX_POW) then
		if moreThan(self, base) then
			self.tetrate -= 1
			return fix(add(self, AlyaNum.new(-self.exponent)))
		end
		return ZERO
	end

	local q = 0
	local t = (self.exponent or 0) - (base.exponent or 0)
	if t > 3 then
		local p = t - 3
		q += p
		self.exponent -= p
	end
	for i = 1, 99 do
		if self.sign == -1 then
			self = pow(base, self)
			q -= 1
		else if lessEquals(self, ONE) then
				return AlyaNum.new(q + toNumber(self) - 1)	
			else 
				q += 1
				self = log(self, base)
			end
		end
	end
	if moreThan(self, TEN) then
		return AlyaNum.new(q)
	end
end

function pentlog(self: AlyaNum, base: Number): AlyaNum?
	local self = {
		sign = self.sign,
		multiplicand = self.multiplicand,
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}
	local base = AlyaNum.new(base)
	if self.sign == -1 then
		return NEG_ONE

	elseif equalsOne(self)  then
		return ZERO

	elseif equals(self, base) then
		return ONE

	elseif lessThan(base, ERECIPE) then
		return self

	elseif moreThan(max(self, base), MAX_PENTATE) then
		if moreThan(self, base) then
			return self
		end
		return ZERO

	elseif moreThan(max(self, base), MAX_TETRATE) then
		if moreThan(self, base) then
			self.pentate -= 1
			return fix(add(self, AlyaNum.new(-self.tetrate)))
		end
		return ZERO
	end

	local q = 0
	local t = (self.tetrate or 0) - (base.tetrate or 0)
	if t > 3 then
		local p = t - 3
		q += p
		self.tetrate -= p
	end
	for i = 1, 99 do
		if self.sign == -1 then
			self = tetrate(base, self)
			q -= 1
		else if lessEquals(self, ONE) then
				return AlyaNum.new(q + toNumber(self) - 1)	
			else 
				q += 1
				self = slog(self, base)
			end
		end
	end
	if moreThan(self, TEN) then
		return AlyaNum.new(q)
	end
end

function hextlog(self: AlyaNum, base: Number): AlyaNum?
	local self = {
		sign = self.sign,
		multiplicand = self.multiplicand,
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}
	local base = AlyaNum.new(base)
	if self.sign == -1 then
		return NEG_ONE

	elseif equalsOne(self)  then
		return ZERO

	elseif equals(self, base) then
		return ONE

	elseif lessThan(base, ERECIPE) then
		return self

	elseif moreThan(max(self, base), MAX_HEXATE) then
		if moreThan(self, base) then
			return self
		end
		return ZERO

	elseif moreThan(max(self, base), MAX_PENTATE) then
		if moreThan(self, base) then
			self.hexate -= 1
			return fix(add(self, AlyaNum.new(-self.pentate)))
		end
		return ZERO
	end

	local q = 0
	local t = (self.pentate or 0) - (base.pentate or 0)
	if t > 3 then
		local p = t - 3
		q += p
		self.pentate -= p
	end
	for i = 1, 99 do
		if self.sign == -1 then
			self = pentate(base, self)
			q -= 1
		else if lessEquals(self, ONE) then
				return AlyaNum.new(q + toNumber(self) - 1)	
			else 
				q += 1
				self = pentlog(self, base)
			end
		end
	end
	if moreThan(self, TEN) then
		return AlyaNum.new(q)
	end
end

--- Returns x^^y, where ^^ = tetration, and tetration is repeated exponentiation.
--- This is an expensive operation, performing generally ~8-80x worse than mul depending on different values and whether the height is an integer or not.
--- Do try to minimize calls of this function.
--- @param self AlyaNum
--- @param number Height of the power tower. If the height is not an integer, lambertw is used to approximate the final result.
--- @returns AlyaNum
--- @see https://en.wikipedia.org/wiki/Tetration
function tetrate(self: AlyaNum, number: AlyaNum): AlyaNum
	if lessThan(number, NEG_TWO) or equals(number, NEG_ONE) then -- negative tetrational values dont really exist so just return 0
		return ZERO

	elseif self.sign == 0 then
		if number.sign == 0 or equals(mod(number, TWO), ZERO) then -- 0^^0 = 0, 0^^any even number = 0
			return ZERO
		end
		return ONE -- 0^^any odd number = 1

	elseif equalsOne(self) or number.sign == 0 then -- 1^^y = 1 || x^^0 = 1
		return ONE

	elseif equalsOne(number) then -- x^^1 = x
		return self

	elseif equals(number, TWO) then -- x^^2 = x^x
		return pow(self, self)
	end

	local maxNum = max(self, number)
	if moreThan(maxNum, MAX_TETRATE) then -- number is too big for tetration to matter
		return maxNum

	elseif moreThan(self, MAX_POW) or moreThan(number, MAX_SAFE) then -- use lambertw for approximation
		if lessThan(self, ERECIPE) then
			local nel = mutableUnary(log(self, E))
			return div(lambertw(nel), nel)
		end

		local q = add(slog(self, TEN), number)
		q.tetrate += 1
		return fix(q)
	end
	local revertedTetrate = toNumber(number)
	local floored = math.floor(revertedTetrate)
	local result = pow(self, AlyaNum.new(revertedTetrate - floored))
	local check = ZERO
	local count = 0
	for i = 1, 100 do -- maximum times to perform algorithm is 100, should be enough for any number
		if not (floored ~= 0 and lessThan(result, MAX_ADD)) then
			break
		end
		count += 1
		if floored > 0 then
			result = pow(self, result)
			if equals(check, result) then -- nothing happens so just break
				floored = 0
				break
			end
			check = result
			floored -= 1
		else
			result = log(result, self) -- log since its negative now
			if equals(check, result) then
				floored = 0
				break
			end
			check = result
			floored += 1
		end
	end
	if count == 100 or lessThan(self, ERECIPE) then
		floored = 0
	end
	result.exponent += floored
	return fix(result)
end

--- Returns x^^^y, where ^^^ = pentation, and pentation is repeated tetration.
--- This is an expensive operation, performing generally ~8-80x worse than mul depending on different values and whether the height is an integer or not.
--- Do try to minimize calls of this function.
--- @param self AlyaNum
--- @param number Height of the tetration tower. If the height is not an integer, lambertw is used to approximate the final result.
--- @returns AlyaNum
--- @see https://en.wikipedia.org/wiki/Pentation
function pentate(self: AlyaNum, number: AlyaNum): AlyaNum
	if lessThan(number, NEG_TWO) or equals(number, NEG_ONE) then
		return ZERO

	elseif self.sign == 0 then
		if number.sign == 0 or equals(mod(number, TWO), ZERO)  then
			return ZERO
		end
		return ONE

	elseif equalsOne(self) or number.sign == 0 then
		return ONE

	elseif equalsOne(number) then
		return self

	elseif equals(number, TWO) then
		return tetrate(self, self)

	elseif equals(self, TWO) then
		if equals(number, THREE) then
			return AlyaNum.new(65536) -- dumb edge case
		end
	end

	local maxNum = max(self, number)
	if moreThan(maxNum, MAX_PENTATE) then
		return maxNum

	elseif moreThan(self, MAX_POW) or moreThan(number, MAX_SAFE) then
		if lessThan(self, ERECIPE) then
			local nel = mutableUnary(log(self, E))
			return div(lambertw(nel), nel)
		end
		local q = add(slog(self, TEN), number)
		q.tetrate = number.tetrate
		q.pentate = number.pentate + 1
		return fix(q)
	end
	local revertedPentate = toNumber(number)
	local floored = math.floor(revertedPentate)
	local result = pow(self, AlyaNum.new(revertedPentate - floored))
	local check = ZERO
	local count = 0
	for i = 1, 100 do
		if not (floored ~= 0 and lessThan(result, MAX_ADD)) then
			break
		end
		count += 1
		if floored > 0 then
			result = tetrate(self, result)
			if equals(check, result) then
				floored = 0
				break
			end
			check = result
			floored -= 1
		else
			result = slog(result, self)
			if equals(check, result) then
				floored = 0
				break
			end
			check = result
			floored += 1
		end
	end
	if count == 100 or lessThan(self, ERECIPE) then
		floored = 0
	end
	result.tetrate += floored
	return fix(result)
end

--- Returns x^^^^y, where ^^^^ = hexation, and hexation is repeated pentation.
--- This is an expensive operation, performing generally ~8-80x worse than mul depending on different values and whether the height is an integer or not.
--- Do try to minimize calls of this function.
--- @param self AlyaNum
--- @param number Height of the pentation tower. If the height is not an integer, lambertw is used to approximate the final result.
--- @returns AlyaNum
--- @see https://en.wikipedia.org/wiki/Hexation
function hexate(self: AlyaNum, number: AlyaNum): AlyaNum
	if lessThan(number, NEG_TWO) or equals(number, NEG_ONE) then
		return ZERO

	elseif self.sign == 0 then
		if number.sign == 0 or equals(mod(number, TWO), ZERO)  then
			return ZERO
		end
		return ONE

	elseif equalsOne(self) or number.sign == 0 then
		return ONE

	elseif equalsOne(number) then
		return self

	elseif equals(number, TWO) then
		return pentate(self, self)
	end

	local maxNum = max(self, number)
	if moreThan(maxNum, MAX_HEXATE) then
		return maxNum

	elseif moreThan(self, MAX_POW) or moreThan(number, MAX_SAFE) then
		if lessThan(self, ERECIPE) then
			local nel = mutableUnary(log(self, E))
			return div(lambertw(nel), nel)
		end
		local q = add(slog(self, TEN), number)
		q.tetrate = number.tetrate
		q.pentate = number.pentate
		q.hexate = number.hexate + 1
		return fix(q)
	end
	local revertedHexate = toNumber(number)
	local floored = math.floor(revertedHexate)
	local result = pow(self, AlyaNum.new(revertedHexate - floored))
	local check = ZERO
	local count = 0
	for i = 1, 100 do
		if not (floored ~= 0 and lessThan(result, MAX_ADD)) then
			break
		end
		count += 1
		if floored > 0 then
			result = pentate(self, result)
			if equals(check, result) then
				floored = 0
				break
			end
			check = result
			floored -= 1
		else
			result = pentlog(result, self)
			if equals(check, result) then
				floored = 0
				break
			end
			check = result
			floored += 1
		end
	end
	if count == 100 or lessThan(self, ERECIPE) then
		floored = 0
	end
	result.pentate += floored
	return fix(result)
end

--- Compares two numbers.
--- @param self AlyaNum
--- @param number AlyaNum
--- @returns 1 | -1 | 0
function compare(self: AlyaNum, number: AlyaNum): number
	if self.sign ~= number.sign then
		return self.sign > number.sign and 1 or -1
	elseif self.heptate ~= number.heptate then
		return self.heptate > number.heptate and 1 or -1
	elseif self.hexate ~= number.hexate then
		return self.hexate > number.hexate and 1 or -1
	elseif self.pentate ~= number.pentate then
		return self.pentate > number.pentate and 1 or -1
	elseif self.tetrate ~= number.tetrate then
		return self.tetrate > number.tetrate and 1 or -1
	elseif self.exponent ~= number.exponent then
		return self.exponent > number.exponent and 1 or -1
	elseif self.multiplicand ~= number.multiplicand then
		return self.multiplicand > number.multiplicand and 1 or -1
	else
		return 0
	end
end

function absCompare(self: AlyaNum, number: AlyaNum): number
	if self.heptate ~= number.heptate then
		return self.heptate > number.heptate and 1 or -1
	elseif self.hexate ~= number.hexate then
		return self.hexate > number.hexate and 1 or -1
	elseif self.pentate ~= number.pentate then
		return self.pentate > number.pentate and 1 or -1
	elseif self.tetrate ~= number.tetrate then
		return self.tetrate > number.tetrate and 1 or -1
	elseif self.exponent ~= number.exponent then
		return self.exponent > number.exponent and 1 or -1
	elseif self.multiplicand ~= number.multiplicand then
		return self.multiplicand > number.multiplicand and 1 or -1
	else
		return 0
	end
end

function equals(self: AlyaNum, number: AlyaNum): boolean
	return self.sign == number.sign and 
		self.multiplicand == number.multiplicand and 
		self.exponent == number.exponent and 
		self.tetrate == number.tetrate and 
		self.pentate == number.pentate and 
		self.hexate == number.hexate and 
		self.heptate == number.heptate
end

function moreThan(self: AlyaNum, number: AlyaNum): boolean
	return compare(self, number) == 1
end

function lessThan(self: AlyaNum, number: AlyaNum): boolean
	return compare(self, number) == -1
end

function moreEquals(self: AlyaNum, number: AlyaNum): boolean
	return compare(self, number) >= 0
end

function lessEquals(self: AlyaNum, number: AlyaNum): boolean
	return compare(self, number) <= 0
end

function absMoreThan(self: AlyaNum, number: AlyaNum): boolean
	return absCompare(self, number) == 1
end

function absLessThan(self: AlyaNum, number: AlyaNum): boolean
	return absCompare(self, number) == -1
end

function absMoreEquals(self: AlyaNum, number: AlyaNum): boolean
	return absCompare(self, number) >= 0
end

function absLessEquals(self: AlyaNum, number: AlyaNum): boolean
	return absCompare(self, number) <= 0
end

function equalsOne(self: AlyaNum): boolean
	return self.sign == 1 and self.multiplicand == 1 and self.exponent == 0 and self.tetrate == 0 and self.pentate == 0 and self.hexate == 0 and self.heptate == 0
end

function max(self: AlyaNum, number: AlyaNum): AlyaNum
	if moreThan(self, number) then
		return self
	else
		return number
	end
end

function min(self: AlyaNum, number: AlyaNum): AlyaNum
	if moreThan(self, number) then
		return number
	else
		return self
	end
end

function minmax(self: AlyaNum, number: AlyaNum): (AlyaNum, AlyaNum)
	if lessThan(self, number) then
		return self, number
	else
		return number, self
	end
end

function absMax(self: AlyaNum, number: AlyaNum): AlyaNum
	if absMoreThan(self, number) then
		return self
	else
		return number
	end
end

function absMin(self: AlyaNum, number: AlyaNum): AlyaNum
	if absMoreThan(self, number) then
		return number
	else
		return self
	end
end

function absMinmax(self: AlyaNum, number, AlyaNum): (AlyaNum, AlyaNum)
	if absLessThan(self, number) then
		return self, number
	else
		return number, self
	end
end

function mutableUnary(self: AlyaNum): AlyaNum
	self.sign = -self.sign
	return self
end

--- Flips the sign of the AlyaNum object. Equivalent to multiplying by -1.
--- @param self AlyaNum
--- @returns AlyaNum
function unary(self: AlyaNum): AlyaNum
	return setmetatable({
		sign = -self.sign,
		multiplicand = self.multiplicand,
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}, AlyaNum)
end

function mutableAbs(self: AlyaNum): AlyaNum
	self.sign = 1
	return self
end

--- Get the absolute value of the AlyaNum.
--- @param self AlyaNum
--- @returns AlyaNum
function abs(self: AlyaNum): AlyaNum
	return setmetatable({
		sign = 1,
		multiplicand = self.multiplicand,
		exponent = self.exponent,
		tetrate = self.tetrate,
		pentate = self.pentate,
		hexate = self.hexate,
		heptate = self.heptate
	}, AlyaNum)
end


-- number type conversion utils
function AlyaNum.fromOnoe(onoeNum: {mantissa: number, exponent: number} & BaseAlyaNum): AlyaNum
	local number: BaseAlyaNum
	if onoeNum.sign ~= nil then -- is an onoenum
		number = onoeNum :: BaseAlyaNum
	else -- probably already converted
		number = { sign = math.sign(onoeNum.mantissa), multiplicand = math.log10(onoeNum.mantissa) + onoeNum.exponent, exponent = 1, tetrate = 0, pentate = 0, hexate = 0, heptate = 0 }
	end
	return fix(number)
end

function AlyaNum.fromOmega(onum: unknown): AlyaNum
	local number: BaseAlyaNum
	if onum.sign ~= nil then -- probably already converted
		number = onum :: BaseAlyaNum
	else
		number = { sign = onum[1] or 0, multiplicand = onum[2][1] or 0, exponent = onum[2][2] or 0, tetrate = onum[2][3] or 0, 
			pentate = onum[2][4] or 0, hexate = onum[2][5]or 0, heptate = onum[2][6] or 0 }
	end
	return fix(number)
end

--- Reverts the AlyaNum back to a primitive number.
--- For numbers beyond 2^1024, this will return math.huge.
--- @param self AlyaNum
--- @returns number
function toNumber(self: AlyaNum): number
	if self.exponent >= 2 or (self.exponent == 1 and self.multiplicand > LOG10_FLOAT64_LIMIT) then
		return HUGE * self.sign
	end
	return self.exponent == 1 and math.pow(10, self.multiplicand) * self.sign or self.multiplicand * self.sign
end

function toSerika(self: AlyaNum): (number, number)
	local mantissa: number;
	local exponent: number;
	if self.exponent == 0 then
        mantissa = (self.multiplicand / math.pow(10, math.floor(math.log10(self.multiplicand)))) * self.sign
		exponent = math.floor(math.log10(self.multiplicand))
	elseif self.exponent == 1 then
		mantissa = math.pow(10, self.multiplicand - math.floor(self.multiplicand)) * self.sign
		exponent = math.floor(self.multiplicand)
	elseif self.exponent == 2 and self.multiplicand <= 308 then
		local exp = math.pow(10, self.multiplicand)
		mantissa = math.pow(10, (exp - math.floor(exp))) * self.sign
		exponent = math.floor(exp)
	else
		return 10, HUGE
	end
	return mantissa, exponent
end

-- imported from serikanum
function serikaNumEnforceDP(mantissa: number, exponent: number): string
	if DECIMAL_POINTS <= 0 then
		return tostring(math.floor(mantissa * math.pow(10, exponent)))
	else
		return tostring(math.floor(mantissa * math.pow(10, exponent) * DP_OFFSET) / DP_OFFSET)
	end
end

function getTier1Suffix(exponent: number, hasBeginning: boolean?): string?
	if exponent < 3 then
		return nil
	else
		local suffix = "";
		if exponent < HUGE then
			exponent = math.floor(exponent / 3) - 1
			if hasBeginning == true and exponent < 3 then
				suffix = suffixes.beginning[exponent + 1]
			else
				local firstDivisee = exponent
				local secondDivisee: number
				local thirdDivisee: number
				if exponent > 99 then
					thirdDivisee = math.floor(exponent / 100)
					suffix = suffixes.third[thirdDivisee]
					if suffix == nil then
						return nil
					end
				end
				if exponent > 9 then
					secondDivisee = math.floor(exponent / 10)
					if thirdDivisee ~= nil then
						secondDivisee -= thirdDivisee * 10
						firstDivisee -= thirdDivisee * 100
					end
					firstDivisee -= secondDivisee * 10
					local second = suffixes.second[secondDivisee]
					if second ~= nil then
						suffix = second .. suffix
					end
					local first = suffixes.first[firstDivisee]
					if first ~= nil then
						suffix = first .. suffix
					end
				else
					suffix = suffixes.first[firstDivisee]
				end
			end
		end
		return suffix
	end
end

function getTier2Suffix(exponent: number): string?
	if exponent == HUGE then
		return
	end
	exponent = math.floor(exponent / 3) - 1
	local suffix = ""
	for i = math.floor(math.log10(exponent) / 3), 0, -1 do
		local powed = math.pow(10, i * 3)
		if exponent >= powed then
			local part1Exponent = math.floor(exponent / powed)
			if part1Exponent > 1000 then
				part1Exponent = math.fmod(part1Exponent, 1000)
			end
			local part1 = getTier1Suffix((part1Exponent + 1) * 3, false)
			if part1 ~= nil and part1 ~= "U" then
				suffix ..= part1
			end
			if i ~= 0 then
				local part2 = suffixes.mult[i]
				if part2 ~= nil then
					suffix ..= part2
				end
			end
			exponent = math.fmod(exponent, powed)
		end
	end
	return suffix
end

function serikaNumToSuffix(mantissa: number, exponent: number): string?
	if exponent < 3 then
		return serikaNumEnforceDP(mantissa, exponent)
	end
	local suffix = exponent > 3002 and getTier2Suffix(exponent) or getTier1Suffix(exponent, true)
	return suffix and serikaNumEnforceDP(mantissa, exponent % 3) .. suffix
end


function numberToSuffix(number: number): string?
	local exponent = math.floor(math.log10(math.abs(number)))
	return serikaNumToSuffix(number / (math.pow(10, exponent)), exponent)
end

function serikaNumToScientific(mantissa: number, exponent: number): string
	local e: string
	if exponent == 0 then
		e = "0"
	else
		e = numberToSuffix(exponent)
	end
	return tostring(math.floor(mantissa * DP_OFFSET) / DP_OFFSET) .. "e" .. (e == nil and tostring(math.floor(exponent * DP_OFFSET) / DP_OFFSET) or e)
end

--- Converts the AlyaNum into a string with a number and suffix.
--- Use the AlyaNum.changeSuffixes method to edit the suffixes.
--- If a suffix for the specified AlyaNum is not found, scientific notation is used.
--- @param self AlyaNum
--- @returns string
function toSuffix(self: AlyaNum): string
	if self.exponent > 1 then
		return toScientific(self)
	end
	local mantissa, exponent = toSerika(self)
	return serikaNumToSuffix(mantissa, exponent) or serikaNumToScientific(mantissa, exponent)
end

--- Converts the AlyaNum object into a string in scientific notation format.
--- @param self AlyaNum
--- @returns string
function toScientific(self: AlyaNum): string
	if self.sign == 0 then
		return "0"
	elseif self.exponent > 2 then
		return toEChain(self)
	end

	local mantissa, exponent = toSerika(self)
	return serikaNumToScientific(mantissa, exponent)
end

--- Converts the AlyaNum into a string in an E chain.
--- An E chain is exactly what it says. 1e(1e1M) is formatted as ee1M.
--- E chains place all Es at the start, and have a maximum chain of 10 Es.
--- @param self AlyaNum
--- @returns string
function toEChain(self: AlyaNum): string
	if self.tetrate > 0 or self.exponent > 10 then
		return toEnt(self)
	end
	return string.rep("e", self.exponent) .. tostring(math.floor(self.multiplicand * DP_OFFSET) / DP_OFFSET)
end

--- Converts the AlyaNum into a format E(y)x.
--- y is the number of times to perform 10^x. For example, E(3)2 = 10^(10^(10^2))
--- @see https://googology.fandom.com/wiki/Nihilustheabsolutists_E_function
--- @param self AlyaNum
--- @returns string
function toEnt(self: AlyaNum): string
	local multiplicand = self.multiplicand
	if self.tetrate > 0 then
		if self.tetrate > 1 or multiplicand > 308 or self.exponent > 1 then
			return toHyperE(self)
		end
		multiplicand = math.pow(10, multiplicand)
	end
	local part = "E(" .. numberToSuffix(self.exponent) .. ")"
	if self.sign == -1 then
		part = "-" .. part
	end
	return part .. numberToSuffix(self.multiplicand)
end

--- Converts the AlyaNum into Hyper-E notation, Ex#a#b#c#d#e.
--- a is the number of times to perform 10^x, b is the number of times to perform 10^^x, c is the number of times to perform 10^^^x and so on.
--- @see https://googology.fandom.com/wiki/Hyper-E_notation
--- @param self AlyaNum
--- @returns string
function toHyperE(self: AlyaNum): string
	if self.sign == -1 then
		return "-" .. toHyperE(abs(self))
	end
	if lessThan(self, MAX_SAFE) then
		return toSuffix(self)
	end
	local suffixed = numberToSuffix(self.multiplicand)
	local str = "E" .. (suffixed == nil and tostring(math.floor(self.multiplicand * DP_OFFSET) / DP_OFFSET) or suffixed)
	if (self.exponent > 0) then
		str ..= "#" .. numberToSuffix(self.exponent) 
	end
	if (self.tetrate > 0) then
		str ..= "#" ..  numberToSuffix(self.tetrate + 1)
	end
	if (self.pentate > 0) then
		str ..= "#" ..  numberToSuffix(self.pentate + 1)
	end
	if (self.hexate > 0) then
		str ..= "#" ..  numberToSuffix(self.hexate + 1)
	end
	if (self.heptate > 0) then
		str ..= "#" ..  numberToSuffix(self.heptate + 1)
	end
	return str
end

function toString(self: AlyaNum): string
	if self.sign == 0 then
		return "0"
	elseif self.sign == -1 then
		return "-" .. toString(abs(self))
	elseif lessThan(abs(self), MAX_FRACTIONAL) then
		return "1 / " .. toSuffix(div(ONE, self))

	elseif lessThan(self, MAX_SUFFIX) and DEFAULT_ABBREVIATION == "suffix" then
		return toSuffix(self)

	elseif lessThan(self, MAX_SCIENTIFIC) then
		return toScientific(self)

	elseif lessThan(self, MAX_E_CHAIN) then
		return toEChain(self) 

	elseif lessThan(self, MAX_ENT) then
		return toEnt(self)

	else
		return toHyperE(self)
	end
end

function getSuffixExponent(suffix: string): number?
	local exponent = 0
	for i, v in suffixes.third do
		local startIndex, endIndex = string.find(suffix, v)
		if startIndex ~= nil then
			exponent += i * 300
			suffix = string.sub(suffix, 1, startIndex - 1)
			break
		end
	end
	local secondPresent = false
	for i, v in suffixes.second do
		local startIndex, endIndex = string.find(suffix, v)
		if startIndex ~= nil then
			exponent += i * 30
			suffix = string.sub(suffix, 1, startIndex - 1)
			secondPresent = true
			break
		end
	end
	for i, v in suffixes.first do
		local startIndex, endIndex = string.find(suffix, v)
		if startIndex ~= nil then
			exponent += i * 3
			suffix = string.sub(suffix, 1, startIndex - 1)
			break
		end
	end
	for i, v in suffixes.beginning do
		local startIndex, endIndex = string.find(suffix, v)
		if startIndex ~= nil then
			exponent += i * 3 - 3
			suffix = string.sub(suffix, 1, startIndex - 1)
			break
		end
	end

	return exponent + 3
end

function fromSuffix(str: string): AlyaNum?
	local suffix = str:match("%a+")
	if suffix == nil then
		return nil
	end
	local mantissa = tonumber(string.sub(str, 1, string.find(str, suffix) - 1))

	local exponent = getSuffixExponent(suffix)
	if mantissa ~= nil and exponent > 0 then
		return AlyaNum.fromOnoe({mantissa = mantissa, exponent = exponent})
	else
		return nil
	end
end

function AlyaNum.fromString(str): AlyaNum
	if str == "[0]" then
		return ZERO
	end
	if (string.find(str, 'e') or string.find(str, 'E')) and not string.find(str,"%[") then
		local subs = string.split(str, 'e')
		-- Fix problem with tetrate
		if subs[1] == "" then
			table.insert(subs, 1, "1")
			if subs[2] == "" then
				table.remove(subs, 2)
			end
		end
		if #subs == 2 then
			-- its scientific yk
			local sign = 1

			local mantissa = tonumber(subs[1])
			local exponent = tonumber(subs[2]) or 0
			if mantissa == 0 then
				return ZERO
			end
			if mantissa ~= nil then
				if mantissa < 0 then
					mantissa = math.abs(mantissa)
					sign = -sign
				end
				if exponent < 0 then -- we are making a small number
			mantissa = mantissa * math.pow(10, exponent)
			return fix({ sign = sign, multiplicand = mantissa, exponent = 0, tetrate = 0, pentate = 0, hexate = 0, heptate = 0 })
				end
				local first = exponent + math.log10(mantissa)
				local second = 1
				if first == 0 then
					first = 1
					second = 0
				elseif first < 0 then
				first = -first
					sign = -sign
				end
				return fix({ sign = sign, multiplicand = first, exponent = second, tetrate = 0, pentate = 0, hexate = 0, heptate = 0 })
			end
		else
			-- its a e chain!
			local second = #subs-1
			local first = subs[#subs]
			local sign = 1
			if subs[1] == '-' then
				sign = -1
			end
			return fix({ sign = sign, multiplicand = tonumber(first), exponent = second, tetrate = 0, pentate = 0, hexate = 0, heptate = 0 })
		end
	end
	if string.find(str, ',') or string.find(str,"%[") then
		str = game.HttpService:JSONDecode(str)
		str = {math.sign(str[1] or 1), str}
		str[2][1] = math.abs(str[2][1] or 0)
		return fix(AlyaNum.fromOmega(str))
	else
		local fromSuff = fromSuffix(str)
		if (fromSuff ~= nil) then
			return fromSuff
		end
		return AlyaNum.new(tonumber(str))
	end
end

function AlyaNum.toBaseAlya(self: AlyaNum): BaseAlyaNum
	return setmetatable(self, nil) :: BaseAlyaNum
end

-- completely stolen from omeganum
function AlyaNum.lbencode(self: AlyaNum): number
	if self.sign == 0 then
		return 0
		-- For maximum performance, you do not need to encode 0.
	end

	local sign = self.sign
	if self.heptate > 0 then
		-- good until 916 arrays
		local cnum = 1.2e17
		cnum += math.log10((self.heptate + (math.log10(self.hexate + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif self.hexate > 0 then
		-- mode 11: I Do Not Konw
		local cnum = 1.1e17
		cnum += math.log10((self.hexate + (math.log10(self.pentate + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif self.pentate > 0 then
		-- mode 10: Big Number Territory
		local cnum = 1e17
		cnum += math.log10((self.pentate + (math.log10(self.tetrate + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif self.tetrate > 0 then
		if self.tetrate < 9999 then
			-- mode 8: Pentation Empire
			local cnum = 8e16
			cnum += math.log10((self.exponent + (math.log10(self.multiplicand) / 16) + 1)) * 6.26775e8
			cnum += self.tetrate * 1e10
			return sign * cnum
		elseif self.tetrate == 2 then
			-- mode 7: Post-EternityNum
			local cnum = 7e16
			cnum += math.log10((self.exponent + (math.log10(self.multiplicand) / 16) + 1)) * 6.26775e14
			return sign * cnum
		elseif self.tetrate == 1 then
			-- mode 6: Beyond EternityNum
			local cnum = 6e16
			cnum += math.log10((self.exponent + (math.log10(self.multiplicand) / 16) + 1)) * 6.26775e14
			return sign * cnum
		end
		-- mode 9: Ultra Pentation
		local cnum = 9e16
		cnum += math.log10((self.tetrate + (math.log10(self.exponent + 1) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif self.exponent > 0 then
		if self.exponent <= 9999 then
			-- mode 4: Native Big EternityNum Numbers
			local cnum = 4e16
			cnum += math.log10((self.multiplicand + 1)) * 6.26775e8
			cnum += self.exponent * 1e10
			return sign * cnum
		elseif self.exponent < 4 then
			-- mode 1: Native BigNum
			-- mode 2: Native Post-BigNum
			-- mode 3: Native EternityNum
			return sign * (math.floor(math.log10((self.multiplicand + 1)) * 6.26775e14) + self.exponent * 1e16)
		end
		-- mode 5: Native Extreme EternityNum Numbers
		local cnum = 5e16
		cnum += math.log10((self.exponent + (math.log10(self.multiplicand) / 16) + 1)) * 6.26775e14
		return sign * cnum
	elseif self.multiplicand > 0 then
		-- mode 0: Native Float
		return sign * math.floor(math.log10((self.multiplicand + 1)) * 6.26775e14)
	end
end

function AlyaNum.lbdecode(int: number): AlyaNum
	if int == 0 then
		return ZERO
	end
	local sign = math.sign(int)
	int = math.abs(int)

	local mode = math.floor(int / 1e16)
	if mode >= 3 then
		int -= 1
	end
	if mode == 0 then
		return fix({sign = sign, multiplicand = 10^(int / 6.26775e14) - 1, exponent = 0, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	elseif mode < 4 then
		return fix({sign = sign, multiplicand = 10^(math.fmod(int, 1e16) / 6.26775e14) - 1, exponent = mode, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 4 then
		local remainder = math.fmod(int, 1e10)
		return fix({sign = sign, multiplicand = 10^(remainder / 6.26775e8) - 1, exponent =  math.floor((int - 4e16) / 1e10), tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 5 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = arg1, exponent = math.floor(arrows), tetrate = 0, pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 6 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = arg1, exponent = math.floor(arrows), tetrate = 1, pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 7 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = arg1, exponent = math.floor(arrows), tetrate = 2, pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 8 then
		local arg3 = math.floor((int-8e16) / 1e10)
		local remainder = math.fmod(int, 1e10) * 1e6
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = arg1, exponent = math.floor(arrows), tetrate = math.floor(arg3), pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 9 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = 1, exponent = math.floor(arg1), tetrate = math.floor(arrows), pentate = 0, hexate = 0, heptate = 0})
	elseif mode == 10 then
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = 10^(math.fmod(arrows, 1)*16)
		return fix({sign = sign, multiplicand = 1, exponent = 0, tetrate = math.floor(arg1), pentate = math.floor(arrows), hexate = 0, heptate = 0})
	else
		local zeros = mode - 10
		local remainder = math.fmod(int, 1e16)
		local arrows = 10^(remainder / 6.26775e14) - 1
		local arg1 = FLOAT64_SAFE_LIMIT ^ (math.fmod(arrows, 1))
		local xd = {1, 0}
		for i=1,zeros do
			table.insert(xd, 0)
		end
		table.insert(xd, math.floor(arg1))
		table.insert(xd, math.floor(arrows))
		if xd[zeros + 4] == 0 then
			table.remove(xd)
		end
		return AlyaNum.fromOmega({sign, xd}) -- lol
	end
end

function AlyaNum.fromScientific(str: string): AlyaNum
	local split = string.split(str, "e")
    local mantissa = AlyaNum.new(tonumber(split[1]))
    if #split == 1 then
        return mantissa
    end
	return mul(mantissa, mutablePow10(AlyaNum.new(tonumber(split[2]))))
end

function AlyaNum.changeSuffixes(newSuffixes: typeof(suffixes))
	suffixes = newSuffixes
end

function AlyaNum.changeDecimalPoints(decimalPoints: number)
	DECIMAL_POINTS = decimalPoints
end

function AlyaNum.changeDefaultAbbreviation(mode: "suffix" | "scientific")
	DEFAULT_ABBREVIATION = mode
end

-- exports

--- Fix the AlyaNum object to ensure it is a valid AlyaNum.
--- You shouldn't need to use this function.
AlyaNum.fix = fix

--- Adds the specified number to this AlyaNum and returns the result as a new AlyaNum.
--- @param number The number to add (can be AlyaNum, BaseAlyaNum, or primitive number).
AlyaNum.add = function(self: AlyaNum, number: Number)
	return add(self, AlyaNum.new(number))
end

--- Subtracts the specified number from this AlyaNum and returns the result as a new AlyaNum.
--- @param number The number to subtract.
AlyaNum.sub = function(self: AlyaNum, number: Number)
	return add(self, unary(AlyaNum.new(number)))
end

--- Multiplies this AlyaNum by the specified number and returns the result as a new AlyaNum.
--- @param number The number to multiply by.
AlyaNum.mul = function(self: AlyaNum, number: Number)
	return mul(self, AlyaNum.new(number))
end

--- Divides this AlyaNum by the specified number and returns the result as a new AlyaNum.
--- @param number The number to divide by.
AlyaNum.div = function(self: AlyaNum, number: Number)
	return div(self, AlyaNum.new(number))
end

--- Raises this AlyaNum to the power of the specified number and returns the result as a new AlyaNum.
--- @param number The exponent value.
AlyaNum.pow = function(self: AlyaNum, number: Number)
	return pow(self, AlyaNum.new(number))
end

--- Returns the remainder after dividing this AlyaNum by the specified number.
--- @param number The divisor.
AlyaNum.mod = function(self: AlyaNum, number: Number)
	return mod(self, AlyaNum.new(number))
end

--- Calculates the nth root of this AlyaNum, where n is the specified number.
--- @param number The degree of the root.
AlyaNum.root = function(self: AlyaNum, number: Number)
	return root(self, AlyaNum.new(number))
end

--- Checks if this AlyaNum is exactly equal to the specified number.
--- @param number The number to compare against.
AlyaNum.equals = function(self: AlyaNum, number: Number)
	return equals(self, AlyaNum.new(number))
end

--- Checks if this AlyaNum is less than the specified number.
--- @param number The number to compare against.
AlyaNum.lessThan = function(self: AlyaNum, number: Number)
	return lessThan(self, AlyaNum.new(number))
end

--- Checks if this AlyaNum is less than or equal to the specified number.
--- @param number The number to compare against.
AlyaNum.lessEquals = function(self: AlyaNum, number: Number)
	return lessEquals(self, AlyaNum.new(number))
end

--- Checks if this AlyaNum is greater than the specified number.
--- @param number The number to compare against.
AlyaNum.moreThan = function(self: AlyaNum, number: Number)
	return moreThan(self, AlyaNum.new(number))
end

--- Checks if this AlyaNum is greater than or equal to the specified number.
--- @param number The number to compare against.
AlyaNum.moreEquals = function(self: AlyaNum, number: Number)
	return moreEquals(self, AlyaNum.new(number))
end

--- Compares two numbers.
--- @param number The number to compare against.
AlyaNum.compare = function(self: AlyaNum, number: Number)
	return compare(self, AlyaNum.new(number))
end

--- Get the absolute value of the AlyaNum.
AlyaNum.abs = function(self: AlyaNum)
	return abs(AlyaNum.new(self))
end

--- Get the logarithm of the AlyaNum object with a base of 10.
AlyaNum.log10 = function(self: AlyaNum)
	return log10(AlyaNum.new(self))
end

--- Get the logarithm of the AlyaNum object with the specified number base.
--- @param number Base of the logarithm
AlyaNum.log = function(self: AlyaNum, number: Number)
	return log(self, AlyaNum.new(number))
end

--- Rounds down the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
AlyaNum.floor = function(self: AlyaNum)
	return floor(AlyaNum.new(self))
end

--- Rounds the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
AlyaNum.round = function(self: AlyaNum)
	return round(AlyaNum.new(self))
end

--- Rounds up the AlyaNum to the nearest integer.
--- This operation is unsafe for numbers beyond 2^1024.
AlyaNum.ceil = function(self: AlyaNum)
	return ceil(AlyaNum.new(self))
end

--- Returns if the AlyaNum is an integer.
--- This operation is unsafe for numbers beyond 2^1024.
AlyaNum.isInteger = function(self: AlyaNum)
	return isInteger(AlyaNum.new(self))
end

--- Returns 1/AlyaNum.
AlyaNum.reciprocal = function(self: AlyaNum)
	return reciprocal(AlyaNum.new(self))
end

--- Returns the value of the AlyaNum after going through the Lambert W function.
--- This is a fairly expensive operation.
AlyaNum.lambertw = function(self: AlyaNum)
	return lambertw(AlyaNum.new(self))
end

--- Returns the super-logarithm of the AlyaNum with the specified base.
--- @param number Base of the logarithm
AlyaNum.slog = function(self: AlyaNum, number: Number)
	return slog(self, AlyaNum.new(number))
end

--- Returns x^^^y, where ^^^ = pentation, and pentation is repeated tetration.
--- @param number Height of the tetration tower.
AlyaNum.pentlog = function(self: AlyaNum, number: Number)
	return pentlog(self, AlyaNum.new(number))
end

--- Returns x^^^^y, where ^^^^ = hexation, and hexation is repeated pentation.
--- @param number Height of the pentation tower.
AlyaNum.hextlog = function(self: AlyaNum, number: Number)
	return hextlog(self, AlyaNum.new(number))
end

--- Returns x^^y, where ^^ = tetration, and tetration is repeated exponentiation.
--- @param number Height of the power tower.
AlyaNum.tet = function(self: AlyaNum, number: Number)
	return tetrate(self, AlyaNum.new(number))
end

--- Returns x^^^y, where ^^^ = pentation, and pentation is repeated tetration.
--- @param number Height of the tetration tower.
AlyaNum.pent = function(self: AlyaNum, number: Number)
	return pentate(self, AlyaNum.new(number))
end

--- Returns x^^^^y, where ^^^^ = hexation, and hexation is repeated pentation.
--- @param number Height of the pentation tower.
AlyaNum.hext = function(self: AlyaNum, number: Number)
	return hexate(self, AlyaNum.new(number))
end

--- Flips the sign of the AlyaNum object. Equivalent to multiplying by -1.
AlyaNum.unary = function(self: AlyaNum)
	return unary(AlyaNum.new(self))
end

--- Returns the minimum value of two AlyaNum objects.
--- @param number The number to compare against.
AlyaNum.min = function(self: AlyaNum, number: Number)
	return min(self, AlyaNum.new(number))
end

--- Returns the maximum value of two AlyaNum objects.
--- @param number The number to compare against.
AlyaNum.max = function(self: AlyaNum, number: Number)
	return max(self, AlyaNum.new(number))
end

--- Returns the minimum and maximum value of two AlyaNum objects.
--- @param number The number to compare against.
AlyaNum.minmax = function(self: AlyaNum, number: Number)
	return minmax(self, AlyaNum.new(number))
end

--- Converts the AlyaNum object into a displayable string.
AlyaNum.toString = function(self: Number)
	return toString(AlyaNum.new(self))
end

--- Converts the AlyaNum into a string with a number and suffix.
AlyaNum.toSerika = function(self: Number)
	return toSerika(AlyaNum.new(self))
end

--- Reverts the AlyaNum back to a primitive number.
--- For numbers beyond 2^1024, this will return math.huge.
AlyaNum.toNumber = function(self: Number)
	return toNumber(AlyaNum.new(self))
end

--- Converts the AlyaNum into a string with a number and suffix.
AlyaNum.toSuffix = function(self: Number)
	return toSuffix(AlyaNum.new(self))
end

--- Converts the AlyaNum object into a string in scientific notation format.
AlyaNum.toScientific = function(self: Number)
	return toScientific(AlyaNum.new(self))
end

--- Converts the AlyaNum into a string in an E chain.
AlyaNum.toEChain = function(self: Number)
	return toEChain(AlyaNum.new(self))
end

--- Converts the AlyaNum into a `format E(y)x`.
AlyaNum.toEnt = function(self: Number)
	return toEnt(AlyaNum.new(self))
end

--- Converts the AlyaNum into Hyper-E notation, `Ex#a#b#c#d#e`.
AlyaNum.toHyperE = function(self: Number)
	return toHyperE(AlyaNum.new(self))
end

--- Alias for AlyaNum.equals. Checks if two AlyaNum objects are equal.
AlyaNum.eq = AlyaNum.equals

--- Alias for AlyaNum.lessThan. Checks if this AlyaNum is less than another.
AlyaNum.lt = AlyaNum.lessThan

--- Alias for AlyaNum.lessEquals. Checks if this AlyaNum is less than or equal to another.
AlyaNum.le = AlyaNum.lessEquals

--- Alias for AlyaNum.moreThan. Checks if this AlyaNum is greater than another.
AlyaNum.mt = AlyaNum.moreThan

--- Alias for AlyaNum.moreEquals. Checks if this AlyaNum is greater than or equal to another.
AlyaNum.me = AlyaNum.moreEquals

--- Alias for AlyaNum.unary. Flips the sign of the AlyaNum object.
AlyaNum.unm = AlyaNum.unary

--- Alias for AlyaNum.reciprocal. Returns 1/AlyaNum.
AlyaNum.recip = AlyaNum.reciprocal

--- Alias for AlyaNum.toNumber. Reverts the AlyaNum back to a primitive number.
AlyaNum.revert = toNumber

--- Alias for AlyaNum.lbencode. Converts AlyaNum to a single primitive number for leaderboards.
AlyaNum.toSingle = AlyaNum.lbencode

--- Alias for AlyaNum.lbdecode. Converts a single primitive number back into AlyaNum.
AlyaNum.fromSingle = AlyaNum.lbdecode

--- Metamethod for addition.
AlyaNum.__add = AlyaNum.add

--- Metamethod for subtraction.
AlyaNum.__sub = AlyaNum.sub

--- Metamethod for multiplication.
AlyaNum.__mul = AlyaNum.mul

--- Metamethod for division.
AlyaNum.__div = AlyaNum.div

--- Metamethod for exponentiation.
AlyaNum.__pow = AlyaNum.pow

--- Metamethod for modulo.
AlyaNum.__mod = AlyaNum.mod

--- Metamethod for equality.
AlyaNum.__eq = AlyaNum.eq

--- Metamethod for less than.
AlyaNum.__lt = AlyaNum.lt

--- Metamethod for less than or equal.
AlyaNum.__le = AlyaNum.le

--- Metamethod for unary minus.
AlyaNum.__unm = AlyaNum.unm

--- Metamethod for converting AlyaNum to string.
AlyaNum.__tostring = AlyaNum.toString

--- Metamethod for concatenating AlyaNum with another value.
AlyaNum.__concat = function(self: AlyaNum, value: any): AlyaNum
	return AlyaNum.toString(self) .. value
end

-- fun little things

--- A googol, 10^100.
AlyaNum.GOOGOL = AlyaNum.new(10e100)

--- A googolplex, 10^(10^100).
AlyaNum.GOOGOLPLEX = AlyaNum.new(10):pow(AlyaNum.GOOGOL)

--- A googolplexplex, 10^(10^(10^100)).
AlyaNum.GOOGOLPLEXPLEX = AlyaNum.new(10):pow(AlyaNum.GOOGOLPLEX)

--- Tritri, 3^^^3.
AlyaNum.TRITRI = AlyaNum.new({sign = 1, multiplicand = 3638334640023.778, exponent = 7625597484984, tetrate = 0, pentate = 0, hexate = 0, heptate = 0})

--- Tritet, 4^^^^4.
AlyaNum.TRITET = AlyaNum.new({sign = 1, multiplicand = 153.906997547968, exponent = 2, tetrate = 2, pentate = 2, hexate = 0, heptate = 0})

--- The first term of Graham's number, 3^^^^3.
AlyaNum.GRAHAM1 = AlyaNum.new({sign = 1, multiplicand = 3638334640023.778, exponent = 7625597484984, tetrate = 0, pentate = 1, hexate = 0, heptate = 0})

export type AlyaNum = typeof(setmetatable({} :: BaseAlyaNum, AlyaNum))

return AlyaNum
