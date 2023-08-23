import unittest
import money

test "amount == amount":
  assert 0.01.USD == 0.01.USD
  assert 0.99.EUR == 0.99.EUR
  assert 1.00.EUR == 1.00.EUR
  assert 100.50.EUR == 100.50.EUR
  assert 1000.EUR == 1000.EUR

test "amount > amount":
  assert 100.EUR > 99.99.EUR
  assert 99.99.EUR > 99.99.EUR == false

test "amount + amount":
  assert 0.01.USD + 0.01.USD == 0.02.USD
  assert 0.99.EUR + 0.99.EUR == 1.98.EUR
  assert 1.00.EUR + 1.00.EUR == 2.EUR
  assert 100.50.EUR + 100.50.EUR == 201.00.EUR
  assert 1000.EUR + 1000.EUR == 2000.EUR

  assert amount(100, 50, USD) + amount(55, USD) == amount(155, 50, USD)


test "amount - amount":
  assert 0.02.USD - 0.01.USD == 0.01.USD
  assert 0.99.EUR - 0.99.EUR == 0.00.EUR
  assert 2.00.EUR - 1.00.EUR == 1.EUR
  assert 201.00.EUR - 100.50.EUR == 100.5.EUR
  assert 200.50.EUR - 100.80.EUR == 99.7.EUR
  assert 2000.EUR - 1000.EUR == 1000.EUR

  assert amount(100, USD) - amount(55, USD) == amount(45, USD)

test "currencies":
  var x = 200.USD
  var y = 199.CZK
  assert y.getCurrency.name == "CZECH KORUNA"
  assert y.getCurrency.alpha3 == CZK
  assert y.getCurrency.expo == 2

  var e = 100.EUR
  assert e.getCurrency.name == "Euro"
  assert e.getCurrency.alpha3 == EUR
  assert e.getCurrency.expo == 2
  
  assert x.contains(USD) == true
  assert amount(200, EUR).contains(EUR) == true
  assert amount(199, CZK) != amount(100, EUR)

test "amount min":
  assert min(50.EUR, 55.EUR, 120.EUR, 5.EUR, 5.02.EUR) == 5.EUR

test "amount max":
  assert max(50.EUR, 55.EUR, 120.EUR, 5.EUR, 120.50.EUR) == 120.50.EUR