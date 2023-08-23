# Package

version       = "0.1.0"
author        = "Supranim"
description   = "Create, calculate and format money in Nim language"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 1.6.12"
requires "bigints"

task dev, "development build":
  exec "nim c --out:./bin/money src/money.nim"