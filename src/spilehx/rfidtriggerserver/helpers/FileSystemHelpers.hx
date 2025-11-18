package spilehx.rfidtriggerserver.helpers;

import haxe.Constraints.Function;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import sys.FileSystem;
import haxe.io.Path;
import spilehx.config.RFIDTriggerServerConfig;

class FileSystemHelpers {
	public static final instance:FileSystemHelpers = new FileSystemHelpers();

	private function new() {}

	public function getFullPath(subPath:String):String {
		var root:String = SettingsManager.instance.applicationDataFolder;

		var path:String = root + "/" + subPath;
		return path;
	}

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

	public function setupApplicationDataFolder(onFolderReady:Function) {
		var root:String = SettingsManager.instance.applicationDataFolder;

		if (isValidPath(root) == false) {
			LOG_ERROR(root + " is not a valid path - must start with / or ./");
			Sys.exit(1);
		}

		if (FileSystem.exists(root) == false) {
			USER_MESSAGE("Application data folder not found at: " + root);
			USER_MESSAGE_WARN("Creating automatically in 5 seconds, ctrl-c to exit");
			Sys.sleep(5);
			ensurePath(root);
		} else {
			USER_MESSAGE("Application data folder FOUND at: " + root);
		}
		ensureAppDataFolderStructure();

		onFolderReady();
	}

	private function ensureAppDataFolderStructure() {
		USER_MESSAGE("Ensureing structure");
		ensurePath(getFullPath(RFIDTriggerServerConfig.IMAGE_FOLDER));
		ensurePath(getFullPath(RFIDTriggerServerConfig.SETTINGS_FOLDER));
		ensurePath(getFullPath(RFIDTriggerServerConfig.CACHE_FOLDER));
		ensurePath(getFullPath(RFIDTriggerServerConfig.YT_CACHE_FOLDER));
	}

	public function isValidPath(path:String):Bool {
		return (StringTools.startsWith(path, "/") || StringTools.startsWith(path, "./"));
	}
}
