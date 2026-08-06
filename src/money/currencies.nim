# Create, calculate and format money in Nim language.
# 
# This package has no dependencies other than `pkg/bigints`
# and the standard library. It is designed to be a simple and efficient
# way to handle money and currency in Nim applications.
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/supranim/money

{.experimental: "dotOperators".}

import std/[math, algorithm, macros, strutils, options,
        enumutils, tables, typetraits, critbits, json]
import pkg/bigints

import ./codes
export codes, bigints

## This module provides a `Money` type and related operations for handling
## monetary values in Nim. It includes support for multiple currencies, formatting,
## conversion rates, and basic arithmetic operations. The `Money` type is designed
## to be immutable by default, with mutable operations available through specific procs.

const
  moneyDefaultCurrency* {.intdefine.}: int = 49
    # compile-time flag to manage a default currency
    # pass `-d:moneyDefaultCurrency:{int}` to change the default currency
    # Default: `49` = EURO
  moneyDefaultUnit* {.strdefine.}: string = "coins"
    # it can be either `coins` or `notes`
    # By default all amounts are represented in the smallest unit (eg. cents),
    # so EUR 5.00 is written as `amount(500, EUR)`
    # You can switch to banknotes by using `-d:moneyDefaultUnit=notes` flag
    # at compile-time

type
  Money* = object
    ## The `Money` type represents a monetary value with a specific currency.
    currency*: Currency
      ## The currency of the money, represented as a `Currency` tuple containing
    units*: BigInt
      ## The amount of money in the smallest unit (e.g., cents for USD, pennies for GBP).
    negative*, rtl*: bool
      ## `negative` indicates if the amount is negative, while `rtl` can be used
      ## for right-to-left currency formatting if needed.
    rates*: CurrencyRates
      ## A reference to `CurrencyRates` for handling conversion rates, if applicable.

  CurrencyRates* = ref object
    ## The `CurrencyRates` type holds conversion rates for a
    ## specific currency to other currencies.
    data: CritBitTree[float]
      ## A crit-bit tree mapping target currency alpha3 codes to
      ## their conversion rates relative to the base currency.

  MoneyConversionRates* = ref object
    ## The `MoneyConversionRates` type is a singleton that
    ## holds conversion rates
    data*: CritBitTree[CurrencyRates]
      ## A crit-bit tree mapping base currency alpha3 codes to
      ## their corresponding `CurrencyRates` objects.

  MoneyFormattingError* = object of CatchableError
    ## An exception type for errors that occur during money formatting.
  
  MoneyError* = object of CatchableError
    ## A general exception type for errors related to money operations.

proc amount*(units: int, currency: Alpha3): Money =
  ## Create a new amount of `Money`
  result = Money(units: initBigInt(units),
    currency: Currencies[symbolRank(currency)])

proc `.`*[A: int, C: Alpha3](unit: A, currency: C): Money = 
  result = amount(unit, currency)

template matchCurrency(operation): untyped {.dirty.} =
  if likely(x.currency[1] != y.currency[1]):
    raise newException(MoneyError,
      "Cannot operate on <" & $x.currency[1] & "> and <" & $y.currency[1] & ">")
  operation

proc getCurrency*(amount: Money): Currency =
  result = amount.currency

proc formatMoney*(amount: string, currency: Alpha3): Money =
  ## Format `amount` string to `Money`
  result = Money()
  if likely(currency != noCurrency):
    result.currency = Currencies[symbolRank(currency)]
  else:
    result.currency = Currencies[moneyDefaultCurrency]
  var
    isNeg: bool
    amount = amount
  if amount.len == 0:
    raise newException(MoneyFormattingError, "Invalid amount: amount is empty")
  if amount[0] == '-':
    isNeg = true
    amount = amount[1..^1]
  for c in amount:
    if c notin Digits and c != '.':
      raise newException(MoneyFormattingError, "Invalid amount: " & amount)
  result.negative = isNeg
  result.units =
    if not isNeg:
      initBigInt(amount)
    else:
      initBigInt("-" & amount)

proc fmt*(x: string, currency: Alpha3 =
    Alpha3(moneyDefaultCurrency)): Money {.inline.} =
  ## An alias of `formatMoney` with `currency`
  ## set as `moneyDefaultCurrency `
  formatMoney(x, currency)

proc `$$`*(x: string, currency: Alpha3 =
    Alpha3(moneyDefaultCurrency)): Money {.inline.} =
  ## An alias of `formatMoney` using `currency`
  ## set as `moneyDefaultCurrency`
  formatMoney(x, currency)

proc `$$`*(x: int): Money =
  ## Creates `Money` from `x` int
  Money(units: initBigInt(x),
    currency: Currencies[moneyDefaultCurrency])

proc newMoney*(x: string = "0", currency: Alpha3 =
    Alpha3(moneyDefaultCurrency)): Money =
  ## An alias of `formatMoney` that creates a
  ## `Money` object with amount 0
  formatMoney(x, currency)

proc newMoney*(x: BigInt, currency: Currency =
    Currencies[moneyDefaultCurrency]): Money =
  ## Creates `Money` from `x` BigInt
  Money(units: x, currency: currency)

proc newMoney*(x: int, currency: Currency =
    Currencies[moneyDefaultCurrency]): Money {.inline.} =
  ## Creates `Money` from `x` int
  newMoney(initBigInt(x), currency)

proc newMoney*(x: float, currency: Currency =
    Currencies[moneyDefaultCurrency]): Money {.inline.} =
  ## Creates `Money` from `x` float
  let expo = int(pow(10.0, float(currency.expo)))
  newMoney(initBigInt(int(round(x * expo.float))), currency)

proc toMoney*(x: float64, currency: Alpha3 = Alpha3(moneyDefaultCurrency)): Money =
  ## Convert `x` float to `Money`
  let cur = Currencies[symbolRank(currency)]
  let str = $x
  var
    whole, frac: string
  if count(str, '.') > 0:
    let f = split(str, ".")
    whole = f[0]
    frac = f[1]
  else:
    whole = str
  if frac.len > cur.expo:
    raise newException(MoneyError,
      "Invalid decimal for `" & cur.alpha3.symbolName & "`")
  while frac.len < cur.expo:
    frac.add('0')
  result = formatMoney(whole & frac, currency)

when parseEnum[MoneyUnit](moneyDefaultUnit) == moneyUnitCoins:
  proc coins*(rep: uint = 1): int = 1 * rep.int
  proc hundreds*(rep: uint = 1):  int = 10000 * rep.int
  proc thousands*(rep: uint = 1): int = 100000 * rep.int
elif parseEnum[MoneyUnit](moneyDefaultUnit) == moneyUnitNotes:
  proc coins*(rep: uint = 1): int = 1 * rep.int
  proc hundreds*(rep: uint = 1):  int = 100 * rep.int
  proc thousands*(rep: uint = 1): int = 1000 * rep.int

proc splitDec(x: BigInt): array[2, string] =
  let str = $(abs(x))
  let len = len(str)
  var units, subunits: string
  if len > 2:
    when moneyDefaultUnit == $moneyUnitCoins:
      units = str[0..^3]
      subunits = str[str.high - 1 .. ^1]
      result[0] = units
      result[1] = subunits
    else:
      # units = str[0..^3]
      result[0] = str
      result[1] = "00"
  elif len == 2:
    result[0] = "0"
    result[1] = str
  else:
    result[0] = "0"
    result[1] = "0" & str

#
# Math
#
proc isNegative*(x: Money): bool =
  ## Checks if `x` Money is negative
  x.negative or x.units < initBigInt(0)

proc isZero*(x: Money): bool =
  ## Checks if `x` Money is `0.00`
  result = x.units == initBigInt("0")

proc isCent*(x: Money): bool =
  ## Checks if `x` Money in cents
  x.units <= initBigInt("99")

proc isNotes*(x: Money): bool =
  ## Checks if `x` in banknotes
  x.units > initBigInt("99")

proc `+`*[M: Money](x, y: M): M =
  ## Addition of `x` and `y` Money.
  ## Returns the total as `Money`
  matchCurrency:
    result = x
    result.units = x.units + y.units

proc `+=`*[M: Money](x: var M, y: M) =
  ## Addition of mutable `x` and `y` Money.
  ## Returns the total as `Money`
  matchCurrency:
    x.units += y.units
    if x.units >= initBigInt(0):
      x.negative = false

proc `-`*[M: Money](x, y: M): M =
  ## Subtract of `x` based on `y`. Returns the total as new `Money`
  matchCurrency:
    result = x
    if x.units < y.units:
      result.negative = true
    result.units = x.units - y.units

proc `-=`*[M: Money](x: var M, y: M) =
  ## Performs subtraction on the two operands and assigns
  ## the result to the mutable `x`.
  matchCurrency:
    if x.units < y.units:
      x.negative = true
    x.units -= y.units

proc `*=`*[M: Money](x: var M, y: int) =
  ## Multiplies `x` with `y`, and assing the result
  x.units = x.units * initBigInt(y)

proc `*=`*[M: Money](x: var M, y: M) =
  ## Multiplies `x` with `y` and assing the result
  matchCurrency:
    x.units = x.units * y.units

proc `*`*[M: Money](x: M, y: float): M =
  ## Multiplies `x` by `y`
  ## Multiplies `x` by `y` with fixed-point precision
  result = x
  const scale = 1_000_000
  let factor = int(round(y * scale.float))
  result.units = (x.units * initBigInt(factor)) div initBigInt(scale)

proc `*`*[M: Money](x: M, y: BigInt): M =
  ## Multiplies `x` by `y`
  result = x
  result.units = (x.units * y) div initBigInt(100)

proc `*`*[M: Money](x: M, y: M): M =
  # Multiply `x` by `y`
  matchCurrency:
    result = x
    result.units = x.units * y.units

proc `/`*[M: Money](x: M, y: M): M =
  matchCurrency:
    result = x
    result.units = x.units div y.units

proc `/=`*[M: Money](x: var M, y: M) =
  matchCurrency:
    x.units = x.units div y.units

proc `/=`*[M: Money](x: var M, y: int) =
  x.units = x.units div initBigInt(y)

proc add*[M: Money](x: var M, y: varargs[M]) =
  for z in y:
    x += z

proc sub*[M: Money](x: var M, y: varargs[M]) =
  for z in y:
    x -= z

proc multi*[M: Money](x: var M, y: varargs[int]) =
  ## A mutable proc to multiply `Money` with `y` int
  for z in y:
    x *= z

proc `div`*[M: Money](x: var M, y: varargs[M]) =
  ## A mutable proc to divide `Money` by `y` Money
  for z in y:
    x /= z

proc `div`*(x: var Money, y: varargs[int]) =
  ## A mutable proc to divide `Money` by `y` int
  for z in y:
    x /= z

proc `div`*[M: Money](x: M, y: int): M =
  result = x
  result.units = result.units div initBigInt(y)

#
# Comparison
#
proc `>`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units > y.units

proc `<`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units < y.units

proc `<=`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units <= y.units

proc `>=`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units >= y.units

proc `==`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units == y.units

proc `!=`*[M: Money](x, y: M): bool =
  matchCurrency:
    return x.units != y.units

proc `%`*(perc: float, x: Money): Money =
  ## Applies `perc` to `x` Money
  var part = (perc / 100) * toInt[int](x.units).get.toFloat
  result = x
  result.units += initBigInt(int(part))

proc `%`*(perc: float, x: var Money) =
  ## Applies `perc` cut to `x` Money
  var part = (perc / 100) * toInt[int](x.units).get.toFloat
  x.units -= initBigInt(int(part))

proc abs*[M: Money](x: M): M =
  ## Returns the absolute value of `x` Money
  result = Money()
  result.units = abs(x.units)
  result.currency = x.currency

proc max*[M: Money](x: varargs[M]): M =
  ## Returns the largest of the given `Money` objects
  if x.len == 0:
    raise newException(MoneyError, "max requires at least one Money value")
  result = x[0]
  for i in 1..high(x):
    if x[i].units > result.units:
      result = x[i]

proc min*[M: Money](x: varargs[M]): M =
  ## Returns the smallest of the given `Money` objects
  if x.len == 0:
    raise newException(MoneyError, "min requires at least one Money value")
  result = x[0]
  for i in 1..high(x):
    if x[i].units < result.units:
      result = x[i]

proc avg*[M: Money](x: varargs[M]): M =
  ## Returns the average of the given `Money` objects
  if x.len == 0:
    raise newException(MoneyError, "avg requires at least one Money value")
  result = x[0]
  var total = result.units
  for i in 1..high(x):
    total += x[i].units
  result.units = total div initBigInt(x.len)

#
# Utils
#
proc contains*(x: Money, currency: Alpha3): bool =
  ## Determine if currency type of `x` Money is `currency`
  result = x.currency[1] == currency

proc isCurrency*(x: Money, currency: Alpha3): bool =
  ## An alias of `contains`
  contains(x, currency)

proc inc*(x: var Money, y: int = 1) =
  when moneyDefaultUnit == $moneyUnitCoins:
    bigints.inc(x.units, y)
  else:
    bigints.inc(x.units, y)

proc incCent*(x: var Money, y: int = 1) =
  ## Increment `x` Money by `y` cents
  bigints.inc(x.units, y)

proc incNotes*(x: var Money, y: int = 1) =
  ## Increment `x` Money by `y` banknotes
  bigints.inc(x.units, y)

#
# Conversion Rates & Exchange API
#

proc add*(cvrates: MoneyConversionRates, alpha: Alpha3, rates: JsonNode) =
  ## Adds conversion `rates` for `alpha` currency to `exchange`
  assert cvrates != nil
  if likely(not cvrates.data.hasKey($alpha)):
    cvrates.data[$alpha] = CurrencyRates()
  for k, rate in rates:
    cvrates.data[$(alpha)].data[k] = rate.getFloat

proc convert*(x: Money, y: Alpha3, cvrates: MoneyConversionRates): Money =
  ## Takes `x` Money and converts to `y` `Alpha3` currency
  assert cvrates != nil
  let symbol = $x.currency[1]
  if not cvrates.data.hasKey(symbol):
    raise newException(MoneyError, "No conversion rates registered for <" & symbol & ">")
  if y == noCurrency:
    raise newException(MoneyError, "Cannot convert to <noCurrency>")
  let currencyRates = cvrates.data[symbol]
  if not currencyRates.data.hasKey($y):
    raise newException(MoneyError, "No conversion rate from <" & symbol & "> to <" & $y & ">")
  const scale = 1_000_000
  let factor = int(round(currencyRates.data[$y] * scale.float))
  result = Money(
    units: (x.units * initBigInt(factor) + initBigInt(scale div 2)) div initBigInt(scale),
    currency: Currencies[symbolRank(y)])

#
# Cart Utilities
#
proc allocate*(x: var Money, ratios: openarray[SomeNumber]): seq[Money] =
  ## Applies successive ratios to `x` Money (each ratio uses remaining balance)
  let zero = initBigInt(0)

  if ratios.len == 0:
    raise newException(MoneyError, "Cannot allocate. Ratios cannot be empty")
  if sum(ratios) <= 0:
    raise newException(MoneyError,
      "Cannot allocate. Sum of ratios must be greater than zero")

  for ratio in ratios:
    if ratio < 0:
      raise newException(MoneyError,
        "Cannot allocate. Ratio must be zero or positive")

    if x.isZero:
      add result, Money(units: zero, currency: x.currency)
      continue

    # Apply ratio to CURRENT remaining amount (successive allocation)
    var fraction = (ratio / 100) * toInt[int](x.units).get.toFloat
    var share = initBigInt(int(round(fraction)))

    if share > x.units:
      share = x.units

    add result, Money(units: share, currency: x.currency)
    x.units -= share

proc allocate*[M: Money](x: var M, targets: int): seq[M] =
  ## An alias of `div` proc that allocates `x` Money to N targets
  if targets <= 0:
    raise newException(MoneyError, "Cannot allocate. Targets must be greater than zero")
  for i in 1..targets:
    add result, x div targets
  for i in 0..(targets - 1):
    x -= result[i]
  var i = 0
  while not x.isZero:
    dec x.units
    inc result[i].units
    inc i

proc `$`*(symbol: Alpha3): string =
  ## Returns the `symbol` name
  result = symbolName(symbol)

proc `$`*[M: Money](m: M | ref M): string =
  ## Return string representation of `Money`
  add result, $m.currency[1] & spaces(1)
  if m.negative: add result, "-"
  let d = splitDec(m.units)
  when moneyDefaultUnit == $moneyUnitCoins:
    add result, d[0] & "." & d[1]
  else:
    add result, d[0] & "." & d[1]

proc toStringMoney*(x: Money): string =
  ## An alias of `$` proc for `Money`
  $x

proc toSmallestCurrency*(x: Money): string =
  ## Converts `x` Money to the smallest currency unit (e.g., cents)
  ## For example, EUR 5.00 would be converted to "500".
  let d = splitDec(x.units)
  result = d[0] & d[1]