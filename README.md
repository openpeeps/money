<p align="center">
  <img src="https://github.com/supranim/money/blob/main/.github/logo.png" width="90px"><br>Create, calculate and format money in 👑 Nim language.
</p>

<p align="center">
  <code>nimble install money</code>
</p>

<p align="center">
  <a href="#">API reference</a><br>
  <img src="https://github.com/supranim/money/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/supranim/money/workflows/docs/badge.svg" alt="Github Actions">
</p>

Nim library to make working with money safer, easier and fun!
> If I had a dime for every time I've seen someone use FLOAT to store currency, I'd have $999.997634 -- Bill Karwin


## 😍 Key Features
- Framework agnostic
- Works with BigInts via `pkg/bigints`
- Math Operations `+`, `-`, `*`, `/`
- Math Operations (mutable) `+=` `-=`, `*=`, `/=` => `add`, `sub`, `multi`, `div`
- Money Formatting (including intl formatter) 
- Money Exchange using 3rd party providers

## Examples

Use `defaultCurrency` option to change the default currency at compile-time. Example `-d:defaultCurrency:49` (default) for `EURO` 

```nim
import money

assert $(fmt("150")) == "EUR 1.50"
assert 2500.EUR == fmt"2500" # EUR 25.50
```

### Math

```nim
var
  x = amount("150", EUR)
  y = amount("150", EUR)

assert x + y == 300.EUR # EUR 3.00

x += y
assert x == 300.EUR   # EUR 3.00
assert x + y > y      # EUR 3.00 > EUR 1.50  
```

```nim
var x = fmt("100")
assert $(x - fmt(50)) == "EUR 0.50"
```

### Comparisons
Comparing `x` to `y` is easy!

```nim
var
  x = 100.EUR
  y = 150.EUR

assert x == 100.EUR
assert x < y
assert x >= 99.EUR
assert x != 100.USD
assert y > x
assert y >= 149.EUR
```

### Cart Example
[Dummy cart example available in `/tests`](https://github.com/supranim/money/blob/main/tests/test1.nim)

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/supranim/money/issues)
- 👋 Wanna help? [Fork it!](https://github.com/supranim/money/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)
- 🥰 [Donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C)

This library is inspired from [moneyphp/money](https://github.com/moneyphp/money).

### 🎩 License
Money | MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps) for Supranim<br>
Copyright &copy; 2023 Supranim | OpenPeeps & Contributors &mdash; All rights reserved.
