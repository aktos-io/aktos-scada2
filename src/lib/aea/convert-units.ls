require! 'prelude-ls': {find, filter, empty}

function ConversionException message
    @message = message
    @name = "ConversionException"

function ConversionTestException message
    @message = message
    @name = "ConversionTestException"

export function convert-units params
    {in: coeff, from: source, to: target, direction: direction} = params
    direction = \from-derived-to-base unless direction

    try
        throw 'direction is not derived to base' if direction isnt \from-derived-to-base
        sources = filter (.derived-unit is source), coeff
        throw new ConversionException "source unit #{source} is not found!" if empty sources
        for unit in sources
            if unit.base-unit is target
                return unit.amount
            else
                try return unit.amount * convert-units {in: coeff, from: unit.base-unit, to: target, direction: direction}
        throw new ConversionException "target unit #{target} is not found!"

    catch
        direction = \base-to-derived
        sources = filter (.base-unit is source), coeff
        throw new ConversionException "source unit #{source} is not found!" if empty sources
        for unit in sources
            if unit.derived-unit is target
                return 1 / unit.amount
            else
                try return (convert-units {in: coeff, from: unit.derived-unit, to: target, direction: direction}) / unit.amount

        throw new ConversionException "target unit #{target} is not found!"

test-units =
    * derived-unit: \palet
      amount: 4
      base-unit: \koli
    * derived-unit: \koli
      amount: 6
      base-unit: \paket
    * derived-unit: \koli
      amount: 12
      base-unit: \desi
    * derived-unit: \koli
      amount: 24
      base-unit: \lira
    * derived-unit: \paket
      amount: 10
      base-unit: \gr
    * derived-unit: \gr
      amount: 1000
      base-unit: \mg

test-cases =
    * calculated: {in: test-units, from: \koli, to: \gr}
      expected: 60
    * calculated: {in: test-units, from: \koli, to: \mg}
      expected: 60_000
    * calculated: {in: test-units, from: \desi, to: \koli}
      expected: 1 / 12
    * calculated: {in: test-units, from: \desi, to: \palet}
      expected: 1 / 12 / 4
    * calculated: {in: test-units, from: \koli, to: \koli}
      expected: 1
    * calculated: {in: test-units, from: \paket, to: \paket}
      expected: 1

exceptional-cases =
    * {in: test-units, from: \maket, to: \paket}
    * {in: test-units, from: \paket, to: \maket}

console.log "Begin CONVERT_UNITS testing..."
for test in test-cases
    test-name = "from #{test.calculated.from} to #{test.calculated.to}"
    if test.expected isnt convert-units test.calculated
        throw "test failed while converting #{test-name}, expected: #{test.expected}, calculated: #{convert-units test.calculated}"
    else
        console.log "test passed: #{test-name}"

# expected throwing exception for some test cases...
for test in exceptional-cases
    test-name = "from #{test.from} to #{test.to}"
    try
        x = convert-units test
        throw new ConversionTestException """test failed for #{test-name}
            (expected throwing an exception, but returned #{x} instead)
            """
    catch
        if e.name is \ConversionException
            console.log "test passed: #{test-name}, message: #{e.message}"
        else
            throw e.message

console.log "End of CONVERT_UNITS testing..."
