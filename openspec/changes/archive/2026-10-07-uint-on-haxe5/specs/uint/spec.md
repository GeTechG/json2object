## ADDED Requirements

### Requirement: Unsigned integers are read as unsigned
A `JsonParser` of `UInt` (the abstract `UInt` on Haxe 4, the typedef to `haxe.UInt32` on Haxe 5) or of `haxe.UInt32` SHALL read a JSON integer in the range 0 to 4294967295 as that value, without an error. A JSON number that is not an integer SHALL be reported as an incorrect type, and the value of a non-nullable target SHALL then be `0`.

#### Scenario: A value above the signed range
- **WHEN** `2147483648` is parsed as `UInt`
- **THEN** the parser reports no error and the value is 2147483648

#### Scenario: A number with a fraction
- **WHEN** `2147483648.54` is parsed as `UInt`
- **THEN** the parser reports one error and the value is `0`

### Requirement: Unsigned integers are written as unsigned
A `JsonWriter` of `UInt` or of `haxe.UInt32` SHALL write the value as a non-negative decimal number, on every supported compiler.

#### Scenario: A value above the signed range
- **WHEN** the `UInt` value 2147483648 is written
- **THEN** the output is `2147483648`
