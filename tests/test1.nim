import unittest
import money

test "money aliases":
  block:
    var x = newMoney(199)
    assert $x == "EUR 1.99"
  
  block:
    var x = newMoney(10)
    assert $x == "EUR 0.10"

  block:
    assert $($$100.coins) == "EUR 1.00"
    assert $($$50.coins) == "EUR 0.50"

  block:
    var x = $$(2.hundreds)
    assert x == newMoney(20000)
    assert $x == "EUR 200.00"

  block:
    var x = $$(2.thousands)
    assert x == newMoney(200000)
    assert $x == "EUR 2000.00"


test "formatting":
  assert $fmt("1") == "EUR 0.01"
  assert $fmt("11") == "EUR 0.11"
  assert $fmt("1430") == "EUR 14.30"
  assert $fmt("4500", USD) == "USD 45.00"
  assert $fmt("10000") == "EUR 100.00"
  assert $fmt("100050") == "EUR 1000.50"
