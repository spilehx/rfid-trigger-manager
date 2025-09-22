package settings;

class SettingsData {
	public static final ACTION_STREAM:String = "ACTION_STREAM";
	public static final ACTION_YTPL:String = "ACTION_YTPL";

    public var verboseLogging:Bool; // show all outputs
	public var deviceID:String; // stored id of usb rfid reader
	public var cards:Array<CardData>;

	public function new() {
        verboseLogging = true;
		deviceID = "";
		cards = new Array<CardData>();
	}
}

