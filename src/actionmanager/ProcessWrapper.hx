package actionmanager;

import haxe.Timer;
import haxe.Constraints.Function;
import sys.io.Process;
import sys.thread.Thread;

class ProcessWrapper {
	public static final instance:ProcessWrapper = new ProcessWrapper();

	private var proc:Process;
	private var pid:Int;
	private var onStoppedFollowOn:Function;
	private var onCompleteFollowOn:Function;
	private var processPoll:Timer;
	private var processPollInterval:Int = 100;

	private function new() {}

	public function start(cmd:String, args:Array<String>, ?onCompleteFollowOn:Function = null):Void {
		this.onCompleteFollowOn = onCompleteFollowOn;
		proc = new Process(cmd, args, true);
		pid = proc.getPid();
		startPollProcess();
	}

	private function startPollProcess() {
		processPoll = new Timer(processPollInterval);
		processPoll.run = onPollProcess;
	}

	private function onPollProcess() {
		if (proc != null) {
			if (proc.exitCode(false) != null) {
				stopPollProcess();
				onComplete();
			}
		} else {
			stopPollProcess();
		}
	}

	private function stopPollProcess() {
		if (processPoll != null) {
			processPoll.stop();
			processPoll = null;
		}
	}

	public function stop(?onStoppedFollowOn:Function = null):Void {
		this.onStoppedFollowOn = onStoppedFollowOn;

		if (proc != null) {
			proc.kill();
		}

		onStopped();
		onComplete();
	}

	private function cleanUp() {
		stopPollProcess();
		if (proc != null) {
			proc = null;
			pid = 0;
		}
	}

	private function onStopped() {
		cleanUp();

		if (onStoppedFollowOn != null) {
			onStoppedFollowOn();
		}
	}

	public function onComplete():Void {
		cleanUp();
		if (onCompleteFollowOn != null) {
			onCompleteFollowOn();
		}
	}
}
