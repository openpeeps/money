import std/[unittest, tables, strutils]
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

test "comparisons":
  var x = 100.EUR
  var y = 150.EUR
  assert x == 100.EUR
  assert x < y
  assert x >= 99.EUR
  assert x != 100.USD
  assert y > x
  assert y >= 149.EUR

test "dummy cart example":
  # todo add discount coupons
  type
    Price = tuple[
      net, gross: Money
    ]

    Product = object
      title: string
      types: Table[string, Price]

    Cart = object
      products: OrderedTable[int, tuple[p: Product, choice: string]]

  proc price(net: string): Price =
    let netPrice = money.fmt(net)
    (net: netPrice, gross: 19 % netPrice)

  # create a product
  var
    tshirt = Product(
      title: "Cool t-shirt with Nim logo",
      types: {
        "black": price("2099"),
        "white": price("1899")
      }.toTable
    )
    book = Product(
      title: "Mastering Nim 2.0 - A complete guide to the programming language",
      types: {
        "ebook": price("4000"),
        "print": price("5200")
      }.toTable
    )

  # Init cart
  var cart = Cart()
  cart.products[1234] = (tshirt, "black")
  cart.products[4321] = (book, "ebook")

  # runtime
  echo "My Cart ($1):\n" % [$(cart.products.len)]
  var total = newMoney()
  var shipping = newMoney(850)
  for k, prod in pairs(cart.products):
    echo indent("SKU($1)\n$2" % [$(k), prod.p.title], 2)
    echo spaces(5), "Type: $1" % [prod.choice]
    let price = prod.p.types[prod.choice]
    echo spaces(5), "Price: $1" % [$(price.gross)]
    total += price.gross
    echo repeat("-", 30)

  let spanShipping = "Shipping Cost: $1" % [$(shipping)]
  let spanTotal =  "Total: $1" % [$(total)]
  let spanTotalShipping = "Total + Shipping: $1" % [$(total + shipping)]

  echo indent(spanShipping, 7)
  echo indent(spanTotal, 15)
  echo indent(spanTotalShipping, 4)
  echo repeat("-", 30)