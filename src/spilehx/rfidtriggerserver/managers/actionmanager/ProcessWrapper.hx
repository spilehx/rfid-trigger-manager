package spilehx.rfidtriggerserver.managers.actionmanager;

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

	// private function setupEnv():Void {
	// 			Sys.putEnv("PATH", "/usr/local/bin:" + Sys.getEnv("PATH"));
	// 	Sys.putEnv("XDG_RUNTIME_DIR", "/run/user/1000");
	// 	Sys.putEnv("PULSE_SERVER", "unix:/run/user/1000/pulse/native");
	// }

	public function start(cmd:String, args:Array<String>, ?onCompleteFollowOn:Function = null):Void {
		this.onCompleteFollowOn = onCompleteFollowOn;
		// trace("  cmd " + cmd + " " + args.join(" "));
		// proc = new Process("/bin/sh", ["-c", cmd+" "+args.join(" ")], true);
		// Sys.putEnv("PATH", "/usr/local/bin:" + Sys.getEnv("PATH"));
		// Sys.putEnv("XDG_RUNTIME_DIR", "/run/user/1000");
		// Sys.putEnv("PULSE_SERVER", "unix:/run/user/1000/pulse/native");
		// setupEnv();
		// EnvHelper.setupEnvAll(false); // pulls caller's env if started via sudo
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
				// trace("proc.stdout  " + proc.stdout.readAll());
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

	public function stop(?onStoppedFollowOn:Function = null, ?softStop:Bool = false):Void {
		this.onStoppedFollowOn = onStoppedFollowOn;

		if (proc != null) {
			proc.kill();
		}

		onStopped();
		if (softStop == false) {
			onComplete();
		}
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

	public function runProcessForResponse(cmd:String, args:Array<String>, onResult:Dynamic->Void) {
		var buffer = new StringBuf();
		var output:String = "";

		var p = new Process(cmd, args, true);
		var t:Timer = new Timer(200);
		t.run = function() {
			// trace("p.exitCode(false)  " + p.exitCode(false));
			if (p.exitCode(false) == null) {
				try {
					while (true) {
						buffer.add(p.stdout.readLine());
						buffer.add("\n");
					}
				} catch (e:haxe.io.Eof) {
					// stream closed
				}
			} else {
				t.stop();
				t = null;
				p.close();

				output = StringTools.trim(buffer.toString());
				onResult(output);
				// trace("Process exited ():\n" + output);
			}
		}

		// var output = p.stdout.readAll().toString();

		// while (p.exitCode(false) != null){

		// 	LOG("RUNNING");
		// 	}

		// var t:Timer = new Timer(200);
		// t.run = function () {
		// 	trace("p.exitCode(false)  "+p.exitCode(false));
		// }

		// LOG_INFO("line "+output);

		return output;
	}
}
