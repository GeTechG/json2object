package tests;

// Malformed tagged enums: each fails the build once a parser, writer or schema of it is built (see TaggedEnumTest.testBuildErrors).

@:tagged("kind") enum NoArgument { a; }
@:tagged("kind") enum TwoArguments { a(x:{v:Int}, y:{v:Int}); }
@:tagged("kind") enum NotStructure { a(x:Int); }
@:tagged("kind") enum TagField { a(x:{kind:String}); }
@:tagged("kind") enum TagAlias { a(x:{@:alias("kind") var k:String;}); }
@:tagged(kind) enum TagNotString { a(x:{v:Int}); }
@:tagged("a b") enum TagNotIdentifier { a(x:{v:Int}); }
