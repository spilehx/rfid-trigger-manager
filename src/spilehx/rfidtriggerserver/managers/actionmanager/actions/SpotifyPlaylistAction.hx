package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;

class SpotifyPlaylistAction extends Action {
	override public function start() {
		super.start();
		ActionCommandHelpers.ensureMopidyState(function() {
			// mopidy ok
			setMPCPlaylist();
		}, function() {
			// mopidy failed
			onFinished();
		});
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

	private function setMPCPlaylist() {
		USER_MESSAGE("Playing spotfy: " + "spotify:playlist:" + command);
		var playlist:String = "spotify:playlist:" + command;
		clearPlaylistMpc();
		addPlaylistMpc(playlist);
		playMPC();
	}

	private function playMPC() {
		triggerProcess("mpc", ["play", "-q"],function() {
			LOG("playMPC done");
		});
	}

	private function stopMpc() {
		triggerProcess("mpc", ["stop", "-q"]);
	}

	private function nextTrackMpc() {
		triggerProcess("mpc", ["next", "-q"],function() {
			LOG("nextTrackMpc done");
		});
	}

	private function clearPlaylistMpc() {
		triggerProcess("mpc", ["clear"], function() {
			LOG("clearPlaylistMpc done");
		});
	}

	private function addPlaylistMpc(playlist:String) {
		triggerProcess("mpc", ["add", playlist], function() {
			LOG("addPlaylistMpc done");
		});
	}
}
