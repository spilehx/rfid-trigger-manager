package spilehx.rfidtriggerserver.managers;

import spilehx.rfidtriggerserver.managers.rfid.RFIDReader;
import spilehx.rfidtriggerserver.managers.rfid.DeviceDetection;
import spilehx.rfidtriggerserver.managers.rfid.Device;
import spilehx.rfidtriggerserver.managers.SettingsManager;
import haxe.Timer;
import haxe.Constraints.Function;
import sys.thread.Deque;

class RFIDManager extends spilehx.core.ManagerCore {
	public static final instance:RFIDManager = new RFIDManager();

	@:isVar public var onDeviceConnected(get, set):Function;
	@:isVar public var onRead(get, set):String->Void;

	private var connectedDevices:Array<String>;

	final queue = new Deque<String>();
	// var running:Bool = false;
	var pumpTimer:Timer;

	private var device:Device;

	public function init(onDeviceConnected:Function = null, onRead:String->Void = null) {
		this.onDeviceConnected = onDeviceConnected;
		this.onRead = onRead;
		checkDeviceConnection();
	}

	private function checkDeviceConnection() {
		USER_MESSAGE("Checking Device connection");
		if (isConnected() == true) {
			device = DeviceDetection.getDeviceByName(SettingsManager.instance.settings.deviceID);
			deviceConnected();
		} else {
			if (SettingsManager.instance.settings.deviceID == "") {
				USER_MESSAGE("No reader device connected - Open web admin and choose one");
			} else {
				USER_MESSAGE("Saved reader device "
					+ SettingsManager.instance.settings.deviceID
					+ " not connected, connect it or open admin and select another");
			}

			// Delay then recheck
			var recheckDelay:Timer = new Timer(3000);
			recheckDelay.run = function() {
				recheckDelay.stop();
				recheckDelay = null;
				checkDeviceConnection();
			}
		}
	}

	private function deviceConnected() {
		USER_MESSAGE("Device Ready " + SettingsManager.instance.settings.deviceID);
		if (onDeviceConnected != null) {
			onDeviceConnected();
		}

		startCardListen();
	}

	private function delay(t:Int, followOn:Function) {
		var timer:Timer = new Timer(t);
		timer.run = function() {
			timer.stop();
			timer = null;
			followOn();
		}
	}

	private function isConnected():Bool {
		return (DeviceDetection.getDeviceNames().indexOf(SettingsManager.instance.settings.deviceID) > -1
			&& DeviceDetection.getDeviceByName(SettingsManager.instance.settings.deviceID) != null);
	}

	public function startCardListen() {
		USER_MESSAGE("Starting reader listen");
		startQueuePump();

		RFIDReader.instance.startRead(device, function(result) {
			if (isCardCode(result)) {
				queue.add(result);
			}
		});
	}

	private function startQueuePump() {
		pumpTimer = new Timer(10);
		pumpTimer.run = () -> {
			var code:String;
			while ((code = queue.pop(false)) != null) {
				onCardRead(code);
			}
		};
	}

	public function stopCardListen() {
		RFIDReader.instance.stopRead();
		stopQueuePump();
	}

	public function stopQueuePump() {
		if (pumpTimer != null) {
			pumpTimer.stop();
			pumpTimer = null;
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
		USER_MESSAGE("Card Read " + code);
		if (onRead != null) {
			onRead(code);
		}
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
