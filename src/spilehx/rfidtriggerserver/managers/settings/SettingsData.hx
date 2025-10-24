package spilehx.rfidtriggerserver.managers.settings;

class SettingsData {
    public var verboseLogging:Bool; // show all outputs
	public var deviceID:String; // stored id of usb rfid reader
	public var cards:Array<CardData>;
	public var avalibleCardActions:Array<String>;
	public var avalibleDevices:Array<String>;

	public function new() {
        verboseLogging = true;
		deviceID = "";
		cards = new Array<CardData>();
		avalibleCardActions = [];
		avalibleDevices = [];
	}
}

