package tests;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

/**
 * Compiles an expression apart from the test build, with the same compiler and class paths.
 */
class BuildError {
	/** The compiler output if `e` fails to build, or null if it builds. */
	public macro static function of (e:Expr) : ExprOf<Null<String>> {
		var compiler = "haxe";
		var args = [];
		for (cp in Context.getClassPath()) {
			var dir = Path.removeTrailingSlashes(Path.normalize(cp));
			var name = Path.withoutDirectory(dir);
			if (name == "std" || name == "_std" || name == "extraLibs") {
				var candidate = Path.join([Path.directory(dir), "haxe"]);
				if (name == "std" && sys.FileSystem.exists(candidate) && !sys.FileSystem.isDirectory(candidate)) {
					compiler = candidate;
				}
				continue;
			}
			args.push("-cp");
			args.push(cp == "" ? "." : cp);
		}

		var dir = Path.join([Sys.getEnv("TMPDIR") != null ? Sys.getEnv("TMPDIR") : "/tmp", 'json2object-build-error-${Std.random(1000000000)}']);
		sys.FileSystem.createDirectory(dir);
		sys.io.File.saveContent(Path.join([dir, "Probe.hx"]), 'class Probe { static function main() { ${e.toString()}; } }');
		args = args.concat(["-cp", dir, "-main", "Probe", "--interp", "--no-output"]);

		var process = new sys.io.Process(compiler, args);
		var output = process.stderr.readAll().toString() + process.stdout.readAll().toString();
		var code = process.exitCode();
		process.close();
		sys.FileSystem.deleteFile(Path.join([dir, "Probe.hx"]));
		sys.FileSystem.deleteDirectory(dir);

		return (code == 0) ? macro null : macro $v{output};
	}
}
