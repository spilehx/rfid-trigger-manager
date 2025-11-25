package spilehx.config;

import spilehx.rfidtriggerserver.helpers.cliargs.ApplicationCommandArg;

class RFIDTriggerServerConfig {
	public static final APP_DATA_FOLDER_DEFAULT_PATH:String = "./RFIDTriggerServerData";
	public static final CACHE_FOLDER:String = "filecache";
	public static final YT_CACHE_FOLDER:String = CACHE_FOLDER + "/yt";
	public static final IMAGE_FOLDER:String = "images";
	public static final SETTINGS_FOLDER:String = "appdata";
	public static final SETTINGS_FILE_NAME:String = "settings.json";

	public static final REPO_ORG:String = "spilehx";
	public static final REPO_NAME:String = "rfid-trigger-manager";
	public static final REPO_RELEASE_URL:String = "https://github.com/spilehx/rfid-trigger-manager/releases";

	// Application CLI args
	public static var APP_ARGS:Array<ApplicationCommandArg> = [
        new ApplicationCommandArg("--help", "", "Display this help message and exit."),
		new ApplicationCommandArg("-d", "isDebug", "Runs in debug mode, so does not require sudo, and does not look for devices."),
		new ApplicationCommandArg("-p", "applicationDataFolder","[PATH] Sets the path to the settings and cache folder, if there is not one you will be prompted to create")
	];

	public static final CLI_HELP_CONTENT_APP_NAME:String = "RFID Music Trigger Server";
	public static final CLI_HELP_CONTENT_CLI_USAGE:String = "RFIDTriggerServer [options]";
	public static final CLI_HELP_CONTENT_DESCRIPTION:Array<String> = [
		"The RFID Music Trigger Server and web admin interface",
		"By scanning tags you can trigger music to play from youtube, spotify or live streams",
		"When running, open http://localhost:1337 to setup reader and cards."
	];

    public static final CLI_HELP_CONTENT_EXAMPLES:Array<String> = [
		"# Start server in debug mode with rfid features deactivated",
		"    RFIDTriggerServer -d true",
        "",
		"# Display help message",
        "    RFIDTriggerServer --help",
        ""
	];
}
