# json2object - Type safe Haxe/JSON (de)serializer

[![CI status](https://github.com/elnabo/json2object/actions/workflows/main.yaml/badge.svg)](https://github.com/elnabo/json2object/actions/workflows/main.yaml)

This library uses macro and a typed position aware JSON parsing (hxjsonast : <https://github.com/nadako/hxjsonast/>) to create json parser and writer from and to every supported type.

Incorrect json files or mismatch between the object and the json will yield errors or exceptions, with information on the position of the problematic parts.

Requires at least haxe 3.4.1.

## Installation

```
haxelib install json2object
```

## Usage

### Using the parser
```haxe
var parser = new json2object.JsonParser<Cls>(); // Creating a parser for Cls class
parser.fromJson(jsonString, filename); // Parsing a string. A filename is specified for errors management
var data:Cls = parser.value; // Access the parsed class
var errors:Array<json2object.Error> = parser.errors; // Access the potential errors yield during the parsing
```

It is also possible to populate an existing Array with the errors
```haxe
var errors = new Array<json2object.Error>();
var data:Cls = new json2object.JsonParser<Cls>(errors).fromJson(jsonString, filename);
```

To print the errors, you can do
```haxe
trace(json2object.ErrorUtils.convertErrorArray(parser.errors));
```

### Using the writer
```haxe
var value:Cls;
var writer = new json2object.JsonWriter<Cls>(); // Creating a writer for Cls class
var json = writer.write(value);
```

The `write` function accepts an optional `String` parameter for indenting the json file.

### Using the JsonSchema writer
```haxe
var schema = new json2object.utils.JsonSchemaWriter<Cls>().schema;
```

The constructor accepts an optional `String` parameter for indenting the schema. The generated schema follow null-safety rules.

An other parser `json2object.utils.special.VSCodeSchemaWriter` has been introduced in 3.6.3 to produce a schema with some non standard properties used by VScode.

### Constraints in the parsing

- Variables defined with the `@:jignored` metadata will be ignored by the parser.
- Variables defined with the `@:optional` metadata won't trigger errors if missing.

### Supported types

- Basic types (`Int`, `Float`, `Bool`, `String`)
- `Null` and `Array`
- `Map` with `Int` or `String` keys
- Class (generics are supported)
- Anonymous structure
- Typedef alias of supported types
- Enum values
- Abstract over a supported type
- Abstract enum of String, Int, Float or Bool
- Enum marked `@:tagged`, as a flat object with a tag field (see below)

### Tagged enums

An enum marked `@:tagged("<tag>")` is read and written as a single flat object: the field `<tag>` holds the constructor name, and the fields of that constructor's argument sit beside it.
```haxe
@:tagged("kind")
enum Shape {
	rect(s:{width:Float, height:Float});
	circle(s:{radius:Float, ?label:String});
}
```
`Shape.rect({width: 32, height: 16})` is written as
```json
{"kind": "rect", "width": 32, "height": 16}
```
The writer puts the tag first. The parser accepts it at any position, and reads the other fields the way it reads any anonymous structure: a missing required field is an error, an `@:optional` field may be left out, and `@:alias`, `@:default` and `@:jignored` apply. Each constructor's object is closed, so a field that the selected constructor does not declare is reported as an unknown variable. A missing tag, or one that is not a string, gives an `IncorrectType` error; a tag that names no constructor gives an `IncorrectEnumValue` error. Both errors list the possible tags (`Shape.kind (rect | circle)`), and the parsed value is then `null`.

Constraints, checked at compile time (a violation fails the build with a message naming the enum and the constructor):
- the argument of `@:tagged` is a single string constant that is a valid identifier;
- every constructor takes exactly one argument, an anonymous structure (or a typedef of one);
- no field of that structure is named (or `@:alias`ed) as the tag.

The `JsonSchemaWriter` describes a tagged enum as a `oneOf` with one closed object (`"additionalProperties": false`) per constructor. In each object the tag is required and has a `const` value, the constructor name. The `oneOf` comes with an OpenAPI-style `discriminator`:
```json
{
	"discriminator": {"propertyName": "kind"},
	"oneOf": [
		{"type": "object", "additionalProperties": false,
		 "properties": {"kind": {"const": "rect"}, "width": {"type": "number"}, "height": {"type": "number"}},
		 "required": ["height", "kind", "width"]},
		{"type": "object", "additionalProperties": false,
		 "properties": {"kind": {"const": "circle"}, "radius": {"type": "number"}, "label": {"type": "string"}},
		 "required": ["kind", "radius"]}
	]
}
```
A `@:default(...)` on a constructor, giving the value of its argument, becomes the `default` of that constructor's object in the schema.

### Other

- As of version 2.4.0, the parser fields `warnings` and `object` have been replaced by `errors` and `value` respectively. Since version `3.6.1`, previous notations are no longer supported.

- Anonymous structure variables can be defined to be loaded with a default value if none is specified in the json using the `@:default` metadata
```haxe
typedef Struct = {
	var normal:String;

	@:default(new Map<Int, String>())
	var map:Map<Int,String>;

	@:default(-1) @:optional
	var id:Int;
}
```

- `@:default(auto)` will, by default, initialize each field of the anonymous structure / object to its default value. No effect on non Structure/Object variables.

- Variable defined as `(default, null)` may have unexpected behaviour on some `extern` classes.

- You can alias a field from the json into another name, for instance if the field name isn't a valid haxe identifier.
```haxe
typedef Struct = {
	@:alias("public") var isPublic:Bool;
}
class Main {
	static function main() {
		var parser = new JsonParser<Struct>();
		var data = parser.fromJson('{"public": true }', "file.json");
		trace(data.isPublic);
	}
}
```
If multiple alias metadatas are on the variable only the last one is taken into account.

- As of version 3.4.0, private classes can be parsed except on the CS, Java and HL targets.

- As of version 3.7.0, it is possible to add field or class specific parser/writer to object using the `@:jcustomparse` / `@:jcustomwrite` meta. This increase the type coverage of json parsing/writing. Those custom parser/writer can also be applied to the entire class.
	- The custom writer receive a single parameter, the value to stringify
	- The custom parser receive two parameters: the corresponding json, encoded in a `hxjsonast.Json` instance, and the name of the field being parsed.
	- The `@:jcustom*` metadatas require the fully quallified path to the custom function, for instance `pack.TheClass.fn` or `pack.TheModule.TheClass.fn`
	- As of version 3.8.0 throwing an exception in a custom parser will be available in `parser.errors` in the `CustomFunctionException` member.
```haxe
class Object {
	@:jcustomparse(Object.customParse)
	@:jcustomwrite(Object.customWrite)
	public var value:Date;

	public function new() {}

	public static function customWrite(v:Date):String {
		return v.getTime() + '';
	}

	public static function customParse(val:Json, name:String):Date {
		return switch (val.value) {
			case JString(s):
				Date.fromString(s);
			case JNumber(s):
				Date.fromTime(Std.parseFloat(s));
			default:
				null;

		}
	}
}
```

## Example

With an anonymous structure:
```haxe
import json2object.JsonParser;

class Main {
	static function main() {
		var parser = new JsonParser<{ name : String, quantity : Int }>();
		var data = parser.fromJson('{"name": "computer", "quantity": 2 }', "file.json");
		trace(data.name, data.quantity);
	}
}
```

A more complex example with a class and subclass:
```haxe
import json2object.JsonParser;

class Data {
	public var a:String;
	public var b:SubData;
	public var d:Array<Int>;
	public var e:Array<Map<String, String>>;
	public var f:Array<Float>;
	public var g:Array<Bool>;
	@:jignored
	public var h:Math;
}

class SubData {
	public var c:String;
}

class Main {
	static function main() {
		var parser = new JsonParser<Data>();
		var data = parser.fromJson('{"a": "a", "b": {"c": "c"}, "e": [ { "c": "1" }, { "c": "2" } ], "f": [], "g": [ true ] }', "file.json");
		var errors = parser.errors;

		trace(data.a);
		trace(data.b.c);

		for (e in data.e) {
			trace(e.get("c"));
		}

		trace(data.e[0].get("c");
		trace(data.f.length);

		for (g in data.g) {
			trace(data.g.length);
		}

		for (e in errors) {
			switch(e) {
				case IncorrectType(variable, expected, pos):
				case UninitializedVariable(variable, pos):
				case UnknownVariable(variable, pos):
				default:
			}
		}
	}
}
```
