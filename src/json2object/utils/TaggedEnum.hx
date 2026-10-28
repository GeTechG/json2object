package json2object.utils;

#if !macro
class TaggedEnum {}
#else
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.TypeTools;

/**
 * A constructor of a tagged enum: its name and the record of its single argument.
 */
typedef TaggedBranch = {
	var name:String;
	var construct:EnumField;
	/** The argument type, with the enum's type parameters applied. */
	var type:Type;
	/** The fields of the record, in declaration order. */
	var fields:Array<ClassField>;
}

/**
 * An enum marked `@:tagged("<tag>")`: a flat object whose field `<tag>` names the constructor,
 * the other fields being those of the constructor's single anonymous structure argument.
 */
class TaggedEnum {
	static var IDENTIFIER = ~/^[A-Za-z_][A-Za-z0-9_]*$/;

	/**
	 * The tag of `t`, or null if it is not tagged. Fails the build if the `@:tagged` argument is not one string identifier.
	 */
	public static function tagOf(t:EnumType):Null<String> {
		var metas = t.meta.extract(":tagged");
		if (metas.length == 0) {
			return null;
		}
		var meta = metas[0];
		if (metas.length == 1 && meta.params != null && meta.params.length == 1) {
			switch (meta.params[0].expr) {
				case EConst(CString(s)) if (IDENTIFIER.match(s)):
					return s;
				default:
			}
		}
		Context.fatalError('json2object: @:tagged enum ${t.name}: the argument of @:tagged must be one string identifier, like @:tagged("kind")', meta.pos);
		return null;
	}

	/**
	 * The branches of the tagged enum `t` applied to `params`, in declaration order.
	 * Fails the build on a constructor that does not take exactly one anonymous structure argument,
	 * or whose record declares a field named `tag`.
	 */
	public static function branches(t:EnumType, params:Array<Type>, tag:String):Array<TaggedBranch> {
		var result = [];
		for (n in t.names) {
			var construct = t.constructs.get(n);
			var fail = function (reason:String) {
				Context.fatalError('json2object: @:tagged enum ${t.name}: constructor $n $reason', construct.pos);
			}
			var args = switch (construct.type) {
				case TFun(args, _): args;
				default: [];
			}
			if (args.length != 1) {
				fail('must take exactly one argument, an anonymous structure');
			}
			var type = args[0].t.applyTypeParameters(t.params, params);
			var fields = switch (Context.follow(type)) {
				case TAnonymous(_.get() => a): a.fields.copy();
				default:
					fail('must take an anonymous structure, not ${type.toString()}');
					null;
			}
			for (field in fields) {
				var names = [field.name];
				for (m in field.meta.extract(":alias")) {
					if (m.params != null && m.params.length == 1) {
						switch (m.params[0].expr) {
							case EConst(CString(s)): names.push(s);
							default:
						}
					}
				}
				if (names.indexOf(tag) != -1) {
					fail('declares a field ${field.name} named as the tag "$tag"');
				}
			}
			fields.sort(function (a, b) return Context.getPosInfos(a.pos).min - Context.getPosInfos(b.pos).min);
			result.push({name: n, construct: construct, type: type, fields: fields});
		}
		return result;
	}

	/**
	 * How the tag and its allowed values are named in a parsing error: `Shape.kind (rect | circle)`.
	 */
	public static function expected(t:EnumType, tag:String):String {
		return '${t.name}.$tag (${t.names.join(" | ")})';
	}

	/**
	 * The expression of the constructor `name` of `t`, by its full path.
	 */
	public static function constructorExpr(t:EnumType, name:String):Expr {
		var path = t.module.split(".");
		path.push(t.name);
		path.push(name);
		return macro $p{path};
	}
}
#end
