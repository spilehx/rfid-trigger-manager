package spilehx.versionmanager;

class VersionManager {
	public static macro function getVersion():haxe.macro.Expr.ExprOf<String> {
		#if !display
		var runCommand:String->Array<String>->String = function(cmd:String, args:Array<String>):String {
			var process = new sys.io.Process(cmd, args);
			if (process.exitCode() != 0) {
				var message = process.stderr.readAll().toString();
				var pos = haxe.macro.Context.currentPos();
				haxe.macro.Context.error("Cannot execute `" + cmd + " " + args.join(" ") + "`. " + message, pos);
			}

			var response:String = process.stdout.readLine();
			return response;
		};

		var branch:String = runCommand('git', ['rev-parse', '--abbrev-ref', 'HEAD']);

		if (branch.length > 0) {
			return macro $v{branch};
		}

		var tag:String = runCommand('bash', ["-c", "git describe --tags --exact-match 2>/dev/null || echo \"\""]);

		if (tag.length > 0) {
			return macro $v{tag};
		}

		trace("No branch or tag name found");
		return macro $v{"unknown version"};
		#else
		return macro $v{""};
		#end
	}

	public static macro function getBuildTime():haxe.macro.Expr.ExprOf<Float> {
		#if !display
		return macro $v{Date.now().getTime()};
		#else
		return macro $v{0};
		#end
	}

	public static function isNewerVersion(runningVersion:String, newestVersion:String):Bool {
		var newestSomanticVersion:SomanticVersion = new SomanticVersion(newestVersion);
		var runningSomanticVersion:SomanticVersion = new SomanticVersion(runningVersion);

		if (newestSomanticVersion.major != runningSomanticVersion.major) {
			return newestSomanticVersion.major > runningSomanticVersion.major;
		}

		if (newestSomanticVersion.minor != runningSomanticVersion.minor) {
			return newestSomanticVersion.minor > runningSomanticVersion.minor;
		}

		if (newestSomanticVersion.bugfix != runningSomanticVersion.bugfix) {
			return newestSomanticVersion.bugfix > runningSomanticVersion.bugfix;
		}
		return false; // versions are equal
	}

	public static function getLatestReleaseName(owner:String, repo:String, callback:String->Void):Void {
		var url = 'https://api.github.com/repos/$owner/$repo/releases/latest';
		var http = new haxe.Http(url);

		http.setHeader("User-Agent", repo);

		http.onData = data -> {
			try {
				final json:Dynamic = haxe.Json.parse(data);
				final name:String = json.name;
				callback(name);
			} catch (e) {
				callback("");
			}
		}

		http.onError = err -> {
			callback("");
		}

		http.request();
	}
}

class SomanticVersion {
	@:isVar public var valid(default, null):Bool;

	@:isVar public var major(default, null):Float;
	@:isVar public var minor(default, null):Float;
	@:isVar public var bugfix(default, null):Float;

	public function new(versionString:String) {
		valid = validateVersion(versionString);
	}

	private function validateVersion(versionString:String):Bool {
		// is of format 11.11.11
		//  has 2 '.'
		//  is numbers when split
		var dot:String = ".";
		if (versionString.indexOf(dot) > -1) {
			var split:Array<String> = versionString.split(dot);
			if (split.length == 3) {
				for (v in split) {
					if (isFloat(v) == false) {
						trace("not valid version numbers");
						return false;
					}
				}

				major = Std.parseFloat(split[0]);
				minor = Std.parseFloat(split[1]);
				bugfix = Std.parseFloat(split[2]);

				return true;
			}
		}

		return false;
	}

	private function isFloat(s:String):Bool {
		var v = Std.parseFloat(s);
		return !Math.isNaN(v);
	}
}
