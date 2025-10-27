package spilehx.rfidtriggerserver.helpers;

import sys.io.Process;

class ActionCommandHelpers {
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

	public static function startMopidy(onComplete:Bool->Void = null):Void {
		try {
			// Run the command through a shell to emulate `nohup ... &`
			var proc = new Process("/bin/sh", ["-c", "nohup mopidy >/dev/null 2>&1 &"],true);

			// Wait for shell to finish launching the background job
			var exitCode = proc.exitCode();
			proc.close();

			// if (exitCode != 0) {
			// 	trace("Failed to start mopidy (exit code: " + exitCode + ")");
			// } else {
			// 	trace("Mopidy started successfully.");
			// }

			if (onComplete != null) {
				var success:Bool = (exitCode == 0);
                if(success == true){
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
			LOG_ERROR("Error stopping "+processName+": " + e);
		}
	}
}
