import unittest
import money

test "formatting":
  assert $fmt("1") == "EUR 0.01"
  assert $fmt("11") == "EUR 0.11"
  assert $fmt("1430") == "EUR 14.30"
  assert $fmt("4500", USD) == "USD 45.00"
  assert $fmt("10000") == "EUR 100.00"
  assert $fmt("100050") == "EUR 1000.50"
