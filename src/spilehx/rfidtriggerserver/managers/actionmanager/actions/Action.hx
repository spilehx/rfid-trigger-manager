package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import haxe.Constraints.Function;
import sys.io.Process;

class Action {
	@:isVar public var type(get, null):String;
	@:isVar public var onActionComplete(get, set):String->Void;

	public var cardId:String;
	public var command:String;

	public var onStopped:Function;

	public function new(cardId:String, command:String) {
		// this.type = "BASE_ACTION";
		this.type = Type.getClassName(Type.getClass(this)).split(".").pop();
		this.cardId = cardId;
		this.command = command;
		setGeneralEnv();
		// setRequiredEnv();
	}

	private function setGeneralEnv() {
		// var username = Sys.getEnv("SUDO_USER");
		// if (username == null || username == "") {
		// 	username = Sys.getEnv("USER");
		// }

		// loadUserEnv(username);

		// var home = Sys.getEnv("HOME");
		// if ((home == null || home == "") && username != null && username != "") {
		// 	home = "/home/" + username;
		// }

		// Sys.putEnv("LANG", "en_US.UTF-8");
		// Sys.putEnv("LC_ALL", "en_US.UTF-8");
		// Sys.putEnv("PATH", "/usr/local/bin:/usr/bin:/bin");

		// if (home != null)
		// 	Sys.putEnv("HOME", home);
		// if (username != null) {
		// 	Sys.putEnv("USER", username);
		// 	Sys.putEnv("LOGNAME", username);
		// }

		// Sys.putEnv("PYTHONIOENCODING", "utf-8");
		// Sys.putEnv("PYTHONUNBUFFERED", "1");

		// Sys.putEnv("SSL_CERT_FILE", "/etc/ssl/certs/ca-certificates.crt");
		// Sys.putEnv("SSL_CERT_DIR", "/etc/ssl/certs");

		Sys.putEnv("PATH", "/usr/local/bin:" + Sys.getEnv("PATH"));
		Sys.putEnv("XDG_RUNTIME_DIR", "/run/user/1000");
		Sys.putEnv("PULSE_SERVER", "unix:/run/user/1000/pulse/native");
	}

	public static function loadUserEnv(user:String = null):Void {
		// pick correct user
		if (user == null || user == "") {
			var sudoUser = Sys.getEnv("SUDO_USER");
			if (sudoUser != null && sudoUser != "") {
				user = sudoUser;
			} else {
				user = Sys.getEnv("USER");
			}
		}

		// run: su -l <user> -c printenv
		var args = ["-l", user, "-c", "printenv"];
		var p:Process = null;
		try {
			p = new Process("su", args, false);
			var out = p.stdout.readAll().toString();
			p.close();

			var lines = ~/\r?\n/.split(out);
			for (line in lines) {
				var key:String = line.split("=")[0];
				var value:String = line.split("=")[1];
				trace("key " + key);

				Sys.putEnv(key, value);

				//     if (line == null || line == "") continue;
				//     var idx = line.indexOf("=");
				//     if (idx <= 0) continue;

				//     var key = line.substr(0, idx);
				//     var value = line.substr(idx + 1);

				//     // skip volatile/noisy
				//     switch (key) {
				//         case "PWD", "OLDPWD", "SHLVL":
				//             // ignore
				//         default:

				//             try Sys.putEnv(key, value) catch (_:Dynamic) {}
				//     }
			}
		} catch (e:Dynamic) {
			trace("Failed to load user env: " + e);
		}
	}

	private function setRequiredEnv() {}

	private function triggerProcessFromStingCommand(command:String, onCompleteFollowOn = null) {
		// helper function so i can just use string commands like i would
		// on the command line rather than breaking up into an array etc
		var splitCommand:Array<String> = command.split(" ");
		var mainCommand:String = splitCommand.shift();

		triggerProcess(mainCommand, splitCommand, onCompleteFollowOn);
	}

	private function triggerProcess(command:String, args:Array<String>, onCompleteFollowOn = null) {
		ProcessWrapper.instance.start(command, args, function() {
			if (onCompleteFollowOn != null) {
				onCompleteFollowOn();
			} else {
				onFinished();
			}
		});
	}

	private function triggerProcessForResponse(command:String, args:Array<String>, onResult:Dynamic->Void) {
		ProcessWrapper.instance.runProcessForResponse(command, args, onResult);
	}

	public function start() {
		USER_MESSAGE("Starting action: " + this.type + " " + command);
		setCardActiveState(cardId, true);
	}

	public function stop() {
		ProcessWrapper.instance.stop(function name() {
			onFinished();
		});
	}

	public function startWhileAlreadyRunning() {
		USER_MESSAGE("Starting again: " + this.type + " " + command);
		stop();
	}

	private function onFinished() {
		USER_MESSAGE("Action Complete " + this.type + " " + command);
		setCardActiveState(cardId, false);
		onActionComplete(cardId);
	}

	function get_type():String {
		return type;
	}

	function get_onActionComplete():String->Void {
		return onActionComplete;
	}

	function set_onActionComplete(onActionComplete):String->Void {
		return this.onActionComplete = onActionComplete;
	}

	private function setCardCurrentState(cardId:String, current:Bool) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		card.current = current;
		SettingsManager.instance.updateCard(card);
	}

	private function setCardActiveState(cardId:String, active:Bool) {
		var card:CardData = SettingsManager.instance.getCard(cardId);
		card.active = active;
		SettingsManager.instance.updateCard(card);
	}
}
