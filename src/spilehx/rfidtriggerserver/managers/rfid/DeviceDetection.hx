package spilehx.rfidtriggerserver.managers.rfid;

import spilehx.rfidtriggerserver.helpers.ActionCommandHelpers;

class DeviceDetection {
	private static var FORBIDDEN_DEVICE_NAME_STRINGS:Array<String> = ["Barcode", "intel", "gpio-keys", "Headset", "PC Speaker", "lid", "power button", "mouse", "touchpad", "video", "audio", "razer", "mic", "headphone", "logitech", "HDA Intel"];

	public static function getDevices():Array<Device> {
		var result:Array<Device> = [];
		var path:String = "/proc/bus/input/devices";

		if (ActionCommandHelpers.isRunningInDocker() == true) {
			path = "/host_proc/bus/input/devices";
		}

		var content:String;
		var fi = sys.io.File.read(path, false);
		content = fi.readAll().toString();
		fi.close();

		var blocks = new EReg("\\n\\s*\\n", "g").split(content); // ✅

		for (block in blocks) {
			var name:String = null;
			var handlers:Array<String> = [];

			var lines = block.split("\n");
			for (line in lines) {
				var l = StringTools.trim(line);
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

			if (name != null && handlers.length > 0) {
				if (allowedDevice(name) == true) {
					result.push({name: name, handlers: handlers});
				}
			}
		}

		return result;
	}

	private static function allowedDevice(deviceName:String):Bool {
		// checking if the device name contains any forbidden strings
		// just so we can exclude devices that are clearly not rfid readers
		// bit rough fix, but helps the user a little

		for (forbidden in FORBIDDEN_DEVICE_NAME_STRINGS) {
			if (deviceName.toLowerCase().indexOf(forbidden.toLowerCase()) != -1) {
				return false;
			}
		}

		return true;
	}

	public static function getDeviceNames():Array<String> {
		var deviceNames:Array<String> = [];
		var devices:Array<Device> = getDevices();

		for (device in devices) {
			deviceNames.push(device.name);
		}

		return deviceNames;
	}

	public static function getDeviceByName(deviceName:String):Device {
		var devices:Array<Device> = getDevices();

		for (device in devices) {
			if (device.name == deviceName) {
				return device;
			}
		}

		return null;
	}
}
