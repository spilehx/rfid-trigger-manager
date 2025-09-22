package rfid;

import settings.SettingsManager;
import sys.io.Process;
import haxe.Timer;
import haxe.Constraints.Function;

class RFIDManager {
	private static final DEVICE_ID:String = "pci-0000:00:14.0-usb-0:1:1.0-event-kbd";
	public static final instance:RFIDManager = new RFIDManager();

	@:isVar public var onDeviceConnected(get, set):Function;
	@:isVar public var onRead(get, set):String->Void;

	private var connectedDevices:Array<String>;

	// private for singleton use only
	private function new() {}

	public function init() {
		if (SettingsManager.instance.settings.deviceID != "") {
			checkDeviceConnection();
		} else {
			startAddDeviceFlow();
		}
	}

	private function startAddDeviceFlow() {
		USER_MESSAGE("Adding new Reader device");
		USER_MESSAGE("If device is connected, disconnect NOW");
		USER_MESSAGE("then wait for prompt and then connect.");

		delay(3000, function() {
			connectedDevices = getConnectedDeviceList();
			reCheckForNewDevice();
		});
	}

	private function reCheckForNewDevice() {
		USER_MESSAGE("Connect device NOW");
		delay(3000, function() {
			checkForNewDevice();
		});
	}

	private function checkForNewDevice() {
		var newConnectedDevices:Array<String> = getConnectedDeviceList();

		var newdeviceFound:Bool = false;
		var newDevice:String = "";

		for (newConnectedDevice in newConnectedDevices) {
			if (connectedDevices.indexOf(newConnectedDevice) == -1) {
				newdeviceFound = true;
				newDevice = newConnectedDevice;
				break;
			}
		}

		if (newdeviceFound == true) {
			onNewDeviceFound(newDevice);
		} else {
			reCheckForNewDevice();
		}
	}

	private function onNewDeviceFound(deviceID:String) {
		USER_MESSAGE("Device found! " + deviceID, true);
		USER_MESSAGE("Saving config and starting app", true);
		SettingsManager.instance.settings.deviceID = deviceID;
		SettingsManager.instance.saveSettingsData();
		init();
	}

	private function delay(t:Int, followOn:Function) {
		var timer:Timer = new Timer(t);
		timer.run = function() {
			timer.stop();
			timer = null;
			followOn();
		}
	}

	private function checkDeviceConnection() {
		LOG("Checking Device connection");
		if (isConnected() == true) {
			deviceConnected();
		} else {
			// Delay then recheck
			var recheckDelay:Timer = new Timer(3000);
			recheckDelay.run = function() {
				recheckDelay.stop();
				recheckDelay = null;
				checkDeviceConnection();
			}
		}
	}

	private function isConnected():Bool {
		return (getConnectedDeviceList().indexOf(SettingsManager.instance.settings.deviceID) > -1);
	}

	private function getConnectedDeviceList():Array<String> {
		var proc:Process = new sys.io.Process("ls /dev/input/by-id");
		var output:String = proc.stdout.readAll().toString();
		var d:Array<String> = output.split("\n");
		proc.close();
		return d;
	}

	private function deviceConnected() {
		if (onDeviceConnected != null) {
			onDeviceConnected();
		}

		startCardListen();
	}

	private function startCardListen() {
		var cardCode:String = "";
		var inputLine:String;
		try
			while (true) {
				inputLine = Sys.stdin().readLine();
				if (isCardCode(inputLine)) {
					cardCode = inputLine;
					break;
				}
			} catch (e:haxe.io.Eof) {
			trace('End of file, bye!');
		}

		if (cardCode.length > 0) {
			onCardRead(cardCode);
		}
	}

	private function isCardCode(input:String):Bool {
		if (input.length == 10) {
			if (~/^\d+$/.match(input)) { // only contains numbers
				return true;
			}
		}
		return false;
	}

	private function onCardRead(code:String) {
		// LOG("INPUT--->" + code);
		if (onRead != null) {
			onRead(code);
		}

        // start read again
        startCardListen();
	}

	function get_onDeviceConnected():Function {
		return onDeviceConnected;
	}

	function set_onDeviceConnected(onDeviceConnected):Function {
		return this.onDeviceConnected = onDeviceConnected;
	}

	function get_onRead():String->Void {
		return onRead;
	}

	function set_onRead(onRead):String->Void {
		return this.onRead = onRead;
	}
}
