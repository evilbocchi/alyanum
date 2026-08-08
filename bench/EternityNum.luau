--!native
--!optimize 2
--!nocheck

-- Made by FoundForces - CommanderSalty#2800

--// Config
local expl = 1e10 -- exponent limit
local ldown = math.log10(expl) -- val for layer down
local msd = 100 -- max sig digits
local AllowOverflow = true -- if this is true functions like to scientific will go to some other short function if input too large
local SuffixLimit = "9e1E14" -- Value when short() doesnt return suffix anymore
local DefaultDigits = 2 -- Amount of digits on short functions (-1 is all digits)
--

--[[
EN: A valid EternityNum Table
val: Any valid input that can be converted to an EternityNum Table

FUNCTIONS:
--// CHECK
	EN.IsNan(EN): boolean -> returns if the given value is NAN or not
	EN.IsInf(EN): boolean -> returns if the given value is INF or not
	EN.IsZero(EN): boolean -> returns if the given value is 0 or not

--// CONVERT
	EN.new(Sign, Layer, Exp): EN -> Directy create a new EternityNum Table :->: Sign * (10^^Layer)^Exp
	EN.fromNumber(number): EN -> Converts a number into an EternityNum Table
	EN.fromString(string): EN -> Converts a string into an EternityNum T able
	EN.fromScientific(string): EN -> Converts "XeY" into an EternityNum Table
	EN.fromDefaultStringFormat(string): EN -> Converts "X;Y" into an EternityNum Table
	EN.convert(val): EN -> Converts any valid input to an EternityNum Table
	
	EN.toNumber(EN): number -> Converts a EternityNum Table to an number
	EN.toString(EN): string -> Converts a EternityNum Table to an string ("X;Y")
	EN.toScientific(val): string -> Converts a value to an string ("XeY")
	EN.toLayerNotation(val, digits): string -> Converts a value to an string ("E(x)y")
	EN.toSuffix(val): string -> Converts a value to an suffix
	EN.short(val, digits): string -> Converts a value to an displayable string

--// BOOLEAN
	EN.eq(val1, val2): bool -> returns if val1 equals val2 (==)
	EN.le(val1, val2): bool -> returns if val1 is less then val2 (<)
	EN.me(val1, val2): bool -> returns if val1 is more then val2 (>)
	EN.leeq(val1, val2): bool -> returns if val1 is less or equal then val2 (<=)
	EN.meeq(val1, val2): bool -> returns if val1 is more or equal then val2 (>=)
	EN.bewteen(val, min, max): bool -> returns if val is between min and max

--// S CALCS
	EN.abs(val): EN -> returns the absolute value of val
	EN.neg(val): EN -> returns the negated value of val (-val)
	EN.recip(val): EN -> returns the reciprocal of val (1/val)
	EN.log10(val): EN -> returns the logarithm base 10 of val
	EN.abslog10(val): EN -> returns the logarithm base 10 of the absolute value of val :->: log10(abs(val))
	EN.exp(val): EN -> returns e^val 
    EN.pow10(val): EN -> returns 10^val
    EN.sqrt(val): EN -> returns the square root of val
    EN.gamma(val): EN -> returns (val - 1)!
    EN.fact(val): EN -> returns val!
    EN.correct(EN): EN -> error corrects an eternitynum (INTERNAL ONLY)
    
    --// USE FOR LEADERBOARDS
    EN.lbencode(val): number -> returns a number that can be stored in ordereddatastore
    EN.lbdecode(number): EN -> converts a lbecoded number back to an EternityNum Table
  
--// BIN CALCS
	EN.add(val1, val2): EN -> returns val1 + val2
	EN.sub(val1, val2): EN -> returns val1 - val2
	EN.mul(val1, val2): EN -> returns val1 * val2
	EN.div(val1, val2): EN -> returns val1 / val2
	EN.pow(val1, val2): EN -> returns val1 ^ val2
	EN.log(val, base): EN -> returns logarithm of val, if base is nil it will return log(val) (natural logarithm)
	EN.root(val1, val2): EN -> returns val2'th root of val1
	EN.rand(min, max): EN -> returns a random number between min and max
	EN.exporand(min, max): EN -> returns a random number between min and max
	EN.cmp(val1, val2): number -> 
		returns 0 if val1 == val2
		returns 1 if val1 > val2
		returns -1 if val1 < val2
	EN.cmpAbs(EN1, EN2): number -> returns cmp(abs(EN1),abs(EN2))
	EN.maxAbs(val1, val2): EN -> returns the max(abs(val1), abs(val2))
	
-- TO ADD:
	EN.min(val1, val2)
	EN.max(val1m val2)
]]

-----------
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

function F_Gamma(n): number -- (x-1)!
	if n > 171.6236 then
		return 1.8e308
	end --// Point where Gamma(x) will return INF

	if n > 0.5 then
		n -= 1
		local x = C[1]

		for i = 1, 7 do
			x += C[i + 1] / (n + i)
		end

		local t = n + 7.5
		return x * t ^ (n + 0.5 - 36) * math.exp(-t) * t ^ 36 * 2.50662827463100050241576528
	end

	return 3.141592653589793238 / (math.sin(3.141592653589793238 * n) * F_Gamma(1 - n))
end
-----------

--// Constants
local tau = 6.2831853071795864769252842 --2*pi
local EXPN1 = 0.36787944117144232159553 --exp(-1)
local OMEGA = 0.56714329040978387299997 --W(1, 0)

function f_Lambertw(z) -- Lambertw function
	local tol = 1e-10
	local w, wn = nil

	if z > 1.79e308 then
		return z
	end
	if z == 0 then
		return z
	end
	if z == 1 then
		return OMEGA
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

	error("Failed to itterate z.... at function: f_lambertw")
end

--// Start of EternityNum
----------------------------------------------------------------------------------------------------------------
type EN = { Sign: number, Layer: number, Exp: number }
type BN = { Mantissa: number, Exp: number }
local EN = {}
-----------

function Cnew(Sign: number, Layer: number, Exp: number): EN
	return { Sign = Sign, Layer = Layer, Exp = Exp }
end

local ZERO: EN = Cnew(0, 0, 0)
local ONE: EN = Cnew(1, 0, 1)
local NaN: EN = Cnew(1, -1, 1)
local Inf: EN = Cnew(1, math.huge, 1)

local DefaultReturn = ZERO

function EN.IsNaN(Value: EN): boolean
	return Value.Sign == NaN.Sign and Value.Layer == NaN.Layer and Value.Exp == NaN.Exp
end

function EN.IsInf(Value: EN): boolean
	return Value.Layer == math.huge or Value.Exp == math.huge
end

function EN.IsZero(Value: EN): boolean
	return Value.Sign == 0 or (Value.Exp == 0 and Value.Layer == 0)
end

function EN.correct(EtNum: EN): EN --// Corrects a EtNum
	if EN.IsNaN(EtNum) then
		return NaN
	end
	if EN.IsInf(EtNum) then
		return Inf
	end
	if EN.IsZero(EtNum) then
		return ZERO
	end
	local Sign = EtNum.Sign
	local Layers = EtNum.Layer
	local Exp = EtNum.Exp

	if Layers == 0 and Exp < 0 then
		Exp = -Exp
		Sign = -Sign
	end

	if Layers == 0 and Exp < 1e-10 then
		Layers += 1
		Exp = math.log10(Exp)
		return Cnew(Sign, Layers, Exp)
	end

	local absExp = math.abs(Exp)
	local signExp = math.sign(Exp)

	if absExp >= expl then
		Layers += 1
		Exp = signExp * math.log10(absExp)
		return Cnew(Sign, Layers, Exp)
	else
		while absExp < ldown and Layers > 0 do
			Layers -= 1
			if Layers == 0 then
				Exp = math.pow(10, Exp)
			else
				Exp = signExp * math.pow(10, absExp)
				absExp = math.abs(Exp)
				signExp = math.sign(Exp)
			end
		end

		if Layers == 0 then
			if Exp < 0 then
				Exp = -Exp
				Sign = -Sign
			end
		elseif Exp == 0 then
			Sign = 0
		end
	end

	return Cnew(Sign, Layers, Exp)
end

function EN.new(Sign: number, Layer: number, Exp: number): EN
	return EN.correct({ Sign = Sign, Layer = Layer, Exp = Exp })
end

function EN.fromNumber(Value: number): EN --// Convert a number to EtNum
	local num = {}
	num.Sign = math.sign(Value)
	num.Layer = 0
	num.Exp = math.abs(Value)
	return EN.correct(num)
end

function EN.fromScientific(Value: string): EN --// Convert from "XeY" to EtNum
	local slice = Value:split("e")

	local Mantissa = tonumber(slice[1])
	local Exp = tonumber(slice[2])
	local Sign = math.sign(Mantissa)

	--// Normalise Mantissa \\--
	local Overflow = math.floor(math.log10(Mantissa))
	if Overflow > 0 then
		Mantissa /= 10 ^ Overflow
		Exp += Overflow
	end
	-----------------------------

	if Exp == 0 then
		return EN.new(math.sign(Mantissa), 0, Mantissa)
	end --// x*10^0 (so just return x)
	if Mantissa == 0 then
		return ZERO
	end --// return 0

	if Mantissa < 0 then
		Mantissa = -Mantissa
	end

	if Exp < 0 then
		if Exp < -100 then
			return ZERO
		end
		local Exp2 = math.log10(Mantissa) + Exp
		return EN.correct(EN.new(Sign, 1, Exp2))
	end

	local Exp2 = math.log10(Mantissa) + Exp
	local Layers = 1

	if Exp2 > expl then
		Exp2 = math.log10(Exp2)
		Layers += 1
	end

	return EN.correct(EN.new(Sign, Layers, Exp2))
end

function EN.fromDefaultStringFormat(Value: string): EN --// Convert "X;Y" to EtNum
	local slice = Value:split(";")
	local Sign = math.sign(tonumber(slice[1]))
	if Sign == 0 then
		Sign = 1
	end
	local Layers = math.abs(tonumber(slice[1]))
	local Exp = tonumber(slice[2])
	return EN.correct(EN.new(Sign, Layers, Exp))
end

function EN.fromString(Value: string)
	if Value:find("e") and not Value:find(";") then -- Assuming its scientific notation
		return EN.fromScientific(Value)
	elseif Value:find(";") then -- String representation
		return EN.fromDefaultStringFormat(Value)
	end

	if Value == "NaN" then
		return NaN
	end
	if Value == "Inf" then
		return Inf
	end
	if Value == "" then
		return DefaultReturn
	end

	return EN.fromNumber(tonumber(Value))
end

function EN.toString(Value: EN): string
	if EN.IsNaN(Value) then
		return "NaN"
	end
	if EN.IsInf(Value) then
		return "Inf"
	end
	return Value.Layer .. ";" .. Value.Exp
end

function EN.convert(Input): EN --// Convert any valid type to EternityNum
	if typeof(Input) == "number" then
		return EN.fromNumber(Input)
	elseif typeof(Input) == "string" then
		return EN.fromString(Input)
	elseif typeof(Input) == "table" then
		if #Input == 2 then -- Its a BigNum (Adding this because if people are updating for "BigNum")
			local String = Input[1] .. "e" .. Input[2]
			return EN.fromScientific(String)
		elseif #Input == 3 then
			return EN.correct(EN.new(Input[1], Input[2], Input[3]))
		elseif Input.Sign then
			return EN.correct(EN.new(Input.Sign, Input.Layer, Input.Exp))
		end
	end
	warn("Returning DefaultReturn at EN.Convert(): Invalid input!")
	return DefaultReturn
end

function EN.toNumber(Value: EN): number --// Convert a EtNum to an number
	if Value.Layer > 1 then
		if math.sign(Value.Exp) == -1 then
			return Value.Sign * 0
		end
		return Value.Sign * 1.8e308
	end

	if Value.Layer == 0 then
		return Value.Sign * Value.Exp
	elseif Value.Layer == 1 then
		return Value.Sign * 10 ^ Value.Exp
	end

	return math.log10(-1)
end

function EN.abs(Value): EN
	Value = EN.convert(Value)

	if Value.Sign == 0 then
		return ZERO
	end
	return EN.new(1, Value.Layer, Value.Exp)
end

function EN.maxAbs(Value, Value2)
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	if EN.cmpAbs(Value, Value2) < 0 then
		return Value2
	end
	return Value
end

function EN.neg(Value): EN --// Negate a EtNum
	Value = EN.convert(Value)
	return EN.new(-Value.Sign, Value.Layer, Value.Exp)
end

function EN.cmpAbs(Value: EN, Value2: EN): number
	local layera = nil
	if Value.Exp > 0 then
		layera = Value.Layer
	else
		layera = -Value.Layer
	end

	local layerb = nil
	if Value2.Exp > 0 then
		layerb = Value2.Layer
	else
		layerb = -Value2.Layer
	end

	if layera > layerb then
		return 1
	end
	if layera < layerb then
		return -1
	end
	if Value.Exp > Value2.Exp then
		return 1
	end
	if Value.Exp < Value2.Exp then
		return -1
	end

	return 0
end

function EN.cmp(Value: EN, Value2: EN): number
	if Value.Sign > Value2.Sign then
		return 1
	end
	if Value.Sign < Value2.Sign then
		return -1
	end
	return Value.Sign * EN.cmpAbs(Value, Value2)
end

function EN.le(Value, Value2): boolean --// <
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.cmp(Value, Value2) == -1
end

function EN.me(Value, Value2): boolean --// >
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.cmp(Value, Value2) == 1
end

function EN.eq(Value, Value2): boolean --// ==
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.cmp(Value, Value2) == 0
end

function EN.leeq(Value, Value2): boolean --// ==
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return not (EN.cmp(Value, Value2) == 1)
end

function EN.meeq(Value, Value2): boolean --// ==
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return not (EN.cmp(Value, Value2) == -1)
end

function EN.recip(Value): EN
	Value = EN.convert(Value)
	if Value.Exp == 0 then
		return NaN
	end

	if Value.Layer == 0 then
		return EN.new(Value.Sign, 0, 1 / Value.Exp)
	end

	return EN.new(Value.Sign, Value.Layer, -Value.Exp)
end

function baseLog(Value, Base): EN
	Value = EN.convert(Value)
	Base = EN.convert(Base)

	if Value.Sign <= 0 or Base.Sign <= 0 then
		return NaN
	end

	if EN.IsNaN(Base) or EN.IsNaN(Value) then
		return NaN
	end

	if Value.Layer == 0 and Base.Layer == 0 then
		return EN.new(Value.Sign, 0, math.log(Value.Exp) / math.log(Base.Exp))
	end

	return EN.div(EN.log10(Value), EN.log10(Base))
end

function EN.log(Value, Base): EN --// Log of x
	if Base then
		return baseLog(Value, Base)
	end

	Value = EN.convert(Value)

	if Value.Sign <= 0 then
		return NaN
	end

	if Value.Layer == 0 then
		return EN.new(Value.Sign, 0, math.log10(Value.Exp))
	elseif Value.Layer == 1 then
		--// so we have this for x*10^y, since log(x) = log10(x) * log(10) we can do exactly that!
		return EN.new(math.sign(Value.Exp), 0, math.abs(Value.Exp) * 2.302585092994046)
	elseif Value.Layer == 2 then
		--// 10^(x*10^y), turns out you can just take the log10 and then add log10(log(10)) to the exponent
		return EN.new(math.sign(Value.Exp), 1, math.abs(Value.Exp) + 0.36221568869946325)
	end
	--// log(x) ~ log10(x) at this point so we just return the log10

	return EN.new(math.sign(Value.Exp), Value.Layer - 1, math.abs(Value.Exp))
end

function EN.log10(Value): EN --// log10(x)
	Value = EN.convert(Value)

	if Value.Sign <= 0 then
		return NaN
	end

	if Value.Layer > 0 then
		return EN.new(math.sign(Value.Exp), Value.Layer - 1, math.abs(Value.Exp))
	end

	return EN.new(Value.Sign, 0, math.log10(Value.Exp))
end

function EN.exp(Value): EN --// e^x
	Value = EN.convert(Value)

	if Value.Layer == 0 and Value.Exp <= 709.7 then
		return EN.fromNumber(math.exp(Value.Sign * Value.Exp))
	elseif Value.Layer == 0 then
		return EN.new(1, 1, Value.Sign * math.log10(2.718281828459045) * Value.Exp)
	elseif Value.Layer == 1 then
		return EN.new(1, 2, Value.Sign * (math.log10(0.4342944819032518) + Value.Exp))
	else
		return EN.new(1, Value.Layer + 1, Value.Sign * Value.Exp)
	end
end

function EN.add(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	if EN.IsInf(Value) or EN.IsInf(Value2) then
		return Inf
	end
	if EN.IsZero(Value) then
		return Value2
	end
	if EN.IsZero(Value2) then
		return Value
	end

	if Value.Sign == -Value2.Sign and Value.Layer == Value2.Layer and Value.Exp == Value2.Exp then
		return ZERO
	end

	local a, b

	if Value.Layer >= 2 or Value2.Layer >= 2 then
		return EN.maxAbs(Value, Value2)
	end

	if EN.cmpAbs(Value, Value2) > 0 then
		a = Value
		b = Value2
	else
		a = Value2
		b = Value
	end

	if a.Layer == 0 and b.Layer == 0 then
		return EN.fromNumber(a.Sign * a.Exp + b.Sign * b.Exp)
	end

	local layera = a.Layer * math.sign(a.Exp)
	local layerb = b.Layer * math.sign(b.Exp)

	if layera - layerb >= 2 then
		return a
	end

	if layera == 0 and layerb == -1 then
		if math.abs(b.Exp - math.log10(a.Exp)) > msd then
			return a
		else
			local magdif = 10 ^ a.Exp - math.log10(b.Exp)
			local Mantissa = b.Sign + a.Sign * magdif
			return EN.new(math.sign(Mantissa), 1, math.log10(b.Exp) + math.log10(math.abs(Mantissa)))
		end
	end

	if layera == 1 and layerb == 0 then
		if math.abs(a.Exp - math.log10(b.Exp)) > msd then
			return a
		end
		local magdif = 10 ^ (a.Exp - math.log10(b.Exp))
		local Mantissa = b.Sign + a.Sign * magdif
		return EN.new(math.sign(Mantissa), 1, math.log10(b.Exp) + math.log10(math.abs(Mantissa)))
	end

	if math.abs(a.Exp - b.Exp) > msd then
		return a
	end

	local magdif = 10 ^ (a.Exp - b.Exp)
	local Mantissa = b.Sign + a.Sign * magdif
	return EN.new(math.sign(Mantissa), 1, b.Exp + math.log10(math.abs(Mantissa)))
end

function EN.sub(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.add(Value, EN.neg(Value2))
end

function EN.toScientific(Value: EN): string
	if Value.Layer > 2 then
		if AllowOverflow then
			return ""
		end
		return "Inf"
	end
	if Value.Layer == 2 and Value.Exp > 308 then
		return "Inf"
	end
	if EN.IsZero(Value) then
		return "0e0"
	end

	if Value.Layer == 0 then
		local Mantissa = (Value.Exp / 10 ^ math.floor(math.log10(Value.Exp))) * Value.Sign
		return Mantissa .. "e" .. math.floor(math.log10(Value.Exp))
	elseif Value.Layer == 1 then
		local Mantissa = (10 ^ (Value.Exp - math.floor(Value.Exp))) * Value.Sign
		return Mantissa .. "e" .. math.floor(Value.Exp)
	end

	local Exp = 10 ^ Value.Exp
	local Mantissa = (10 ^ (Exp - math.floor(Exp))) * Value.Sign
	return Mantissa .. "e" .. math.floor(Exp)
end

function EN.mul(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)

	if EN.IsInf(Value) or EN.IsInf(Value2) then
		return Inf
	end

	if EN.IsZero(Value) or EN.IsZero(Value2) then
		return ZERO
	end

	if Value.Layer == Value2.Layer and Value.Exp == -Value2.Exp then
		return EN.new(Value.Sign * Value2.Sign, 0, 1)
	end

	local a: EN, b: EN

	if (Value.Layer > Value2.Layer) or (Value.Layer == Value2.Layer and math.abs(Value.Exp) > math.abs(Value2.Exp)) then
		a = Value
		b = Value2
	else
		a = Value2
		b = Value
	end

	if a.Layer == 0 and b.Layer == 0 then
		return EN.fromNumber(a.Sign * b.Sign * a.Exp * b.Exp)
	end
	if a.Layer >= 3 or (a.Layer - b.Layer >= 2) then
		return EN.new(a.Sign * b.Sign, a.Layer, a.Exp)
	end
	if a.Layer == 1 and b.Layer == 0 then
		return EN.new(a.Sign * b.Sign, 1, a.Exp + math.log10(b.Exp))
	end
	if a.Layer == 1 and b.Layer == 1 then
		return EN.new(a.Sign * b.Sign, 1, a.Exp + b.Exp)
	end

	if (a.Layer == 2 and b.Layer == 1) or (a.Layer == 2 and b.Layer == 2) then
		local temp = EN.new(math.sign(b.Exp), b.Layer - 1, math.abs(b.Exp))
		local nmag = EN.add(EN.new(math.sign(a.Exp), a.Layer - 1, math.abs(a.Exp)), temp)
		return EN.new(a.Sign * b.Sign, nmag.Layer + 1, nmag.Sign * nmag.Exp)
	end

	return NaN
end

function EN.div(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.mul(Value, EN.recip(Value2))
end

function EN.abslog10(Value): EN
	Value = EN.convert(Value)
	if EN.IsZero(Value) then
		return NaN
	end

	if Value.Layer > 0 then
		return EN.new(math.sign(Value.Exp), Value.Layer - 1, math.abs(Value.Exp))
	end

	return EN.new(1, 0, math.log10(math.abs(Value.Exp)))
end

function EN.pow10(Value): EN
	Value = EN.convert(Value)

	if EN.IsInf(Value) then
		return Inf
	end
	if Value.Layer == 0 then
		local nmag = 10 ^ (Value.Sign * Value.Exp)
		if nmag < 1.8e308 and math.abs(nmag) > 0.1 then
			return EN.new(1, 0, nmag)
		else
			if Value.Sign == 0 then
				return ONE
			end
			Value = EN.new(Value.Sign, Value.Layer + 1, math.log10(Value.Exp))
		end
	end

	if Value.Sign > 0 and Value.Exp > 0 then
		return EN.new(Value.Sign, Value.Layer + 1, Value.Exp)
	end
	if Value.Sign < 0 and Value.Exp > 0 then
		return EN.new(-Value.Sign, Value.Layer + 1, -Value.Exp)
	end

	return ONE
end

function EN.pow(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	if EN.IsZero(Value) then -- 0^x = 0
		return ZERO
	end

	if Value.Sign == 1 and Value.Layer == 0 and Value.Exp == 1 then -- 1^x = 1
		return ONE
	end
	if EN.IsZero(Value2) then -- x^0 = 1
		return ONE
	end
	if Value2.Sign == 1 and Value2.Layer == 0 and Value2.Exp == 1 then -- 1^x = 1
		return Value
	end

	local calc = EN.pow10(EN.mul(EN.abslog10(Value), Value2))
	if Value.Sign == -1 and EN.toNumber(Value2) % 2 == 1 then
		return EN.neg(calc)
	elseif Value.Sign == -1 and EN.toNumber(Value2) < 1e20 then
		local component = EN.fromNumber(math.cos(EN.toNumber(Value2) * math.pi))
		return EN.mul(calc, component)
	end

	return calc
end

--------------------------------------------------------------------------------------

local Sets = { "k", "M", "B" }
local FirstOnes = { "", "U", "D", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No" }
local SecondOnes = { "", "De", "Vt", "Tg", "qg", "Qg", "sg", "Sg", "Og", "Ng" }
local ThirdOnes = { "", "Ce", "Du", "Tr", "Qa", "Qi", "Se", "Si", "Ot", "Ni" }
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

function CutDigits(Value, Digits)
	if Digits < 0 then
		return Value
	end
	return math.floor(Value * 10 ^ Digits) / 10 ^ Digits
end

function EN.toSuffix(Value: EN, Digits: number): string
	Digits = Digits or DefaultDigits
	local BigNum = EN.toScientific(Value):split("e")
	local Mantissa = BigNum[1]
	local Exponent = BigNum[2]
	local Modulus3 = math.fmod(Exponent, 3)
	Exponent = math.floor(Exponent / 3) - 1

	if Exponent <= -1 then
		return CutDigits(BigNum[1] * 10 ^ BigNum[2], Digits)
	end

	if Exponent < 3 then
		return CutDigits(Mantissa * 10 ^ Modulus3, Digits) .. Sets[Exponent + 1]
	end

	local OutString = ""

	local function SuffixPartOne(n)
		local Hundreds = math.floor(n / 100)
		n = math.fmod(n, 100)
		local Tens = math.floor(n / 10)
		n = math.fmod(n, 10)
		local Ones = math.floor(n / 1)

		OutString = OutString .. FirstOnes[Ones + 1]
		OutString = OutString .. SecondOnes[Tens + 1]
		OutString = OutString .. ThirdOnes[Hundreds + 1]
	end

	local function SuffixPartTwo(n)
		if n > 0 then
			n += 1
		end
		if n > 1000 then
			n = math.fmod(n, 1000)
		end
		SuffixPartOne(n)
	end

	if Exponent < 1000 then
		SuffixPartOne(Exponent)
		return CutDigits(Mantissa * 10 ^ Modulus3, Digits) .. OutString
	end

	for i = math.floor(math.log10(Exponent) / 3), 0, -1 do
		if Exponent >= 10 ^ (i * 3) then
			SuffixPartTwo(math.floor(Exponent / 10 ^ (i * 3)) - 1)
			OutString = OutString .. MultOnes[i + 1]
			Exponent = math.fmod(Exponent, 10 ^ (i * 3))
		end
	end

	return CutDigits(Mantissa * 10 ^ Modulus3, Digits) .. OutString
end

function EN.between(Val, x, y): boolean
	Val = EN.convert(Val)
	x = EN.convert(x)
	y = EN.convert(y)
	return EN.me(Val, x) and EN.le(Val, y)
end

function EN.toLayerNotation(Value, Digits: number): string
	Value = EN.convert(Value)
	Digits = Digits or DefaultDigits

	if EN.between(Value, ZERO, ONE) then
		return "1 / " .. EN.short(EN.div(ONE, Value))
	end

	if Value.Sign == 1 then
		if Value.Exp < 0 then
			return "E(" .. Value.Layer .. "-" .. ")" .. CutDigits(math.abs(Value.Exp), Digits)
		end

		return "E(" .. Value.Layer .. ")" .. CutDigits(Value.Exp, Digits)
	end

	if Value.Sign == 0 then
		return "E(0)0"
	end

	return EN.toLayerNotation(EN.abs(Value), Digits)
end

function EN.short(Value, Digits): string
	Value = EN.convert(Value)
	if EN.le(Value, SuffixLimit) then
		return EN.toSuffix(Value, Digits)
	end
	return EN.toLayerNotation(Value, Digits)
end

function EN.root(Value, Value2): EN
	Value = EN.convert(Value)
	Value2 = EN.convert(Value2)
	return EN.pow(Value, EN.recip(Value2))
end

function EN.sqrt(Value): EN
	Value = EN.convert(Value)
	return EN.root(Value, 2)
end

function EN.gamma(Value): EN
	Value = EN.convert(Value)

	if EN.leeq(Value, ZERO) then
		return NaN
	end
	if Value.Exp < 0 then
		return EN.recip(Value)
	end

	if Value.Layer == 0 then
		if EN.le(Value, { 1, 0, 24 }) then
			return EN.fromNumber(F_Gamma(Value.Sign * Value.Exp))
		end

		local t = Value.Exp - 1
		local l = 0.9189385332046727
		l = (l + ((t + 0.5) * math.log(t)))
		l = l - t
		local n2 = t * t
		local np = t
		local lm = 12 * np
		local adj = 1 / lm
		local l2 = l + adj

		if l2 == l then
			return EN.exp(l)
		end

		l = l2
		np = np * n2
		lm = 360 * np
		adj = 1 / lm
		l2 = l - adj

		if l2 == l then
			return EN.exp(l)
		end

		l = l2
		np = np * n2
		lm = 1260 * np
		local lt = 1 / lm
		l = l + lt
		np = np * n2
		lm = 1680 * np
		lt = 1 / lm
		l = l - lt

		return EN.exp(l)
	elseif Value.Layer == 1 then
		return EN.exp(EN.mul(Value, EN.sub(EN.log(Value), 1)))
	end

	return EN.exp(Value)
end

function EN.fact(Value): EN
	Value = EN.convert(Value)
	return EN.gamma(EN.add(Value, 1))
end

function EN.rand(min, max): EN
	local seed = math.random()
	local even = EN.sub(max, min)
	even = EN.mul(even, seed)
	return EN.add(even, min)
end

function EN.exporand(min, max): EN
	local min, max = EN.convert(min), EN.convert(max)
	local sign, sign2 = min.Sign, max.Sign
	local min = EN.mul(EN.exp(EN.abs(min)), sign)
	local max = EN.mul(EN.exp(EN.abs(max)), sign2)
	return EN.exp(EN.rand(min, max))
end

function EN.lbencode(enum): number -- encode cool!
	enum = EN.convert(enum)
	if EN.eq(enum, 1) then
		return 1
	end
	local mode = 0
	if enum.Sign == -1 and enum.Layer > 9999 and math.sign(enum.Exp) == 1 then
		mode = 0
	elseif enum.Sign == -1 and enum.Layer < 9999 and math.sign(enum.Exp) == 1 then
		mode = 1
	elseif enum.Sign == -1 and enum.Layer > 9999 and math.sign(enum.Exp) == -1 then
		mode = 2
	elseif enum.Sign == -1 and enum.Layer < 9999 and math.sign(enum.Exp) == -1 then
		mode = 3
	elseif enum.Sign == 0 then
		return 4E18
	elseif enum.Sign == 1 and enum.Layer < 9999 and math.sign(enum.Exp) == -1 then
		mode = 5
	elseif enum.Sign == 1 and enum.Layer > 9999 and math.sign(enum.Exp) == -1 then
		mode = 6
	elseif enum.Sign == 1 and enum.Layer < 9999 and math.sign(enum.Exp) == 1 then
		mode = 7
	elseif enum.Sign == 1 and enum.Layer > 9999 and math.sign(enum.Exp) == 1 then
		mode = 8
	end

	local VAL = mode * 1E18
	if mode == 8 then
		VAL += ((math.log10(enum.Layer + (math.log10(enum.Exp) / 10))) * 3.2440674117208e+15)
	elseif mode == 7 then
		VAL += (enum.Layer * 1e14)
		VAL += (math.log10(enum.Exp) * 1e13)
	elseif mode == 6 then
		VAL += 1e18
		VAL -= ((math.log10(enum.Layer + (math.log10(math.abs(enum.Exp)) / 10))) * 3.2440674117208e+15)
	elseif mode == 5 then
		VAL += (enum.Layer * 1e14) + 1e14
		VAL -= (math.log10(math.abs(enum.Exp)) * 1e13)
	elseif mode == 3 then
		local VOFFSET = 0
		VAL += (enum.Layer * 1e14) + 1e14
		VAL -= (math.log10(math.abs(enum.Exp)) * 1e13)
		VOFFSET = (1e18 - VOFFSET)
		VAL += VOFFSET
	elseif mode == 2 then
		local VOFFSET = 0
		VAL += 1e18
		VAL -= ((math.log10(enum.Layer + (math.log10(math.abs(enum.Exp)) / 10))) * 3.2440674117208e+15)
		VOFFSET = (1e18 - VOFFSET)
		VAL += VOFFSET
	elseif mode == 1 then
		local VOFFSET = 0
		VAL += (enum.Layer * 1e14)
		VAL += (math.log10(enum.Exp) * 1e13)
		VOFFSET = (1e18 - VOFFSET)
		VAL += VOFFSET
	elseif mode == 0 then
		local VOFFSET = ((math.log10(enum.Layer + (math.log10(enum.Exp) / 10))) * 3.2440674117208e+15)
		VOFFSET = (1e18 - VOFFSET)
		VAL += VOFFSET
	end

	return VAL
end

function EN.lbdecode(enum: number): EN -- decodes numbers for extra spice
	if enum == 2e18 then
		return EN.new(-1, 0, 1)
	elseif enum == 3e18 then
		return EN.new(-1, 10000, -1)
	elseif enum == 1e18 then
		return EN.new(-1, 0, -1)
	elseif enum == 6e18 then
		return ONE
	elseif enum == 7e18 then
		return EN.new(1, 10000, 1)
	elseif enum == 5e18 then
		return EN.new(1, 10000, -1)
	elseif enum == 1 then
		return ONE
	end

	local mode = math.floor(enum / 1e18)
	if mode == 4 then
		return ZERO
	end

	if mode == 0 then
		local v = enum
		v = 1e18 - v
		v /= 3.2440674117208e+15
		v = 10 ^ v
		local layers = math.floor(v)
		local numbaa = 10 ^ (math.fmod(v, 1) * 10)
		return EN.new(-1, layers, numbaa)
	elseif mode == 8 then
		local v = enum - 8e18
		v /= 3.2440674117208e+15
		v = 10 ^ v
		local layers = math.floor(v)
		local numbaa = 10 ^ (math.fmod(v, 1) * 10)
		return EN.new(1, layers, numbaa)
	elseif mode == 1 then
		local v = enum - 1e18
		v = 1e18 - v
		local layers = math.floor(v / 1E14)
		local numbaa = 10 ^ (math.fmod(v, 1e14) / 1e13)
		return EN.new(-1, layers, numbaa)
	elseif mode == 7 then
		local v = enum - 7e18
		local layers = math.floor(v / 1E14)
		local numbaa = 10 ^ (math.fmod(v, 1e14) / 1e13)
		return EN.new(1, layers, numbaa)
	elseif mode == 2 then
		local v = enum - 2e18
		v /= 3.2440674117208e+15
		v = 10 ^ v
		local layers = math.floor(v)
		local e = 10 ^ (math.fmod(v, 1) * 10)
		return EN.new(-1, layers, -e)
	elseif mode == 6 then
		local v = enum - 6e18
		v = (1e18 - v)
		v /= 3.2440674117208e+15
		v = 10 ^ v
		local layers = math.floor(v)
		local e = 10 ^ (math.fmod(v, 1) * 10)
		return EN.new(1, layers, -e)
	elseif mode == 5 then
		local v = enum - 5e18
		local layers = math.floor(v / 1E14)
		local e = 10 ^ ((1e14 - math.fmod(v, 1e14)) / 1e13)
		return EN.new(1, layers, -e)
	elseif mode == 3 then
		local v = enum - 3e18
		v = (1e18 - v)
		local layers = math.floor(v / 1E14)
		local e = 10 ^ ((1e14 - math.fmod(v, 1e14)) / 1e13)
		return EN.new(-1, layers, -e)
	end

	return NaN
end

function EN.shift(Value, digits)
	Value = EN.convert(Value)
	if Value.Layer > 1 then
		return Value
	end
	if digits > 20 then
		return Value
	end
	local d = 10 ^ (Value.Exp - math.floor(Value.Exp))
	d = math.floor(digits * 10 ^ digits) / 10 ^ digits
	Value.Exp = math.floor(Value.Exp) + math.log10(d)
	return Value
end

return EN
