---
title: Introduction
---

# Introduction

Do you need to handle truly massive numbers in your Roblox game—without sacrificing performance?

**AlyaNum** is your solution! This library is a high-performance fork of [OmegaNum](https://create.roblox.com/store/asset/11646892509/OmegaNum-Readable) by FoundForces and [Naruyoko](https://github.com/Naruyoko),
completely rewritten for speed and readability. No more struggling with slow, unoptimized, or hard-to-maintain code.

AlyaNum supports numbers up to 10^^^^^10 (heptation!), a limit so high it's virtually unreachable in any Roblox game. Yet, it remains faster than other libraries like [EternityNum](https://create.roblox.com/store/asset/12144172446/EternityNum-2) and [InfiniteMath](https://github.com/KdudeDev/InfiniteMath).

Enjoy the freedom to work with gigantic numbers—without the headaches.


## Installation
Getting started with AlyaNum is simple! Choose your preferred method:

1. **Roblox Toolbox:** [AlyaNum on Roblox](https://create.roblox.com/store/asset/18985449198/AlyaNum)
2. **Wally:** [evilbocchi/alyanum](https://wally.run/package/evilbocchi/alyanum)
3. **npm (for roblox-ts):** [@antivivi/alyanum](https://www.npmjs.com/package/@antivivi/alyanum)


## Basic Usage

### Lua Example
```lua
local AlyaNum = require(path.to.AlyaNum)

local number = AlyaNum.new(5) -- Create a new AlyaNum representing 5
print(number) -- 5

local toAdd = AlyaNum.new(250)
toAdd = toAdd:mul(2) -- Use macro functions...
number = number + toAdd -- ...or Lua metamethods
print(number) -- 505
```

### TypeScript Example
```ts
import AlyaNum from "@antivivi/AlyaNum";

let number = new AlyaNum(5); // Create a new AlyaNum representing 5
print(number); // 5

let toAdd = new AlyaNum(250);
toAdd = toAdd.mul(2); // Use macro functions (TypeScript does not support operator overloading)
number = number.add(toAdd);
print(number); // 505
```

