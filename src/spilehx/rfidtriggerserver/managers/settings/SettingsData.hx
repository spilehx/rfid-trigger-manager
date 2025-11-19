package spilehx.rfidtriggerserver.managers.settings;

class SettingsData {
	public var version:String;
	public var buildTime:Float;
	public var updateAvalible:Bool;
	public var verboseLogging:Bool; // show all outputs
	public var deviceID:String; // stored id of usb rfid reader
	public var cards:Array<CardData>;
	public var avalibleCardActions:Array<String>;
	public var avalibleDevices:Array<String>;
	public var logs:String;

	public function new() {
		updateAvalible = false;
		buildTime = 0;
		version = "";
		verboseLogging = true;
		deviceID = "";
		cards = new Array<CardData>();
		avalibleCardActions = [];
		avalibleDevices = [];
		logs = "";
	}
}
