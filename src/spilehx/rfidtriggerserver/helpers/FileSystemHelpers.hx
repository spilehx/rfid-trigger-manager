package spilehx.rfidtriggerserver.helpers;

import sys.FileSystem;
import haxe.io.Path;

class FileSystemHelpers {
    public static function ensurePath(path:String):String {
		// check if a path of dis excists if not creates it
		if (path == null || path.length == 0) {
			throw "validateOrCreatePath: Path is empty.";
		}

		// Normalize to remove duplicate slashes and resolve "." wherever possible.
		var normalized = Path.normalize(path);
		var isAbs = StringTools.startsWith(normalized, "/");
		var cwd = Sys.getCwd();
		var parts = normalized.split("/");

		var acc = isAbs ? "/" : cwd;

		for (p in parts) {
			if (p == null || p == "" || p == ".") {
				// skip empty and current-dir segments
				continue;
			}
			if (p == "..") {
				// go up one level safely
				acc = Path.directory(acc);
				if (acc == null || acc == "")
					acc = "/";
				continue;
			}

			// Join without duplicating slashes
			var next = (acc == "/" ? "/" + p : Path.join([acc, p]));

			if (FileSystem.exists(next)) {
				if (!FileSystem.isDirectory(next)) {
					throw 'validateOrCreatePath: "$next" exists but is not a directory.';
				}
				// already a directory; move on
			} else {
				try {
					FileSystem.createDirectory(next);
				} catch (e:Dynamic) {
					throw 'validateOrCreatePath: Failed to create directory "$next": $e';
				}
			}

			acc = next;
		}

		return acc;
	}
}