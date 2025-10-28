package spilehx.rfidtriggerserver.helpers;

import haxe.Constraints.Function;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.Process;

class ActionCommandHelpers {
	private static final MOPIDY_CONFIG_FOLDER_PATH:String = "/app/appdata/mopidy";
	private static final MOPIDY_CONFIG_FILE_NAME:String = "mopidy.conf";
	public static var MOPIDY_CONFIG_PATH:String = MOPIDY_CONFIG_FOLDER_PATH + "/" + MOPIDY_CONFIG_FILE_NAME;

	private static final MOPIDY_DEFAULT_CONFIG_FILE_PATH:String = "/app/defaultconfigs/mopidy/mopidy.conf";

	public static function isProcessRunning(processName:String):Bool {
		try {
			// Run `pgrep -x processName`
			var proc = new Process("pgrep", ["-x", processName]);

			// Read all output (to prevent blocking)
			var output = proc.stdout.readAll().toString();
			var exitCode = proc.exitCode();

			// Close process handles
			proc.close();

			// If exit code is 0, the process is running
			return (exitCode == 0);
		} catch (e:Dynamic) {
			// On error (e.g., pgrep not found), assume not running
			return false;
		}
	}

	public static function checkMopidyState(onSuccess:Function, onFail:Function) {
		LOG_INFO("checking Mopidy state");

		var mopidyRunning:Bool = ActionCommandHelpers.isProcessRunning("mopidy");

		if (mopidyRunning == true) {
			LOG_INFO("Mopidy OK");
			onSuccess();
			// setMPCPlaylist();
		} else {
			LOG_INFO("Starting Mopidy");
			ActionCommandHelpers.startMopidy(function(success:Bool) {
				if (success == true) {
					onSuccess();
				} else {
					LOG_ERROR("Could not start mopidy");
					onFail();
				}
			});
		}
	}

	public static function startMopidy(onComplete:Bool->Void = null):Void {
		try {
			// Run the command through a shell to emulate `nohup ... &`
			var mopidyCommand:String = "nohup mopidy >/dev/null 2>&1 &";

			if (FileSystem.exists(MOPIDY_CONFIG_PATH) == true) {
				// we are in docker use the docker config
				mopidyCommand = "nohup mopidy --config " + MOPIDY_CONFIG_PATH + " >/dev/null 2>&1 &";
			}

			var proc = new Process("/bin/sh", ["-c", mopidyCommand], true);
			var exitCode = proc.exitCode();
			proc.close();

			if (onComplete != null) {
				var success:Bool = (exitCode == 0);
				if (success == true) {
					USER_MESSAGE("Waiting for Mopidy to come up fully");
					Sys.sleep(5);
					USER_MESSAGE("Ok - proceeding");
				}
				onComplete(success);
			}
		} catch (e:Dynamic) {
			LOG_ERROR("Error starting mopidy: " + e);
			onComplete(false);
		}
	}

	public static function killProcess(processName:String):Void {
		try {
			// Run pkill via shell
			var proc = new Process("pkill", [processName]);

			// Wait for pkill to finish
			var exitCode = proc.exitCode();
			proc.close();

			if (exitCode == 0) {
				trace(processName + " stopped successfully.");
			} else {
				// pkill returns nonzero if no process was found
				trace("No " + processName + " process found (exit code: " + exitCode + ")");
			}
		} catch (e:Dynamic) {
			LOG_ERROR("Error stopping " + processName + ": " + e);
		}
	}

	public static function ensureDefaultConfigFiles() {
		if (isRunningInDocker() == true) {
			ensureMopidyConfig();
		}
	}

	private static function ensureMopidyConfig() {
		// this will check if there is a user mopidy config
		if (FileSystem.exists(MOPIDY_CONFIG_PATH) == false) {
			LOG_WARN("No mopidy config found, creating default");
			ensurePath(MOPIDY_CONFIG_FOLDER_PATH);
			File.copy(MOPIDY_DEFAULT_CONFIG_FILE_PATH, MOPIDY_CONFIG_PATH);
		}
	}

	public static function isRunningInDocker():Bool {
		// simple check for an empty file created in the dockerfile
		return FileSystem.exists("/app/IS_DOCKER.file");
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
}
