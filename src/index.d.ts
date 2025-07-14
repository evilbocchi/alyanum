/** 
 * The base version of an AlyaNum object, stripped of its metatables and metamethods.
 * This type commonly appears when sending AlyaNum objects over the client-server boundary or saving it in datastores.
 * 
 * @example
 * {sign: -1, multiplicand: 4, exponent: 2, tetrate: 1, pentate: 0, hexate: 0, heptate: 0}
 * // This represents -1 * 10 ^^ (10 ^ (10 ^ 4)).
 */
interface BaseAlyaNum {
    /** This number primitive represents whether the number is positive, negative or zero. */
    sign: 1 | -1 | 0,
    /** This number primitive represents the significant digits of the entire number. */
    multiplicand: number,
    /** This number primitive represents how many times to perform `10^multiplicand`. e.g. `exponent = 2` would yield in `10^(10^multiplicand)`. */
    exponent: number,
    /** This number primitive represents how many times to perform `10^^multiplicand`. e.g. `tetrate = 3` would yield in `10^^(10^^(10^^(multiplicand)))`. */
    tetrate: number,
    /** This number primitive represents how many times to perform `10^^^multiplicand`. e.g. `pentate = 2` would yield in `10^^^(10^^^multiplicand))`. */
    pentate: number,
    /** This number primitive represents how many times to perform `10^^^^multiplicand`. e.g. `hexate = 2` would yield in `10^^^^(10^^^^multiplicand))`. */
    hexate: number,
    /** This number primitive represents how many times to perform `10^^^^^multiplicand`. e.g. `heptate = 2` would yield in `10^^^^^(10^^^^^multiplicand))`. */
    heptate: number;
}

/** An object representing a number in this library. This could be a number primitive, {@link BaseAlyaNum} or {@link AlyaNum}.*/
type Number = BaseAlyaNum | number;

type Suffixes = {
    beginning: string[],
    first: string[],
    second: string[],
    third: string[],
    mult: string[];
};

/**
 * Library for performing mathematical operations on numbers exceeding 2^1024.
 */
interface AlyaNum extends BaseAlyaNum {
    /**
     * Adds the specified number to this AlyaNum and returns the result as a new AlyaNum.
     * @param number The number to add (can be AlyaNum, BaseAlyaNum, or primitive number).
     */
    add(number: Number): AlyaNum;
    /**
     * Subtracts the specified number from this AlyaNum and returns the result as a new AlyaNum.
     * @param number The number to subtract.
     */
    sub(number: Number): AlyaNum;
    /**
     * Multiplies this AlyaNum by the specified number and returns the result as a new AlyaNum.
     * @param number The number to multiply by.
     */
    mul(number: Number): AlyaNum;
    /**
     * Divides this AlyaNum by the specified number and returns the result as a new AlyaNum.
     * @param number The number to divide by.
     */
    div(number: Number): AlyaNum;
    /**
     * Raises this AlyaNum to the power of the specified number and returns the result as a new AlyaNum.
     * @param number The exponent value.
     */
    pow(number: Number): AlyaNum;
    /**
     * Returns the remainder after dividing this AlyaNum by the specified number.
     * @param number The divisor.
     */
    mod(number: Number): AlyaNum;
    /**
     * Calculates the nth root of this AlyaNum, where n is the specified number.
     * @param number The degree of the root.
     */
    root(number: Number): AlyaNum;

    /**
     * Checks if this AlyaNum is exactly equal to the specified number.
     * @param number The number to compare against.
     * @returns True if the numbers are equal, false otherwise.
     */
    equals(number: Number): boolean;
    /**
     * Checks if this AlyaNum is less than the specified number.
     * @param number The number to compare against.
     * @returns True if this AlyaNum is less, false otherwise.
     */
    lessThan(number: Number): boolean;
    /**
     * Checks if this AlyaNum is less than or equal to the specified number.
     * @param number The number to compare against.
     * @returns True if this AlyaNum is less than or equal, false otherwise.
     */
    lessEquals(number: Number): boolean;
    /**
     * Checks if this AlyaNum is greater than the specified number.
     * @param number The number to compare against.
     * @returns True if this AlyaNum is greater, false otherwise.
     */
    moreThan(number: Number): boolean;
    /**
     * Checks if this AlyaNum is greater than or equal to the specified number.
     * @param number The number to compare against.
     * @returns True if this AlyaNum is greater than or equal, false otherwise.
     */
    moreEquals(number: Number): boolean;
    /**
     * Compares two numbers.
     * 
     * @param number 
     */
    compare(number: Number): 1 | -1 | 0;

    /**
     * Rounds down the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     */
    floor(): AlyaNum;
    /**
     * Rounds the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     */
    round(): AlyaNum;
    /**
     * Rounds up the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     */
    ceil(): AlyaNum;
    /**
     * Returns if the AlyaNum is an integer.
     * This operation is unsafe for numbers beyond 2^1024.
     */
    isInteger(): boolean;
    /**
     * Returns 1/AlyaNum.
     */
    reciprocal(): AlyaNum;
    /**
     * Returns the value of the AlyaNum after going through the Lambert W function.
     * This is a fairly expensive operation.
     * 
     * @see https://en.wikipedia.org/wiki/Lambert_W_function
     */
    lambertw(): AlyaNum;
    /**
     * Returns the super-logarithm of the AlyaNum with the specified base.
     * 
     * @param number Base of the logarithm
     * @see https://en.wikipedia.org/wiki/Iterated_logarithm
     */
    slog(number: Number): AlyaNum;
    /**
     * Returns x^^y, where ^^ = tetration, and tetration is repeated exponentiation.
     * This is an expensive operation, performing generally ~8-80x worse than {@link mul}
     * depending on different values and whether the height is an integer or not.
     * Do try to minimize calls of this function.
     * 
     * @param number Height of the power tower. If the height is not an integer, {@link lambertw}
     * is used to approximate the final result.
     * @see https://en.wikipedia.org/wiki/Tetration
     */
    tet(number: Number): AlyaNum;
    /**
    * Returns x^^^y, where ^^^ = pentation, and pentation is repeated tetration.
    * This is an expensive operation, performing generally ~8-80x worse than {@link mul}
    * depending on different values and whether the height is an integer or not.
    * Do try to minimize calls of this function.
    * 
    * @param number Height of the tetration tower. If the height is not an integer, {@link lambertw}
    * is used to approximate the final result.
    * @see https://en.wikipedia.org/wiki/Pentation
    */
    pent(number: Number): AlyaNum;
    /**
     * Returns x^^^^y, where ^^^^ = hexation, and hexation is repeated pentation.
     * This is an expensive operation, performing generally ~8-80x worse than {@link mul}
     * depending on different values and whether the height is an integer or not.
     * Do try to minimize calls of this function.
     * 
     * @param number Height of the pentation tower. If the height is not an integer, {@link lambertw}
     * is used to approximate the final result.
     * @see https://en.wikipedia.org/wiki/Hexation
     */
    hext(number: Number): AlyaNum;


    /**
     * Get the absolute value of the AlyaNum.
     */
    abs(): AlyaNum;
    /**
     * Flips the sign of the AlyaNum object.
     * Equivalent to multiplying by -1.
     */
    unary(): AlyaNum;
    /**
     * Reverts the AlyaNum back to a primitive number.
     * For numbers beyond 2^1024, this will return `math.huge`.
     * Functionally equivalent to {@link toNumber}.
     * @deprecated Use toNumber instead
     */
    revert(): number;
    /**
     * Reverts the AlyaNum back to a primitive number.
     * For numbers beyond 2^1024, this will return `math.huge`.
     */
    toNumber(): number;

    /**
     * Get the logarithm of the AlyaNum object with the specified number base.
     * 
     * @param number Base of the logarithm
     */
    log(number: Number): AlyaNum | undefined;
    /**
     * Get the logarithm of the AlyaNum object with a base of 10.
     */
    log10(): AlyaNum | undefined;
    /**
     * Converts the AlyaNum object into a displayable string.
     * 
     * @returns Resulting string
     */
    toString(): string;
    /**
     * Converts the AlyaNum into a string with a number and suffix.
     * Use the {@link AlyaNum.changeSuffixes} method to edit the suffixes.
     * If a suffix for the specified AlyaNum is not found, scientific notation is used.
     * 
     * @returns Resulting string
     */
    toSuffix(): string;
    /**
     * Converts the AlyaNum into a string in scientific notation format.
     * 
     * @returns Resulting string
     */
    toScientific(): string;
    /**
     * Converts the AlyaNum into a string in an E chain.
     * An E chain is exactly what it says. `1e(1e1M)` is formatted as `ee1M.`
     * E chains place all Es at the start, and have a maximum chain of 10 Es.
     * 
     * @returns Resulting string
     */
    toEChain(): string;
    /**
     * Converts the AlyaNum into a `format E(y)x`.
     * y is the number of times to perform 10^x.
     * For example, `E(3)2 = 10^(10^(10^2))`
     * 
     * @see https://googology.fandom.com/wiki/Nihilustheabsolutists_E_function
     * @returns Resulting string
     */
    toEnt(): string;
    /**
     * Converts the AlyaNum into Hyper-E notation, `Ex#a#b#c#d#e`.
     * a is the number of times to perform 10^x, b is the number of times to perform 10^^x, c is the number
     * of times to perform 10^^^x and so on.
     * 
     * @see https://googology.fandom.com/wiki/Hyper-E_notation
     * @returns Resulting string
     */
    toHyperE(): string;

    /**
     * Converts the AlyaNum into a single primitive number that represents the magnitude of the number.
     * This method should only be used for leaderboards and other things that do not require the
     * specific number itself as the resulting single numbers are highly inaccurate.
     *
     * @returns Resulting single number
     */
    toSingle(): number;
}

/**
 * Static version of {@link AlyaNum}. This is only separated because roblox-ts requires it.
 * You can simply ignore the naming and treat this interface as {@link AlyaNum}.
 */
interface AlyaNumConstructor {
    /** Constant for `10^100`. */
    readonly GOOGOL: AlyaNum;
    /** Cnstant for `10^(10^100)`. */
    readonly GOOGOLPLEX: AlyaNum;
    /** Constant for `10^(10^(10^100))`. */
    readonly GOOGOLPLEXPLEX: AlyaNum;
    /** Constant for 3^^^3. (^^^ = pentation) */
    readonly TRITRI: AlyaNum;
    /** Constant for 4^^^^4. (^^^^ = hexation) */
    readonly TRITET: AlyaNum;
    /** Constant for 3^^^^3. (^^^^ = hexation) */
    readonly GRAHAM1: AlyaNum;

    /**
     * Create a new AlyaNum object from a primitive number.
     * @param val Primitive number or a table containing mantissa and exponent entries
     */
    new(val: Number): AlyaNum;

    /**
     * Create a new AlyaNum object from a BaseOnoeNum. This function is mainly
     * reserved for migration of number libraries. (OnoeNum -> AlyaNum)
     * 
     * @param onoeNum Object to migrate from. Will automatically detect when the object is already migrated
     * @returns Resulting AlyaNum object
     */
    fromOnoe: (onoeNum: { mantissa: number, exponent: number; }) => AlyaNum;

    /**
     * Create a new AlyaNum object from an OmegaNum. This function is mainly
     * reserved for migration of number libraries. (OnoeNum -> OmegaNum)
     * 
     * @param onum Object to migrate from. Will automatically detect when the object is already migrated
     * @returns Resulting AlyaNum object
     */
    fromOmega: (onum: [number, number[]]) => AlyaNum;

    /**
     * Converts a formatted string into an AlyaNum.
     * Does not handle tier 2 suffixes i.e. suffixes above `Noce`.
     * 
     * @example
     * fromString("2852852858") // Result: AlyaNum 2.85B
     * fromString("5e511") // Result: AlyaNum 50NoSxgCe
     * fromString("eeee5") // Result: AlyaNum eee100000
     * fromString("26UDe") // Result: AlyaNum 26UDe
     * 
     * @param str String to parse
     * @returns Resulting AlyaNum
     */
    fromString: (str: string) => AlyaNum;


    /**
     * Rounds down the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     * 
     * @param number Number to round down
     * @returns AlyaNum rounded down to the nearest integer
     */
    floor: (number: Number) => AlyaNum;
    /**
     * Rounds the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     * 
     * @param number Number to round
     * @returns AlyaNum rounded to the nearest integer
     */
    round: (number: Number) => AlyaNum;
    /**
     * Rounds up the AlyaNum to the nearest integer.
     * This operation is unsafe for numbers beyond 2^1024.
     * 
     * @param number Number to round up
     * @returns AlyaNum rounded up to the nearest integer
     */
    ceil: (number: Number) => AlyaNum;
    /**
     * Get the absolute value of the AlyaNum.
     * 
     * @param number AlyaNum object
     * @returns Absolute value of the AlyaNum object
     */
    abs: (number: Number) => AlyaNum;
    /**
     * Flips the sign of the AlyaNum object.
     * Equivalent to multiplying by -1.
     * 
     * @param number AlyaNum object
     * @returns Negative of the AlyaNum object
     */
    unary: (number: Number) => AlyaNum;
    /**
     * Reverts the AlyaNum back to a primitive number.
     * For numbers beyond 2^1024, this will return `math.huge`.
     * 
     * @param number AlyaNum object
     * @returns Reverted primitive number
     */
    revert: (number: BaseAlyaNum) => number;
    /**
     * Get the logarithm of the AlyaNum object with the specified primitive number base.
     * 
     * @param number AlyaNum object
     * @param base Base of the logarithm as a primitive number
     * @returns Resulting AlyaNum object. Note that if the specified number is negative, this will return nil.
     */
    log: (number: Number, base: number) => AlyaNum | undefined;
    /**
     * Get the logarithm of the AlyaNum object with a base of 10.
     * 
     * @param number AlyaNum object
     * @returns Resulting AlyaNum object
     */
    log10: (number: Number) => AlyaNum | undefined;
    /**
     * Converts the AlyaNum object into a displayable string.
     * 
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toString: (number: Number) => string;
    /**
     * Converts the AlyaNum into a string with a number and suffix.
     * Use the {@link changeSuffixes} method to edit the suffixes.
     * If a suffix for the specified AlyaNum is not found, scientific notation is used.
     * 
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toSuffix: (number: Number) => string;
    /**
     * Converts the AlyaNum object into a string in scientific notation format.
     * 
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toScientific: (number: Number) => string;
    /**
     * Converts the AlyaNum into a string in an E chain.
     * An E chain is exactly what it says. `1e(1e1M)` is formatted as `ee1M.`
     * E chains place all Es at the start, and have a maximum chain of 10 Es.
     * 
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toEChain(number: Number): string;
    /**
     * Converts the AlyaNum into a `format E(y)x`.
     * y is the number of times to perform 10^x.
     * For example, `E(3)2 = 10^(10^(10^2))`
     * 
     * @see https://googology.fandom.com/wiki/Nihilustheabsolutists_E_function
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toEnt(number: Number): string;
    /**
     * Converts the AlyaNum into Hyper-E notation, `Ex#a#b#c#d#e`.
     * a is the number of times to perform 10^x, b is the number of times to perform 10^^x, c is the number
     * of times to perform 10^^^x and so on.
     * 
     * @see https://googology.fandom.com/wiki/Hyper-E_notation
     * @param number AlyaNum object
     * @returns Resulting string
     */
    toHyperE(number: Number): string;

    /**
     * Converts the AlyaNum object into a single primitive number that represents the magnitude of the number.
     * This method should only be used for leaderboards and other things that do not require the
     * specific number itself as the resulting single numbers are highly imprecise.
     * 
     * @param number AlyaNum object
     * @returns Resulting single number
     */
    toSingle: (number: Number) => number;
    /**
     * Converts the single primitive number back into an AlyaNum object.
     * This AlyaNum object is usually much more imprecise than it previous was before conversion into
     * a single primitive number.
     * Use this method to display numbers stored in leaderboard datastores.
     * 
     * @param single Single primitive number
     * @returns Resulting AlyaNum object
     */
    fromSingle: (single: number) => AlyaNum;

    /**
     * Returns the maximum value of two AlyaNum objects.
     * 
     * @returns Largest AlyaNum object
     */
    max: (number1: AlyaNum, number2: Number) => AlyaNum;
    /**
     * Returns the minimum value of two AlyaNum objects.
     * 
     * @returns Smallest AlyaNum object
     */
    min: (number1: AlyaNum, number2: Number) => AlyaNum;
    /**
     * Returns the minimum and maximum value of two AlyaNum objects.
     * 
     * @returns Smallest and largest AlyaNum object respectively
     */
    minmax: (number1: AlyaNum, number2: Number) => LuaTuple<[AlyaNum, AlyaNum]>;


    /**
     * Converts strings formatted as *raw* scientific notation into an AlyaNum.
     * This function does **NOT** accept suffixed scientific notations that are
     * produced from {@link toScientific} and should only be used as a utility
     * function to conveniently get numbers larger than 10^308.
     * @example
     * const number1 = AlyaNum.fromScientific("2.4e5200") // 2.4e5.2K
     * const number2 = new AlyaNum(2.4).mul(new AlyaNum(10).pow(5200)) // 2.4e5.2K
     * 
     * @param str Scientific notated string to convert into AlyaNum
     * @returns Resulting AlyaNum
     */
    fromScientific: (str: string) => AlyaNum;

    /**
     * Change the suffixes to be shown when using the method {@link toSuffix}.
     * 
     * @example 
     * changeSuffixes({
     *      beginning: ["K", "M", "B"],
     *      first: ["U", "D", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No"],
     *      second: ["De", "Vt", "Tg", "Qdg", "Qng", "Sxg", "Spg", "Ocg", "Nog"],
     *      third: ["Ce", "Dce", "Tce", "Qdce", "Qnce", "Sxce", "Spce", "Occe", "Noce"],
     *      mult: ["Mi", "Mc", "Na", "Pi", "Fm", "At", "Zp", "Yc", "Xo", "Ve", "Me"]
     * })
     * @param suffixes Suffix dictionary. 
     */
    changeSuffixes: (suffixes: Suffixes) => void;

    /**
    * Change the number of decimal points when formatting AlyaNum into a string.
    * @param decimalPoints Decimal points to display in strings
    */
    changeDecimalPoints: (decimalPoints: number) => void;

    /**
    * Change the default abbreviation mode used in {@link toString}. 
    * @param mode Abbreviation method to use
    */
    changeDefaultAbbreviation: (mode: "suffix" | "scientific") => void;
}

declare const AlyaNum: AlyaNumConstructor;

export default AlyaNum;