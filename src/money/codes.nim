type
  MoneyUnit* = enum
    ## The `MoneyUnit` type represents the unit of money, which can be either coins or notes.
    ## By default, the unit is set to coins, but you can switch to notes by using
    ## the `-d:moneyDefaultUnit=notes` flag at compile-time.
    moneyUnitCoins = "coins"
    moneyUnitNotes = "notes"
  
  Currency* = tuple[name: string, alpha3: Alpha3, expo: int]
    ## The `Currency` type represents a currency with its name, ISO 4217 alpha-3 code, and exponent.
    ## The `expo` field indicates the number of decimal places used by the currency (e.g., 2 for USD).

  Alpha3* {.pure.} = enum
    ## The `Alpha3` type is an enumeration of ISO 4217 currency codes.
    ## Each currency code is associated with its numeric code as defined by the ISO 4217 standard.
    ## For example, USD has the alpha-3 code "USD" and the numeric code 840. The `noCurrency` value represents an undefined or unknown currency.
    ## https://www.iso.org/iso-4217-currency-codes.html
    DZD # = "012"
    AOA # = "973"
    ARS # = "032"
    AUD # = "036"
    AZN # = "944"
    BSD # = "044"
    BHD # = "048"
    THB # = "764"
    PAB # = "590"
    BBD # = "052"
    BYN # = "933"
    BZD # = "084"
    BMD # = "060"
    BTN # = "064"
    VEF # = "937"
    ESA # = "996"
    BOB # = "068"
    GBP # = "826"
    BND # = "096"
    BIF # = "108"
    XPF # = "953"
    XOF # = "952"
    XAF # = "950"
    CAD # = "124"
    KYD # = "136"
    CLP # = "152"
    CNX # = "158"
    COP # = "170"
    CRC # = "188"
    KMF # = "174"
    CDF # = "976"
    BAM # = "977"
    NIO # = "558"
    CUP # = "192"
    CZK # = "203"
    GMD # = "270"
    DKK # = "208"
    MKD # = "807"
    DJF # = "262"
    STD # = "678"
    NAD # = "516"
    DOP # = "214"
    VND # = "704"
    AMD # = "051"
    XCD # = "951"
    EGP # = "818"
    SVC # = "222"
    CVE # = "132"
    ETB # = "230"
    EUR # = "978"
    FKP # = "238"
    FJD # = "242"
    HUF # = "348"
    GHS # = "936"
    GIP # = "292"
    HTG # = "332"
    PYG # = "600"
    AWG # = "533"
    GNF # = "324"
    GYD # = "328"
    HKD # = "344"
    UAH # = "980"
    ISK # = "352"
    INR # = "356"
    IDR # = "360"
    IQD # = "368"
    JMD # = "388"
    JPY # = "392"
    JOD # = "400"
    KES # = "404"
    PGK # = "598"
    LAK # = "418"
    KWD # = "414"
    MWK # = "454"
    KGS # = "417"
    GEL # = "981"
    LBP # = "422"
    ALL # = "008"
    HNL # = "340"
    LSL # = "426"
    MDL # = "498"
    LRD # = "430"
    LYD # = "434"
    SZL # = "748"
    LTL # = "440"
    MGA # = "969"
    MYR # = "458"
    MVR # = "462"
    TMT # = "934"
    MUR # = "480"
    MXN # = "484"
    MAD # = "504"
    MZN # = "943"
    MMK # = "104"
    NGN # = "566"
    NPR # = "524"
    ANG # = "532"
    AFN # = "971"
    BGN # = "975"
    RUB # = "643"
    ILS # = "376"
    TWD # = "901"
    NZD # = "554"
    NOK # = "578"
    PEN # = "604"
    CNH # = "157"
    MRO # = "478"
    TOP # = "776"
    PKR # = "586"
    MOP # = "446"
    UYU # = "858"
    PHP # = "608"
    PLN # = "985"
    BWP # = "072"
    QAR # = "634"
    GTQ # = "320"
    ZAR # = "710"
    BRL # = "986"
    BYR # = "974"
    OMR # = "512"
    KHR # = "116"
    SAR # = "682"
    RON # = "946"
    RWF # = "646"
    KRW # = "410"
    RSD # = "941"
    SCR # = "690"
    SLE # = "925"
    SGD # = "702"
    SBD # = "090"
    SOS # = "706"
    SSP # = "728"
    LKR # = "144"
    SHP # = "654"
    SRD # = "968"
    SEK # = "752"
    CHF # = "756"
    TJS # = "972"
    BDT # = "050"
    WST # = "882"
    TZS # = "834"
    KZT # = "398"
    TTD # = "780"
    MNT # = "496"
    TND # = "788"
    TRY # = "949"
    AED # = "784"
    UGX # = "800"
    USD # = "840"
    UZS # = "860"
    VUV # = "548"
    YER # = "886"
    CNY # = "156"
    ZMW # = "967"
    noCurrency

const
  Currencies*: array[154, Currency] = [
    ("ALGERIAN DINAR", DZD, 2),
    ("ANGOLA KWANZA", AOA, 2),
    ("ARGENTINE PESO", ARS, 2),
    ("Australian Dollar", AUD, 2),
    ("AZERBAIJANIAN MANAT", AZN, 2),
    ("BAHAMIAN DOLLAR", BSD, 2),
    ("BAHRAINI DINAR", BHD, 3),
    ("BAHT", THB, 2),
    ("BALBOA", PAB, 2),
    ("BARBADOS DOLLAR", BBD, 2),
    ("BELARUSIAN RUBLE", BYN, 2),
    ("BELIZE DOLLAR", BZD, 2),
    ("BERMUDAN DOLLAR", BMD, 2),
    ("BHUTANESE NGULTRUM", BTN, 2),
    ("BOLIVAR FUERTE", VEF, 2),
    ("BOLIVAR FUERTE", ESA, 2),
    ("BOLIVIAN", BOB, 2),
    ("British Pound Sterling", GBP, 2),
    ("BRUNEI DOLLAR", BND, 2),
    ("BURUNDI FRANC", BIF, 0),
    ("C.F.A. FRANC", XPF, 0),
    ("C.F.A. FRANC BCEAO", XOF, 0),
    ("C.F.A. FRANC BEAC", XAF, 0),
    ("Canadian Dollar", CAD, 2),
    ("CAYMAN ISL DOLLAR", KYD, 2),
    ("CHILEAN PESO", CLP, 2),
    ("CHINESE RENMINBI", CNX, 2),
    ("COLOMBIAN PESO", COP, 2),
    ("COLON", CRC, 2),
    ("COMOROS FRANC", KMF, 0),
    ("CONGOLESE FRANC", CDF, 2),
    ("CONVERTIBLE MARK", BAM, 2),
    ("CORDOBA ORO", NIO, 2),
    ("CUBAN PESO", CUP, 2),
    ("CZECH KORUNA", CZK, 2),
    ("DA LASI", GMD, 2),
    ("Danish Krone", DKK, 2),
    ("DENAR", MKD, 2),
    ("DJIBOUTI FRANC", DJF, 0),
    ("DOBRA", STD, 2),
    ("DOLLAR", NAD, 2),
    ("DOMINICAN PESO", DOP, 2),
    ("DONG", VND, 0),
    ("DRAM", AMD, 2),
    ("E. CARIBBEAN D LR", XCD, 2),
    ("Egyptian pound", EGP, 2),
    ("EL SALVADOR COLON", SVC, 2),
    ("ESCUDO", CVE, 2),
    ("ETHIOPIAN BIRR", ETB, 2),
    ("Euro", EUR, 2),
    ("FALKLAND ISL POUND", FKP, 2),
    ("FIJI DOLLAR", FJD, 2),
    ("FORINT", HUF, 2),
    ("GHANA CEDI", GHS, 2),
    ("GIBRALTAR POUND", GIP, 2),
    ("GOURDE", HTG, 2),
    ("GUARANI", PYG, 0),
    ("GUILDER", AWG, 2),
    ("GUINEA FRANC", GNF, 0),
    ("GUYANA DOLLAR", GYD, 2),
    ("HONG-KONG DOLLAR", HKD, 2),
    ("HRYVNIA", UAH, 2),
    ("ICELAND KRONA", ISK, 0),
    ("INDIAN RUPEE", INR, 2),
    ("Indonesian Rupiah", IDR, 2),
    ("IRAQI DINAR", IQD, 3),
    ("JAMAICAN DOLLAR", JMD, 2),
    ("Japanese Yen", JPY, 0),
    ("JORDANIAN DINAR", JOD, 3),
    ("KENYAN SHILLING", KES, 2),
    ("KINA", PGK, 2),
    ("KIP", LAK, 2),
    ("KUWAITI DINAR", KWD, 3),
    ("KWACHA", MWK, 2),
    ("KYRGYZSTAN SOM", KGS, 2),
    ("LARI", GEL, 2),
    ("LEBANESE POUND", LBP, 2),
    ("LEK", ALL, 2),
    ("LEMPIRA", HNL, 2),
    ("LESOTHO LOTI", LSL, 2),
    ("LEU", MDL, 2),
    ("LIBERIA DOLLAR", LRD, 2),
    ("LIBYAN DINAR", LYD, 3),
    ("LILANGENI", SZL, 2),
    ("LITHUANIA", LTL, 2),
    ("MALAGASY ARIARY", MGA, 2),
    ("Malaysian Ringits", MYR, 2),
    ("MALDIVE RUFIYAA", MVR, 2),
    ("MANAT", TMT, 2),
    ("MAURITIUS RUPEE", MUR, 2),
    ("Mexican Peso", MXN, 2),
    ("MOROCCAN DIRHAM", MAD, 2),
    ("MOZAMBIQUE METICAL", MZN, 2),
    ("MYANMAR KYAT", MMK, 2),
    ("NAIRA", NGN, 2),
    ("NEPALESE RUPEE", NPR, 2),
    ("NETH. ANT. GUILDER", ANG, 2),
    ("NEW AFGHANI", AFN, 2),
    ("NEW BULGARIAN LEV", BGN, 2),
    ("NEW RUBLE", RUB, 2),
    ("NEW SHEKEL", ILS, 2),
    ("NEW TAIWAN DOLLAR", TWD, 2),
    ("New Zealand Dollar", NZD, 2),
    ("Norwegian Krone", NOK, 2),
    ("NUEVO SOL", PEN, 2),
    ("OFFSHORE RENMINBI", CNH, 2),
    ("OUGUIYA", MRO, 2),
    ("PA ANGA", TOP, 2),
    ("PAKISTAN RUPEE", PKR, 2),
    ("PATACA", MOP, 2),
    ("PESO URUGUAYO", UYU, 2),
    ("PHILIPPINE PESO", PHP, 2),
    ("Polish Zloty", PLN, 2),
    ("PULA", BWP, 2),
    ("QATARI RIYAL", QAR, 2),
    ("QUETZAL", GTQ, 2),
    ("RAND", ZAR, 2),
    ("REAL", BRL, 2),
    ("REVAL. BELARUS RUBLE", BYR, 0),
    ("RIAL", OMR, 3),
    ("RIEL", KHR, 2),
    ("RIYAL", SAR, 2),
    ("ROMANIAN LEU", RON, 2),
    ("RWANDA FRANC", RWF, 0),
    ("S. KOREAN WON", KRW, 0),
    ("SERBIAN DINAR", RSD, 2),
    ("SEYCHELLES RUPEE", SCR, 2),
    ("Sierra Leonean Leone", SLE, 2),
    ("Singapore Dollar", SGD, 2),
    ("SOLOMON ISL DOLLAR", SBD, 2),
    ("SOMALI SHILLING", SOS, 2),
    ("SOUTH SUDAN POUND", SSP, 2),
    ("SRI LANKA RUPEE", LKR, 2),
    ("ST. HELENA POUND", SHP, 2),
    ("SURINAME DOLLAR", SRD, 2),
    ("Swedish Krona", SEK, 2),
    ("Swiss Franc", CHF, 2),
    ("TAJIKISTAN SOMONI", TJS, 2),
    ("TAKA", BDT, 2),
    ("TALA", WST, 2),
    ("TANZANIAN SHILLING", TZS, 2),
    ("TENGE", KZT, 2),
    ("TRIN. & TOB. DOLLAR", TTD, 2),
    ("TUGRIK", MNT, 2),
    ("TUNISIAN DINAR", TND, 3),
    ("TURKISH LIRA", TRY, 2),
    ("UAE DIRHAM", AED, 2),
    ("UGANDA SHILLING", UGX, 2),
    ("US Dollar", USD, 2),
    ("UZBEKISTAN SUM", UZS, 2),
    ("VATU", VUV, 0),
    ("YEMENI RIAL", YER, 2),
    ("YUAN RENMINBI", CNY, 2),
    ("ZAMBIAN KWACHA", ZMW, 2)
  ]