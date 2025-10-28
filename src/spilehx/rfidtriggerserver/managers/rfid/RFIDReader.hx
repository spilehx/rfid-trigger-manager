package spilehx.rfidtriggerserver.managers.rfid;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;
import haxe.Timer;
import sys.thread.Thread;
import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.io.BytesInput;

using StringTools;

class RFIDReader {
	public static final instance:RFIDReader = new RFIDReader();

	final keys:String = "X^1234567890XXXXqwertzuiopXXXXasdfghjklXXXXXyxcvbnmXXXXXXXXXXXXXXXXXXXXXXX";

	static inline var EV_KEY:Int = 1;
	static inline var KEY_ENTER:Int = 28;
	static inline var KEY_KPENTER:Int = 96;

	var device:Device;
	var eventNode:String;

	// NEW: background reader thread + control
	var running:Bool = false;
	var readerThread:Thread = null;
	var dispatchTimer:Timer = null;

	private function new() {}

	public function startRead(device:Device, onRead:String->Void):Void {
		// prevent duplicate starts
		if (running) {
			return;
		}

		this.device = device;
		this.eventNode = resolveEventNode(device);

		if (this.eventNode == null) {
			Sys.println('Could not find device "' + device.name + '" or its event handler.');
			return;
		}

		running = true;

		// handle messages on the MAIN thread (poll, non-blocking)
		dispatchTimer = new Timer(10);
		dispatchTimer.run = function() {
			var msg:Dynamic = Thread.readMessage(false);
			while (msg != null) {
				var s = Std.string(msg);
				if (s.length > 0) {
					onRead(s);
				}
				msg = Thread.readMessage(false);
			}
		};

		final mainThread = Thread.current();

		readerThread = Thread.create(() -> {
			var fin:sys.io.FileInput = null;
			var buf = new StringBuf();

			try {
				fin = sys.io.File.read("/dev/input/" + eventNode, true);

				while (running) {
					// blocking read on the worker thread (safe for the app)
					var ev = readInputEvent(fin);

					if (ev.typ == EV_KEY && ev.value == 1) {
						if (ev.code == KEY_ENTER || ev.code == KEY_KPENTER) {
							var result = buf.toString().trim();
							buf = new StringBuf();

							if (result.length > 0) {
								// send to MAIN thread (polled by dispatchTimer)
								mainThread.sendMessage(result);
							}
						} else {
							if (ev.code >= 0 && ev.code < keys.length) {
								buf.add(keys.charAt(ev.code));
							}
						}
					}
				}
			} catch (e:Dynamic) {
				mainThread.sendMessage('[RFIDReader error] ' + Std.string(e));
			}

			// TODO: tidy up
			if (fin != null) {
				try {
					fin.close();
				} catch (_:Dynamic) {}
			}

			readerThread = null;
		});
	}

	public function stopRead():Void {
		if (!running) {
			return;
		}

		running = false;

		if (dispatchTimer != null) {
			dispatchTimer.stop();
			dispatchTimer = null;
		}
	}

	private function resolveEventNode(d:Device):String {
		for (h in d.handlers) {
			if (StringTools.startsWith(h, "event")) {
				return h;
			}
		}

		var content = readProcDevices();
		if (content != null && content.trim().length > 0) {
			var blocks = new EReg("\\n\\s*\\n", "g").split(content);
			for (block in blocks) {
				var name:String = null;
				var handlers:Array<String> = [];
				for (line in block.split("\\n")) {
					var l = line.trim();
					if (StringTools.startsWith(l, "N: Name=")) {
						var q1 = l.indexOf('"');
						var q2 = l.lastIndexOf('"');
						if (q1 >= 0 && q2 > q1) {
							name = l.substr(q1 + 1, q2 - q1 - 1);
						} else {
							name = l.substr("N: Name=".length);
						}
					} else {
						if (StringTools.startsWith(l, "H: Handlers=")) {
							var tokens = l.substr("H: Handlers=".length).split(" ");
							for (t in tokens) {
								if (StringTools.startsWith(t, "event")) {
									handlers.push(t);
								}
							}
						}
					}
				}
				if (name != null && name == d.name && handlers.length > 0) {
					return handlers[0];
				}
			}
		}

		var sysClass = "/sys/class/input";
		if (FileSystem.exists(sysClass)) {
			var entries = try FileSystem.readDirectory(sysClass) catch (_:Dynamic) [];
			for (e in entries) {
				if (StringTools.startsWith(e, "event")) {
					var namePath = Path.join([sysClass, e, "device", "name"]);
					if (FileSystem.exists(namePath)) {
						var devName = try File.getContent(namePath).trim() catch (_:Dynamic) null;
						if (devName != null && devName == d.name) {
							return e;
						}
					}
				}
			}
		}

		return null;
	}

	private function readInputEvent(fin:sys.io.FileInput):InputEvent {
		var bytes = fin.read(24);
		if (bytes.length < 24) {
			bytes = fin.read(16);
		}
		if (bytes.length < 8)
			throw "Failed to read input_event";

		var tail:haxe.io.Bytes = (bytes.length >= 24) ? bytes.sub(16, 8) : bytes.sub(8, 8);

		var bi = new BytesInput(tail);
		// LE on Linux input
		var typ = u16le(bi);
		var code = u16le(bi);
		var value = s32le(bi);

		return {typ: typ, code: code, value: value};
	}

	private function readProcDevices():String {
		var p = "/proc/bus/input/devices";

		if (ActionCommandHelpers.isRunningInDocker() == true) {
			p = "/host_proc/bus/input/devices";
		}

		// var p = "/proc/bus/input/devices";
		if (!FileSystem.exists(p)) {
			return null;
		}
		try {
			var fi = File.read(p, false);
			var s = fi.readAll().toString();
			fi.close();
			return s;
		} catch (_:Dynamic) {
			return null;
		}
	}

	inline function u16le(bi:BytesInput):Int {
		var b0 = bi.readByte();
		var b1 = bi.readByte();
		return (b0 | (b1 << 8));
	}

	inline function s32le(bi:BytesInput):Int {
		var b0 = bi.readByte();
		var b1 = bi.readByte();
		var b2 = bi.readByte();
		var b3 = bi.readByte();
		return (b0 | (b1 << 8) | (b2 << 16) | (b3 << 24));
	}
}

typedef InputEvent = {
	var typ:Int;
	var code:Int;
	var value:Int;
}
