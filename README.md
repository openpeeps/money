<p align="center">
  <img src="https://github.com/openpeeps/money/blob/main/.github/money.png" width="128px"><br>Create, calculate and format money in 👑 Nim language.
</p>

<p align="center">
  <code>nimble install money</code>
</p>

<p align="center">
  <a href="#">API reference</a><br>
  <img src="https://github.com/openpeeps/money/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/money/workflows/docs/badge.svg" alt="Github Actions">
</p>

Nim library to make working with money safer, easier and fun!
> If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have $999.997634 -- Bill Karwin


## 😍 Key Features
- Framework agnostic
- Works with BigInts via `pkg/bigints`
- Math Operations `+`, `-`, `*`, `/`
- Math Operations (mutable) `+=` `-=`, `*=`, `*/` => `add`, `sub`, `multi`, `div`
- Money Formatting (including intl formatter) 
- Money Exchange using 3rd party providers

## Examples

> [!NOTE]
> Use compile-time flag `-d:moneyDefaultCurrency` to change the default currency used by constructors that don't specify a currency. For example, `amount(1000)` will create a `Money` instance with the default currency set by the flag. If the flag is not set, it defaults to EUR.

### Constructors and formatting
All constructors return a `Money` instance, which can be formatted using the `$` operator. The formatting is based on the currency's symbol and the amount, with two decimal places for cents.

```nim
import money

let a = amount(1234, EUR)
let b = 1234.EUR
let c = fmt("4500", USD)

assert $a == "EUR 12.34"
assert $b == "EUR 12.34"
assert $c == "USD 45.00"
```

### Arithmetic
Allows addition, subtraction, multiplication and division of money amounts. The result is always a new `Money` instance, so the original values remain unchanged. Mutable versions of these operations are also available, which modify the original instance instead of creating a new one.
```
import money

var a = amount(1000, EUR)  # EUR 10.00
let b = amount(250, EUR)   # EUR 2.50

assert $(a + b) == "EUR 12.50"
a += b
a -= amount(100, EUR)
assert $a == "EUR 11.50"

assert $(amount(129, EUR) * 1.83) == "EUR 2.36"
assert $(amount(1000, EUR) div 4) == "EUR 2.50"
```

### Allocation
Money instances are immutable by default, but mutable versions can be created using `var` and the mutable operators. This allows for efficient memory usage when performing multiple operations on the same instance.

```nim
import money

var x = amount(1000, EUR)
let parts = allocate(x, [50, 30, 20]) # successive ratios

assert $parts[0] == "EUR 5.00"
assert $parts[1] == "EUR 1.50"
assert $parts[2] == "EUR 0.70"
```

### Exachange
Money can be exchanged between different currencies using exchange rates. The library provides a way to perform currency exchange using 3rd party providers, allowing for up-to-date exchange rates.

```
import money
import std/json
import money

var prevRates = MoneyConversionRates()
prevRates.add(EUR, parseJson("""{"EUR":1,"USD":1.08,"GBP":0.855}"""))
prevRates.add(GBP, parseJson("""{"GBP":1,"EUR":1.17,"USD":1.26}"""))
prevRates.add(USD, parseJson("""{"USD":1,"EUR":0.927,"GBP":0.791}"""))

let eur = amount(2000, EUR)
assert $eur.convert(USD) == "USD 21.60"
assert $eur.convert(GBP) == "GBP 17.10"
```

> [!NOTE]
> Check the [tests](/tests/test1.nim) for more examples!

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/money/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/money/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)

This library is inspired from [moneyphp/money](https://github.com/moneyphp/money).

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps)<br>
Copyright &copy; 2025 OpenPeeps & Contributors &mdash; All rights reserved.
