## REMOVED Requirements

### Requirement: Reading a tagged enum
**Reason**: Its text exceeded 500 characters and stated four behaviours.
**Migration**: Split without change of behaviour into "A tagged enum is read as the record of its branch", "A tagged enum branch is closed", "A bad tag names the tag and the constructors" and "A tagged enum is read from an object".

## ADDED Requirements

### Requirement: A tagged enum is read as the record of its branch
A `JsonParser` of a tagged enum SHALL read a JSON object whose tag field, in any position, is a string naming a constructor, and read the other fields as the record of that constructor's branch, as any record is read: a missing required field is reported as uninitialized, an `@:optional` field may be absent, field metadata applies.

#### Scenario: Any field order
- **WHEN** `{"width": 32, "kind": "rect", "height": 16}` is parsed as `Shape`
- **THEN** no error is reported and the value is `rect({width: 32, height: 16})`

### Requirement: A tagged enum branch is closed
A `JsonParser` of a tagged enum SHALL report a field that the selected branch does not declare as an unknown variable.

#### Scenario: A field of another branch
- **WHEN** `{"kind": "circle", "radius": 3, "width": 1}` is parsed as `Shape`
- **THEN** an `UnknownVariable("width", _)` error is reported

### Requirement: A bad tag names the tag and the constructors
A `JsonParser` of a tagged enum SHALL report a missing tag or a tag that is not a string as an incorrect type of the tag variable, and a string that names no constructor as an incorrect enum value; both errors SHALL name the tag and the constructor names (`Shape.kind (rect | circle)`), and the value is then `null`.

#### Scenario: An unknown constructor name
- **WHEN** `{"kind": "square"}` is parsed as `Shape`
- **THEN** an `IncorrectEnumValue("square", "Shape.kind (rect | circle)", _)` error is reported and the value is `null`

#### Scenario: A missing tag
- **WHEN** `{"width": 1}` is parsed as `Shape`
- **THEN** an `IncorrectType("kind", "Shape.kind (rect | circle)", _)` error is reported and the value is `null`

#### Scenario: A tag that is not a string
- **WHEN** `{"kind": 1}` is parsed as `Shape`
- **THEN** an `IncorrectType("kind", "Shape.kind (rect | circle)", _)` error is reported and the value is `null`

### Requirement: A tagged enum is read from an object
A `JsonParser` of a tagged enum SHALL report a JSON value that is neither an object nor `null` as an incorrect type.

#### Scenario: A string instead of an object
- **WHEN** `"rect"` is parsed as `Shape`
- **THEN** an `IncorrectType("", "Shape", _)` error is reported and the value is `null`
