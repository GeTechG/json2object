package tests;

import json2object.Error;
import json2object.JsonParser;
import json2object.JsonWriter;
import json2object.utils.JsonSchemaWriter;
import utest.Assert;

typedef RectShape = {
	var width:Float;
	var height:Float;
}

typedef CircleShape = {
	/** The radius */
	var radius:Float;
	@:optional var label:String;
}

/** A shape */
@:tagged("kind")
enum Shape {
	/** A rectangle */
	@:default({width: 32, height: 32}) rect(s:RectShape);
	@:default({radius: 16}) circle(s:CircleShape);
	empty(s:{});
}

typedef Scene = {
	var shape:Shape;
	@:optional var shapes:Array<Shape>;
}

typedef MetaShape = {
	@:alias("w") var width:Int;
	@:jignored @:optional var cache:Int;
	@:optional @:default(1) var scale:Int;
}

@:tagged("type")
enum WithMeta {
	sized(s:MetaShape);
}

@:tagged("op")
enum Formula<T> {
	lit(s:{value:T});
	add(s:{left:Formula<T>, right:Formula<T>});
}

class TaggedEnumTest implements utest.ITest
{
	public function new () {}

	function pos (min:Int, max:Int) : json2object.Position {
		return {file:"", lines:[{number:1, start:min, end:max}], min:min, max:max};
	}

	public function testRead ()
	{
		var parser = new JsonParser<Shape>();
		var data = parser.fromJson('{"kind": "rect", "width": 32, "height": 16}');
		Assert.same([], parser.errors);
		Assert.same(rect({width: 32, height: 16}), data);

		data = parser.fromJson('{"width": 32, "kind": "rect", "height": 16}');
		Assert.same([], parser.errors);
		Assert.same(rect({width: 32, height: 16}), data);

		data = parser.fromJson('{"radius": 3, "kind": "circle"}');
		Assert.same([], parser.errors);
		Assert.same(circle({radius: 3, label: null}), data);

		data = parser.fromJson('{"kind": "circle", "radius": 3, "label": "c"}');
		Assert.same([], parser.errors);
		Assert.same(circle({radius: 3, label: "c"}), data);

		data = parser.fromJson('{"kind": "empty"}');
		Assert.same([], parser.errors);
		Assert.same(empty({}), data);

		data = parser.fromJson('null');
		Assert.same([], parser.errors);
		Assert.isNull(data);
	}

	public function testReadTagErrors ()
	{
		var parser = new JsonParser<Shape>();
		var expected = "Shape.kind (rect | circle | empty)";

		var data = parser.fromJson('{"kind": "square"}');
		Assert.same([IncorrectEnumValue("square", expected, pos(10, 18))], parser.errors);
		Assert.isNull(data);

		data = parser.fromJson('{"width": 1}');
		Assert.same([IncorrectType("kind", expected, pos(1, 13))], parser.errors);
		Assert.isNull(data);

		data = parser.fromJson('{"kind": 1}');
		Assert.same([IncorrectType("kind", expected, pos(10, 11))], parser.errors);
		Assert.isNull(data);

		data = parser.fromJson('"rect"');
		Assert.same([IncorrectType("", "tests.Shape", pos(1, 7))], parser.errors);
		Assert.isNull(data);

		data = parser.fromJson('[]');
		Assert.same([IncorrectType("", "tests.Shape", pos(1, 3))], parser.errors);
		Assert.isNull(data);

		Assert.equals("line1: characters 10-18 : Identifier 'square' isn't part of 'Shape.kind (rect | circle | empty)'",
			json2object.ErrorUtils.convertError(IncorrectEnumValue("square", expected, pos(10, 18))));
	}

	public function testReadBranchErrors ()
	{
		var parser = new JsonParser<Shape>();

		var data = parser.fromJson('{"kind": "circle", "radius": 3, "width": 1}');
		Assert.same([UnknownVariable("width", pos(33, 40))], parser.errors);

		data = parser.fromJson('{"kind": "rect", "width": 1}');
		Assert.same([UninitializedVariable("height", pos(29, 29))], parser.errors);

		data = parser.fromJson('{"kind": "rect", "width": 1, "height": "a"}');
		Assert.same([IncorrectType("height", "Float", pos(40, 43)), UninitializedVariable("height", pos(44, 44))], parser.errors);

		var parser = new JsonParser<Scene>();
		var scene = parser.fromJson('{"shape": {"kind": "square"}}');
		Assert.equals(2, parser.errors.length);
		Assert.isNull(scene.shape);

		scene = parser.fromJson('{"shapes": [{"kind": "rect", "width": 1, "height": 2}, {"kind": "square"}, {"kind": "circle", "radius": 1}], "shape": {"kind": "empty"}}');
		Assert.equals(1, parser.errors.length);
		Assert.same([rect({width: 1, height: 2}), circle({radius: 1, label: null})], scene.shapes);
		Assert.same(empty({}), scene.shape);
	}

	public function testReadFieldMeta ()
	{
		var parser = new JsonParser<WithMeta>();
		var data = parser.fromJson('{"type": "sized", "w": 3}');
		Assert.same([], parser.errors);
		switch (data) {
			case sized(s):
				Assert.equals(3, s.width);
				Assert.equals(1, s.scale);
			default:
				Assert.fail();
		}

		parser.fromJson('{"type": "sized", "w": 3, "cache": 1}');
		Assert.equals(1, parser.errors.length);
		Assert.isTrue(parser.errors[0].match(UnknownVariable("cache", _)));
	}

	public function testWrite ()
	{
		var writer = new JsonWriter<Shape>();
		Assert.equals('{"kind": "rect","width": 32,"height": 16}', writer.write(rect({width: 32, height: 16})));
		Assert.equals('{"kind": "circle","radius": 3,"label": null}', writer.write(circle({radius: 3})));
		Assert.equals('{"kind": "empty"}', writer.write(empty({})));
		Assert.equals('null', writer.write(null));
		Assert.equals('{\n  "kind": "rect",\n  "width": 1,\n  "height": 2\n}', writer.write(rect({width: 1, height: 2}), "  "));

		var writer = new JsonWriter<Shape>(true);
		Assert.equals('{"kind": "circle","radius": 3}', writer.write(circle({radius: 3})));

		var writer = new JsonWriter<WithMeta>();
		Assert.equals('{"type": "sized","w": 3,"scale": 1}', writer.write(sized({width: 3, cache: 7, scale: 1})));

		var writer = new JsonWriter<Scene>();
		Assert.equals('{\n  "shape": {\n    "kind": "empty"\n  },\n  "shapes": [\n    {\n      "kind": "rect",\n      "width": 1,\n      "height": 2\n    }\n  ]\n}',
			writer.write({shape: empty({}), shapes: [rect({width: 1, height: 2})]}, "  "));
	}

	public function testRoundtrip ()
	{
		var parser = new JsonParser<Scene>();
		var writer = new JsonWriter<Scene>();
		var scene:Scene = {shape: circle({radius: 2, label: "x"}), shapes: [rect({width: 1, height: 2}), empty({}), circle({radius: 1, label: null})]};
		Assert.same(scene, parser.fromJson(writer.write(scene)));
		Assert.same([], parser.errors);
		Assert.same(scene, parser.fromJson(writer.write(scene, "\t")));
		Assert.same([], parser.errors);
	}

	public function testGenericRecursive ()
	{
		var parser = new JsonParser<Formula<Int>>();
		var writer = new JsonWriter<Formula<Int>>();
		var e = add({left: lit({value: 1}), right: add({left: lit({value: 2}), right: lit({value: 3})})});
		var json = writer.write(e);
		Assert.equals('{"op": "add","left": {"op": "lit","value": 1},"right": {"op": "add","left": {"op": "lit","value": 2},"right": {"op": "lit","value": 3}}}', json);
		Assert.same(e, parser.fromJson(json));
		Assert.same([], parser.errors);

		parser.fromJson('{"op": "lit", "value": "a"}');
		Assert.isTrue(parser.errors[0].match(IncorrectType("value", "Int", _)));
	}

	public function testUntagged ()
	{
		var writer = new JsonWriter<tests.EnumTest.Color>();
		Assert.equals('{"None": {"r": {"a": 1}}}', writer.write(None({a: 1})));
	}

	#if !lua
	public function testSchema ()
	{
		var schema = new JsonSchemaWriter<Shape>().schema;
		var oracle = '{"$$schema": "http://json-schema.org/draft-07/schema#","$$ref": "#/definitions/tests.Shape","definitions": {"tests.Shape": {"description": "A shape","discriminator": {"propertyName": "kind"},"oneOf": [{"type": "object","additionalProperties": false,"description": "A rectangle","default": {"kind": "rect","width": 32,"height": 32},"properties": {"kind": {"const": "rect"},"width": {"type": "number"},"height": {"type": "number"}},"required": ["height","kind","width"]},{"type": "object","additionalProperties": false,"default": {"kind": "circle","radius": 16},"properties": {"kind": {"const": "circle"},"radius": {"type": "number","description": "The radius"},"label": {"type": "string"}},"required": ["kind","radius"]},{"type": "object","additionalProperties": false,"properties": {"kind": {"const": "empty"}},"required": ["kind"]}]}}}';
		Assert.isTrue(JsonComparator.areSame(oracle, schema), schema);

		var schema = new JsonSchemaWriter<WithMeta>().schema;
		var oracle = '{"$$schema": "http://json-schema.org/draft-07/schema#","$$ref": "#/definitions/tests.WithMeta","definitions": {"tests.WithMeta": {"discriminator": {"propertyName": "type"},"oneOf": [{"type": "object","additionalProperties": false,"properties": {"type": {"const": "sized"},"w": {"type": "integer"},"scale": {"type": "integer","default": 1}},"required": ["type","w"]}]}}}';
		Assert.isTrue(JsonComparator.areSame(oracle, schema), schema);

		var schema = new JsonSchemaWriter<Formula<Int>>().schema;
		var oracle = '{"$$schema": "http://json-schema.org/draft-07/schema#","$$ref": "#/definitions/tests.Formula<Int>","definitions": {"tests.Formula<Int>": {"discriminator": {"propertyName": "op"},"oneOf": [{"type": "object","additionalProperties": false,"properties": {"op": {"const": "lit"},"value": {"type": "integer"}},"required": ["op","value"]},{"type": "object","additionalProperties": false,"properties": {"op": {"const": "add"},"left": {"$$ref": "#/definitions/tests.Formula<Int>"},"right": {"$$ref": "#/definitions/tests.Formula<Int>"}},"required": ["left","op","right"]}]}}}';
		Assert.isTrue(JsonComparator.areSame(oracle, schema), schema);
	}
	#end

	public function testBuildErrors ()
	{
		Assert.stringContains("json2object: @:tagged enum NoArgument: constructor a must take exactly one argument, an anonymous structure",
			BuildError.of(new json2object.JsonParser<tests.TaggedEnumErrors.NoArgument>()));
		Assert.stringContains("json2object: @:tagged enum TwoArguments: constructor a must take exactly one argument, an anonymous structure",
			BuildError.of(new json2object.JsonWriter<tests.TaggedEnumErrors.TwoArguments>()));
		Assert.stringContains("json2object: @:tagged enum NotStructure: constructor a must take an anonymous structure, not Int",
			BuildError.of(new json2object.utils.JsonSchemaWriter<tests.TaggedEnumErrors.NotStructure>()));
		Assert.stringContains('json2object: @:tagged enum TagField: constructor a declares a field kind named as the tag "kind"',
			BuildError.of(new json2object.JsonParser<tests.TaggedEnumErrors.TagField>()));
		Assert.stringContains('json2object: @:tagged enum TagAlias: constructor a declares a field k named as the tag "kind"',
			BuildError.of(new json2object.JsonWriter<tests.TaggedEnumErrors.TagAlias>()));
		Assert.stringContains('json2object: @:tagged enum TagNotString: the argument of @:tagged must be one string identifier, like @:tagged("kind")',
			BuildError.of(new json2object.JsonParser<tests.TaggedEnumErrors.TagNotString>()));
		Assert.stringContains('json2object: @:tagged enum TagNotIdentifier: the argument of @:tagged must be one string identifier, like @:tagged("kind")',
			BuildError.of(new json2object.JsonParser<tests.TaggedEnumErrors.TagNotIdentifier>()));
	}
}
