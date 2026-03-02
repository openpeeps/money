import std/[unittest, tables, httpclient, json, strutils]
import money

proc m(units: int, c: Alpha3 = EUR): Money =
  amount(units, c)

when parseEnum[MoneyUnit](moneyDefaultUnit) == moneyUnitCoins:

  suite "Money / constructors + formatting":
    test "amount, dot operator, fmt, $$":
      check $m(1234, EUR) == "EUR 12.34"
      check $(1234.EUR) == "EUR 12.34"
      check $fmt("4500", USD) == "USD 45.00"
      check $($$("1430")) == "EUR 14.30"

    test "unit helpers":
      check $($$100.coins) == "EUR 1.00"
      check $($$2.hundreds) == "EUR 200.00"
      check $($$2.thousands) == "EUR 2000.00"

  suite "Money / arithmetic":
    test "+, +=, -, -=, *, /, div":
      var a = m(1000)   # 10.00
      let b = m(250)    # 2.50
      check $(a + b) == "EUR 12.50"
      a += b
      check $a == "EUR 12.50"
      a -= m(100)
      check $a == "EUR 11.50"
      check $(m(129) * 1.83) == "EUR 2.36"
      check $(m(500) * initBigInt(150)) == "EUR 7.50"
      check $(m(1000) div 4) == "EUR 2.50"

    test "mutable helpers add/sub/multi/div":
      var x = m(1000)
      x.add(m(100), m(200))
      check $x == "EUR 13.00"
      x.sub(m(50), m(50))
      check $x == "EUR 12.00"
      x.multi(2, 2)
      check $x == "EUR 48.00"
      x.div(2, 3)
      check $x == "EUR 8.00"

  suite "Money / comparisons + predicates":
    test "comparison operators":
      check m(100) < m(101)
      check m(100) <= m(100)
      check m(101) > m(100)
      check m(101) >= m(101)
      check m(100) == m(100)
      check m(100) != m(100, USD)

    test "isZero/isNegative/isCent/isNotes":
      check m(0).isZero
      check m(-1).isNegative
      check m(99).isCent
      check m(100).isNotes

  suite "Money / percentage + abs + min/max":
    test "% operators":
      let gross = 19.0 % m(1000)   # +19%
      check $gross == "EUR 11.90"
      var discounted = m(1000)
      10.0 % discounted            # -10%
      check $discounted == "EUR 9.00"

    test "abs, min, max":
      check $abs(m(-505)) == "EUR 5.05"
      check $max(m(100), m(999), m(250)) == "EUR 9.99"
      check $min(m(100), m(999), m(250)) == "EUR 1.00"

  suite "Money / currency utils":
    test "contains + isCurrency":
      let x = m(100, GBP)
      check x.contains(GBP)
      check x.isCurrency(GBP)
      check not x.contains(EUR)

    test "inc, incCent, incNotes":
      var x = m(100)
      x.inc()
      check $x == "EUR 1.01"
      x.incCent(9)
      check $x == "EUR 1.10"
      x.incNotes(90)
      check $x == "EUR 2.00"

  suite "Money / allocation":
    test "allocate by targets":
      var x = m(1000)
      let parts = allocate(x, 3)
      check parts.len == 3
      check $(parts[0] + parts[1] + parts[2]) == "EUR 10.00"

    test "allocate by ratios":
      var x = m(1000)
      let parts = allocate(x, [50, 30, 20])
      check parts.len == 3
      check $parts[0] == "EUR 5.00"
      check $parts[1] == "EUR 1.50"
      check $parts[2] == "EUR 0.70"

  suite "Money / conversion":
    test "init rates + convert":
      initRates()
      let eurRates = parseJson("""{"EUR":1,"USD":1.08,"GBP":0.855}""")
      let gbpRates = parseJson("""{"GBP":1,"EUR":1.17,"USD":1.26}""")
      let usdRates = parseJson("""{"USD":1,"EUR":0.927,"GBP":0.791}""")
      initCurrencyRates(EUR, eurRates)
      initCurrencyRates(GBP, gbpRates)
      initCurrencyRates(USD, usdRates)

      let eur = m(2000, EUR)
      let usd = eur.convert(USD)
      let gbp = eur.convert(GBP)
      check $usd == "USD 21.60"
      check $gbp == "GBP 17.10"

    suite "Money / weird numbers":
      test "very large amount formatting + arithmetic":
        let big = fmt("12345678901234567890")
        check $big == "EUR 123456789012345678.90"

        let bumped = big + m(10)
        check $bumped == "EUR 123456789012345679.00"

      test "negative values and mixed-sign arithmetic":
        let debt = m(1000) - m(2500)
        check $debt == "EUR -15.00"
        check $abs(debt) == "EUR 15.00"

        let lessDebt = debt + m(500)
        check $lessDebt == "EUR -10.00"

      test "compound VAT + sale on large amount":
        let base = fmt("1000000")      # EUR 10000.00
        let gross = 19.0 % base        # +19%
        check $gross == "EUR 11900.00"

        var sale = gross
        12.5 % sale                    # -12.5%
        check $sale == "EUR 10412.50"

      test "allocate by targets preserves full total":
        var src = m(123456789)
        let original = src
        let parts = allocate(src, 7)

        var total = m(0)
        for p in parts:
          total += p

        check parts.len == 7
        check total == original
        check src.isZero

      test "large reversible scaling with int factors":
        var x = fmt("7000000000000000")
        let original = x
        x.multi(3, 5)
        
        x /= 15
        check x == original
        check x.toSmallestCurrency() == "7000000000000000"

    test "money aliases":
      block:
        var x = newMoney(199)
        inc x
        # assert $x == "EUR 1.99"
      
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

    test "math":
      assert newMoney(129) * 1.83 == newMoney(236)
      assert newMoney(290) * 0.20 == newMoney(58)

    test "exchange":
      # var exchange = newHttpClient()
      var eurRates = parseJSON("""{"provider":"https://www.exchangerate-api.com","WARNING_UPGRADE_TO_V6":"https://www.exchangerate-api.com/docs/free","terms":"https://www.exchangerate-api.com/terms","base":"EUR","date":"2024-03-31","time_last_updated":1711843201,"rates":{"EUR":1,"AED":3.96,"AFN":77.06,"ALL":104.11,"AMD":425.01,"ANG":1.93,"AOA":911.91,"ARS":925.28,"AUD":1.66,"AWG":1.93,"AZN":1.84,"BAM":1.96,"BBD":2.16,"BDT":118.44,"BGN":1.96,"BHD":0.406,"BIF":3079.77,"BMD":1.08,"BND":1.46,"BOB":7.49,"BRL":5.41,"BSD":1.08,"BTN":90.02,"BWP":14.85,"BYN":3.51,"BZD":2.16,"CAD":1.46,"CDF":2997.01,"CHF":0.973,"CLP":1056.89,"CNY":7.81,"COP":4160.5,"CRC":543.19,"CUP":25.9,"CVE":110.27,"CZK":25.28,"DJF":191.79,"DKK":7.46,"DOP":64,"DZD":145.81,"EGP":51.14,"ERN":16.19,"ETB":61.68,"FJD":2.44,"FKP":0.855,"FOK":7.46,"GBP":0.855,"GEL":2.91,"GGP":0.855,"GHS":14.49,"GIP":0.855,"GMD":70.67,"GNF":9265.78,"GTQ":8.43,"GYD":226.61,"HKD":8.44,"HNL":26.69,"HRK":7.53,"HTG":144.07,"HUF":394.16,"IDR":17128.43,"ILS":3.97,"IMP":0.855,"INR":90.03,"IQD":1415.61,"IRR":45582.19,"ISK":150.29,"JEP":0.855,"JMD":166.4,"JOD":0.765,"JPY":163.41,"KES":142.19,"KGS":96.48,"KHR":4377.21,"KID":1.66,"KMF":491.97,"KRW":1457.03,"KWD":0.332,"KYD":0.899,"KZT":482.96,"LAK":22277.48,"LBP":96583.47,"LKR":324.18,"LRD":209.31,"LSL":20.4,"LYD":5.24,"MAD":10.94,"MDL":19.06,"MGA":4702.89,"MKD":61.5,"MMK":2834.08,"MNT":3641.51,"MOP":8.7,"MRU":43.46,"MUR":49.84,"MVR":16.69,"MWK":1867.21,"MXN":17.9,"MYR":5.11,"MZN":69.01,"NAD":20.4,"NGN":1526.16,"NIO":39.79,"NOK":11.69,"NPR":144.04,"NZD":1.8,"OMR":0.415,"PAB":1.08,"PEN":4.02,"PGK":4.08,"PHP":60.66,"PKR":300.31,"PLN":4.3,"PYG":7925.36,"QAR":3.93,"RON":4.97,"RSD":117.14,"RUB":99.81,"RWF":1435.76,"SAR":4.05,"SBD":9.15,"SCR":14.67,"SDG":483.53,"SEK":11.52,"SGD":1.46,"SHP":0.855,"SLE":24.51,"SLL":24510.38,"SOS":618.34,"SRD":37.76,"SSP":1711.8,"STN":24.5,"SYP":13902.77,"SZL":20.4,"THB":39.32,"TJS":11.8,"TMT":3.78,"TND":3.38,"TOP":2.54,"TRY":34.98,"TTD":7.71,"TVD":1.66,"TWD":34.55,"TZS":2775.3,"UAH":42.05,"UGX":4198.75,"USD":1.08,"UYU":40.65,"UZS":13676.24,"VES":39.26,"VND":26770.28,"VUV":130.27,"WST":2.98,"XAF":655.96,"XCD":2.91,"XDR":0.816,"XOF":655.96,"XPF":119.33,"YER":270.56,"ZAR":20.4,"ZMW":26.91,"ZWL":23873.09}}""")
      var gbpRates = parseJSON("""{"provider":"https://www.exchangerate-api.com","WARNING_UPGRADE_TO_V6":"https://www.exchangerate-api.com/docs/free","terms":"https://www.exchangerate-api.com/terms","base":"GBP","date":"2024-04-01","time_last_updated":1711929601,"rates":{"GBP":1,"AED":4.64,"AFN":89.91,"ALL":120.61,"AMD":496.4,"ANG":2.26,"AOA":1061.78,"ARS":1083.41,"AUD":1.93,"AWG":2.26,"AZN":2.15,"BAM":2.29,"BBD":2.53,"BDT":138.67,"BGN":2.29,"BHD":0.475,"BIF":3627.03,"BMD":1.26,"BND":1.7,"BOB":8.74,"BRL":6.33,"BSD":1.26,"BTN":105.3,"BWP":17.38,"BYN":4.12,"BZD":2.53,"CAD":1.71,"CDF":3528.11,"CHF":1.14,"CLP":1237.71,"CNY":9.15,"COP":4863.2,"CRC":632.86,"CUP":30.33,"CVE":129.1,"CZK":29.6,"DJF":224.56,"DKK":8.74,"DOP":74.74,"DZD":169.94,"EGP":59.73,"ERN":18.95,"ETB":71.46,"EUR":1.17,"FJD":2.85,"FKP":1,"FOK":8.74,"GEL":3.39,"GGP":1,"GHS":16.77,"GIP":1,"GMD":85.02,"GNF":10790.62,"GTQ":9.84,"GYD":264.37,"HKD":9.89,"HNL":31.17,"HRK":8.82,"HTG":167.79,"HUF":461.34,"IDR":20029.87,"ILS":4.66,"IMP":1,"INR":105.3,"IQD":1651.46,"IRR":54765.53,"ISK":175.81,"JEP":1,"JMD":194.26,"JOD":0.896,"JPY":191.15,"KES":166.71,"KGS":112.93,"KHR":5106.47,"KID":1.94,"KMF":575.99,"KRW":1701.97,"KWD":0.388,"KYD":1.05,"KZT":563.55,"LAK":26260.5,"LBP":113089.69,"LKR":379.44,"LRD":244.53,"LSL":23.83,"LYD":6.11,"MAD":12.74,"MDL":22.24,"MGA":5538.5,"MKD":72.03,"MMK":3191.21,"MNT":4264.32,"MOP":10.18,"MRU":50.24,"MUR":58.49,"MVR":19.48,"MWK":2190.54,"MXN":20.92,"MYR":5.97,"MZN":80.64,"NAD":23.83,"NGN":1724.37,"NIO":46.59,"NOK":13.71,"NPR":168.48,"NZD":2.11,"OMR":0.486,"PAB":1.26,"PEN":4.69,"PGK":4.8,"PHP":70.98,"PKR":350.92,"PLN":5.03,"PYG":9273.49,"QAR":4.6,"RON":5.81,"RSD":137.09,"RUB":116.92,"RWF":1638.01,"SAR":4.74,"SBD":10.61,"SCR":17.64,"SDG":564.09,"SEK":13.5,"SGD":1.7,"SHP":1,"SLE":28.68,"SLL":28670.39,"SOS":721.36,"SRD":44.6,"SSP":2002.46,"STN":28.68,"SYP":16280.43,"SZL":23.83,"THB":45.98,"TJS":13.81,"TMT":4.42,"TND":3.95,"TOP":3,"TRY":40.97,"TTD":8.58,"TVD":1.94,"TWD":40.37,"TZS":3235.24,"UAH":49.2,"UGX":4908.71,"USD":1.26,"UYU":47.4,"UZS":16114.12,"VES":45.82,"VND":31381.24,"VUV":152.31,"WST":3.44,"XAF":767.98,"XCD":3.41,"XDR":0.955,"XOF":767.98,"XPF":139.71,"YER":315.85,"ZAR":23.83,"ZMW":31.57,"ZWL":27868.62}}""")
      var usdRates = parseJSON("""{"provider":"https://www.exchangerate-api.com","WARNING_UPGRADE_TO_V6":"https://www.exchangerate-api.com/docs/free","terms":"https://www.exchangerate-api.com/terms","base":"USD","date":"2024-04-01","time_last_updated":1711929601,"rates":{"USD":1,"AED":3.67,"AFN":71.24,"ALL":95.58,"AMD":393.27,"ANG":1.79,"AOA":841.42,"ARS":857.42,"AUD":1.53,"AWG":1.79,"AZN":1.7,"BAM":1.81,"BBD":2,"BDT":109.77,"BGN":1.81,"BHD":0.376,"BIF":2868.44,"BMD":1,"BND":1.35,"BOB":6.92,"BRL":5.01,"BSD":1,"BTN":83.43,"BWP":13.77,"BYN":3.27,"BZD":2,"CAD":1.35,"CDF":2790.5,"CHF":0.902,"CLP":980.81,"CNY":7.24,"COP":3852.83,"CRC":501.7,"CUP":24,"CVE":102.17,"CZK":23.43,"DJF":177.72,"DKK":6.91,"DOP":59.22,"DZD":134.65,"EGP":47.27,"ERN":15,"ETB":56.83,"EUR":0.927,"FJD":2.26,"FKP":0.792,"FOK":6.91,"GBP":0.791,"GEL":2.7,"GGP":0.792,"GHS":13.28,"GIP":0.792,"GMD":67.38,"GNF":8549.12,"GTQ":7.8,"GYD":209.38,"HKD":7.83,"HNL":24.69,"HRK":6.98,"HTG":132.9,"HUF":365.19,"IDR":15869.68,"ILS":3.68,"IMP":0.792,"INR":83.43,"IQD":1308.02,"IRR":41914.51,"ISK":139.15,"JEP":0.792,"JMD":153.96,"JOD":0.709,"JPY":151.28,"KES":131.67,"KGS":89.4,"KHR":4044.37,"KID":1.53,"KMF":455.86,"KRW":1345.83,"KWD":0.308,"KYD":0.833,"KZT":447.23,"LAK":20817.77,"LBP":89500,"LKR":300.56,"LRD":193.77,"LSL":18.87,"LYD":4.84,"MAD":10.11,"MDL":17.65,"MGA":4388.63,"MKD":56.96,"MMK":2103.61,"MNT":3375.24,"MOP":8.06,"MRU":39.8,"MUR":46.33,"MVR":15.44,"MWK":1734.9,"MXN":16.56,"MYR":4.72,"MZN":63.87,"NAD":18.87,"NGN":1329.57,"NIO":36.91,"NOK":10.85,"NPR":133.49,"NZD":1.67,"OMR":0.384,"PAB":1,"PEN":3.72,"PGK":3.8,"PHP":56.18,"PKR":277.78,"PLN":3.98,"PYG":7347.58,"QAR":3.64,"RON":4.61,"RSD":108.58,"RUB":92.56,"RWF":1287.91,"SAR":3.75,"SBD":8.48,"SCR":13.51,"SDG":458.38,"SEK":10.69,"SGD":1.35,"SHP":0.792,"SLE":22.71,"SLL":22712.78,"SOS":571.32,"SRD":35.32,"SSP":1584.2,"STN":22.7,"SYP":12904.1,"SZL":18.87,"THB":36.38,"TJS":10.94,"TMT":3.5,"TND":3.13,"TOP":2.38,"TRY":32.43,"TTD":6.79,"TVD":1.53,"TWD":31.95,"TZS":2563.67,"UAH":39,"UGX":3889.53,"UYU":37.57,"UZS":12766.31,"VES":36.29,"VND":24831.14,"VUV":120.78,"WST":2.74,"XAF":607.82,"XCD":2.7,"XDR":0.757,"XOF":607.82,"XPF":110.57,"YER":250.24,"ZAR":18.86,"ZMW":25.02,"ZWL":20781.39}}""")
      money.initRates()
      money.initCurrencyRates(EUR, eurRates["rates"])
      money.initCurrencyRates(GBP, gbpRates["rates"])
      money.initCurrencyRates(USD, usdRates["rates"])

      block:
        var x = newMoney(2000).convert(USD)
        echo x.convert(GBP)
        assert x == 2160.USD
      block:
        var xeur = 2000.EUR
        let xgbp = xeur.convert(GBP)
        assert xgbp == 1710.GBP
        let xusd = xgbp.convert(USD)
        assert xusd == 2154.USD

  suite "interactive examples":
    test "product pricing examples (VAT + sale price)":
      type ProductPrice = object
        sku, title: string
        net: Money
        vatRate: float
        gross: Money
        saleRate: float
        saleGross: Money

      proc priced(
        sku, title, netCents: string,
        vatRate: float,
        saleRate: float = 0.0
      ): ProductPrice =
        let net = fmt(netCents)        # cents string -> Money
        let gross = vatRate % net      # add VAT
        var saleGross = gross
        if saleRate > 0:
          saleRate % saleGross         # subtract sale %
        ProductPrice(
          sku: sku,
          title: title,
          net: net,
          vatRate: vatRate,
          gross: gross,
          saleRate: saleRate,
          saleGross: saleGross
        )

      let tshirt = priced("TSHIRT-BLK", "T-Shirt Black", "2099", 19.0, 10.0)
      let book   = priced("BOOK-PRINT", "Nim Print Book", "5200", 7.0, 15.0)
      let mug    = priced("MUG-001", "Ceramic Mug", "1299", 9.0)

      check $tshirt.net == "EUR 20.99"
      check $tshirt.gross == "EUR 24.97"
      check $tshirt.saleGross == "EUR 22.48"

      check $book.net == "EUR 52.00"
      check $book.gross == "EUR 55.64"
      check $book.saleGross == "EUR 47.30"

      check $mug.net == "EUR 12.99"
      check $mug.gross == "EUR 14.15"
      check $mug.saleGross == "EUR 14.15" # no sale

      var total = newMoney()
      total += tshirt.saleGross
      total += book.saleGross
      total += mug.saleGross
      check $total == "EUR 83.93"
      check total.toSmallestCurrency() == "8393"

  suite "Money / persona use-cases":
    test "Alice buys a product (VAT applied)":
      var alice = m(10000)                 # EUR 100.00
      let net = m(3499)                    # EUR 34.99
      let gross = 19.0 % net               # +19% VAT => EUR 41.63

      alice -= gross
      check $gross == "EUR 41.63"
      check $alice == "EUR 58.37"

    test "Alice sells product, platform fee, affiliate share":
      let sale = m(10000)                  # EUR 100.00
      let platformFee = sale * 0.125       # 12.5% => EUR 12.50
      let affiliateShare = platformFee * 0.1 # 10% of fee => EUR 1.25
      let sellerPayout = sale - platformFee
      let platformNet = platformFee - affiliateShare

      check $sellerPayout == "EUR 87.50"
      check $platformFee == "EUR 12.50"
      check $affiliateShare == "EUR 1.25"
      check $platformNet == "EUR 11.25"

    test "Alice pays shared bill with Bob and Carol":
      # Successive allocation: 50%, then 30% of remaining, then 20% of remaining
      var bill = m(12000)                  # EUR 120.00
      let shares = allocate(bill, [50, 30, 20])

      check shares.len == 3
      check $shares[0] == "EUR 60.00"      # Alice
      check $shares[1] == "EUR 18.00"      # Bob
      check $shares[2] == "EUR 8.40"       # Carol

      # Remainder stays in bill because ratios are successive
      check $bill == "EUR 33.60"

    test "Alice sale then partial refund":
      var merchant = m(0)
      merchant += m(2500)                  # sale EUR 25.00
      merchant -= m(999)                   # partial refund EUR 9.99

      check $merchant == "EUR 15.01"
else:
  # MoneyUnit is Notes, so amounts are in whole currency units,
  # not cents. This requires `-d:moneyDefaultUnit=notes`
  # TODO
  test "money aliases":
    block:
      var x = newMoney(199)
      assert $x == "EUR 199.00"

  test "inc/dec money":
    block:
      var x = newMoney(199)
      x.inc
      echo x
