package actionmanager;

import sys.thread.Mutex;
import sys.thread.Thread;
import haxe.Constraints.Function;
import sys.io.Process;

class ProcessHelper {
	public static function closeProcess(proc:ProcessHandle) {
		proc.kill();
		proc = null;
	}

	public static function killByName(name:String) {
		var killProc:Process = new sys.io.Process("pkill " + name);
	}

	public static function killByPid(pid:Int) {
		var killProc:Process = new sys.io.Process("pkill " + pid);
		LOG("ERRR " + killProc.stderr.readAll().toString());
		LOG("out " + killProc.stdout.readAll().toString());
	}

	public static function playAudioStream(url:String, onExit:Function):ProcessHandle {
		// Use args-based launch so the process doesn't hang
		return runProcessArgs("mpv", [url], onExit);
	}

	public static function playYTPlaylist(plId:String, onExit:Function):ProcessHandle {
		var pl:String = "https://www.youtube.com/playlist?list=" + plId;
		return runProcessArgs("mpv", ["--no-video", pl], onExit);
	}

	public static function playYTVideo(id:String, onExit:Function):ProcessHandle {
		var url:String = "https://www.youtube.com/watch?v=" + id;
		return runProcessArgs("mpv", ["--no-video", url], onExit);
	}

	// Deprecated: prefer runProcessArgs(). This version uses a shell to support a single string.
	private static function runProcess(action:String, onExit:Function):ProcessHandle {
		var ph = new ProcessHandle("sh", ["-c", action]);
		ph.start(function(code:Int) {
			trace("EXITED");
			if (onExit != null) onExit();
		});
		return ph;
	}

	private static function runProcessArgs(cmd:String, args:Array<String>, onExit:Function):ProcessHandle {
		var ph = new ProcessHandle(cmd, args);
		ph.start(function(code:Int) {
			trace("EXITED");
			if (onExit != null) onExit();
		});
		return ph;
	}
}

class ProcessHandle {
	public var proc:Process; // lazily created on background thread

	var t:Thread;
	var m = new Mutex();
	var _done = false;
	var _exitCode:Int = -1;
	var _cmd:String;
	var _args:Null<Array<String>>;

	public function new(cmd:String, ?args:Array<String>) {
		_cmd = cmd;
		_args = args;
	}

	public function start(?onExit:Int->Void):Void {
		// run everything on a background thread, including Process creation
		t = Thread.create(() -> {
			// create the process here so construction doesn't block the caller thread
			proc = (_args == null || _args.length == 0) ? new Process(_cmd) : new Process(_cmd, _args);

			// Drain output to avoid child process blocking on full pipes
			Thread.create(() -> {
				try {
					while (true) proc.stdout.readLine();
				} catch (_:Dynamic) {}
			});
			Thread.create(() -> {
				try {
					while (true) proc.stderr.readLine();
				} catch (_:Dynamic) {}
			});

			// Poll until exitCode() stops throwing
			while (true) {
				try {
					var code = proc.exitCode(); // throws if still running
					m.acquire();
					_exitCode = code;
					_done = true;
					m.release();
					try proc.close() catch (_:Dynamic) {}
					if (onExit != null) onExit(code);
					break;
				} catch (_:Dynamic) {
					Sys.sleep(0.05); // 50ms poll interval
				}
			}
		});
	}

	public function isDone():Bool {
		m.acquire();
		var d = _done;
		m.release();
		return d;
	}

	/** Returns null if not finished yet. */
	public function tryExitCode():Null<Int> {
		m.acquire();
		var d = _done;
		var c = _exitCode;
		m.release();
		return d ? c : null;
	}

	public function kill():Void {
		try if (proc != null) proc.kill() else {} catch (_:Dynamic) {}
	}
}
