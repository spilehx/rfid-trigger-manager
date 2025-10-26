package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;
import sys.io.Process;

class SpotifyPlaylistAction extends Action {

	override public function start() {
		super.start();
		checkMopidy();
	}

	override public function stop() {
		stopMpc();
		setCardActiveState(cardId, false);
		onActionComplete(cardId);
	}

	override public function startWhileAlreadyRunning() {
		USER_MESSAGE("Next track: " + this.type + " " + command);
		nextTrackMpc();
	}

	private function checkMopidy() {
		LOG_INFO("checking Mopidy state");

		var mopidyRunning:Bool = ActionCommandHelpers.isProcessRunning("mopidy");

		if (mopidyRunning == true) {
			LOG_INFO("Mopidy OK");
			setMPCPlaylist();
		} else {
			LOG_INFO("Starting Mopidy");
			ActionCommandHelpers.startMopidy(function(success:Bool) {
				
				if (success == true) {
					setMPCPlaylist();
				} else {
					LOG_ERROR("Could not start mopidy");
					onFinished();
				}
			});
		}
	}

	private function setMPCPlaylist() {
		// mopidy & sleep 5 && mpc -h 127.0.0.1 clear && mpc add "spotify:playlist:7heA0nmQrcLSKwbDJZqkYU" && mpc play
		USER_MESSAGE("Playing spotfy: " + "spotify:playlist:" + command);
		// var playlist:String = "spotify:playlist:" + command;
var playlist:String = "spotify:track:3n3Ppam7vgaVa1iaRUc9Lp";
		

clearPlaylistMpc();
Sys.sleep(1);
addPlaylistMpc(playlist);
Sys.sleep(1);
trace("playing");
				playMPC();

		// setPlaylist(playlist, function(success:Bool) {
		// 	if (success == true) {
		// 		USER_MESSAGE('Playlist added successfully: ' + command);
		// 		Sys.sleep(5);
		// 		playMPC();
		// 	} else {
		// 		LOG_ERROR("Failed to add playlist");
		// 		onFinished();
		// 	}
		// });
	}

	private function playMPC() {
		triggerProcess("mpc", ["play", "-q"]);
	}

	private function stopMpc() {
		triggerProcess("mpc", ["stop", "-q"]);
	}

	private function nextTrackMpc() {
		triggerProcess("mpc", ["next", "-q"]);
	}


	private function clearPlaylistMpc() {
		triggerProcess("mpc", ["clear"],function () {
			LOG("clearPlaylistMpc done");
		});
	}

private function addPlaylistMpc(playlist:String) {
		triggerProcess("mpc", ["add", playlist],function () {
			LOG("addPlaylistMpc done");
		});
	}


	// private function setPlaylist(trackUri:String, onComplete:Bool->Void):Void {
	// 	try {

	// 		// 1. Clear the current playlist
	// 		var clearProc = new Process("mpc", ["-h", "0.0.0.0", "clear"], true);
	// 		var clearExit = clearProc.exitCode();
	// 		LOG("clear proc");
	// 		LOG(clearProc.stdout.readAll().toString());
	// 		LOG(clearProc.stderr.readAll().toString());
	// 		clearProc.close();

	// 		if (clearExit != 0) {
	// 			LOG_ERROR("Failed to clear MPC playlist (exit code: " + clearExit + ")");
	// 			onComplete(false);
	// 			return;
	// 		}

	// 		// 2. Add the new track URI
	// 		var addProc = new Process("mpc", ["-h", "0.0.0.0", "add", trackUri], true);
	// 		var addExit = addProc.exitCode();
	// 		LOG("add proc");
	// 		LOG(addProc.stdout.readAll().toString());
	// 		LOG(addProc.stderr.readAll().toString());
	// 		// Sys.sleep(5);
	// 		addProc.close();

	// 		onComplete((addExit == 0));
	// 	} catch (e:Dynamic) {
	// 		LOG_ERROR("Error running playSpotify: " + e);
	// 		onComplete(false);
	// 	}
	// }
}
