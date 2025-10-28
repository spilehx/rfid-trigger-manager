package spilehx.rfidtriggerserver.managers.actionmanager.actions;

import haxe.Constraints.Function;

class YTPlayListAction extends Action {
	private var playList:Array<String>;
	private var currentTrack:Int = 0;
	private var forceStop:Bool = false;

	override public function start() {
		super.start();
		triggerProcessForResponse("yt-dlp", ["--flat-playlist", "--get-id", command], function(resp:Dynamic) {
			playList = Std.string(resp).split("\n");
			var validResponse:Bool = ((playList.length > 0)
				&& (Std.string(resp).indexOf("WARNING") == -1)
				&& (Std.string(resp).indexOf("ERROR") == -1));

			if (validResponse) {
				playTrack(0);
			} else {
				USER_MESSAGE("Bad playlist, no tracks found");
			}
		});
	}

	override public function startWhileAlreadyRunning() {
		playNextTrack();
	}

	private function playTrack(index:Int) {
		USER_MESSAGE("Playing track: " + index);
		currentTrack = index;
		var url:String = "https://www.youtube.com/watch?v=" + playList[currentTrack];
		triggerProcess("mpv", ["--no-video", url], onProcessDone);
	}

	private function onProcessDone() {
		if (forceStop == true) {
			onFinished();
		} else {
			onTrackFinished();
		}
	}

	private function onTrackFinished() {
		playNextTrack();
	}

	override public function stop() {
		forceStop = true;
		super.stop();
	}

	private function playNextTrack() {
		USER_MESSAGE("Playing next track : " + this.type + " " + command);
		ProcessWrapper.instance.stop(function() {
			if (currentTrack < playList.length) {
				currentTrack += 1;

				playTrack(currentTrack);
			} else {
				ProcessWrapper.instance.stop(null, false);
			}
		}, true);
	}
}
