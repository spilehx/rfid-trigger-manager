package spilehx.rfidtriggerserver.helpers;

import spilehx.rfidtriggerserver.helpers.cliargs.ApplicationCommandArg;

class ApplicationArgHelper {
	private var INDENT:String = "  \t";
	private var TAB:String = "\t";
	private var FG_RED:Int = 31;
	private var FG_GREEN:Int = 32;

	@:isVar public var helpText_appName(null, default):String;
	@:isVar public var helpText_version(null, default):String;
	@:isVar public var helpText_usage(null, default):String;
	@:isVar public var helpText_description(null, default):Array<String>;
	@:isVar public var helpText_examples(null, default):Array<String>;

	public static final instance:ApplicationArgHelper = new ApplicationArgHelper();

	private var applicationCommandArgs:Array<ApplicationCommandArg>;
	private var onValidArgSubmitted:String->String->Void;

	private function new() {}

	public function parseApplicationArguments(applicationCommandArgs:Array<ApplicationCommandArg>, onValidArgSubmitted:String->String->Void) {
		this.applicationCommandArgs = applicationCommandArgs;
		this.onValidArgSubmitted = onValidArgSubmitted;

		var cliArgs:Array<CLIArg> = getValidCLIArgs();

		if (cliArgs.length > 0) {
			triggerCLIArgs(cliArgs);
		}
	}

	private function triggerCLIArgs(cliArgs:Array<CLIArg>) {
		// look for invalid arg keys
		var validKeys = applicationCommandArgs.map(a -> a.keyValue);
		var invalidKeyFound = Lambda.exists(cliArgs, cliArg -> {
			if (!validKeys.contains(cliArg.argKey)) {
				outputArgErrorMessage("Invalid key " + cliArg.argKey);
				return true;
			}
			return false;
		});

		var helpArg:Bool = Lambda.exists(cliArgs, a -> a.argKey == "--help");

		if (helpArg == true || invalidKeyFound == true) {
			printHelpAndExit();
		} else {
			while (cliArgs.length > 0) {
				var cliArg:CLIArg = cliArgs.pop();
				var foundApplicationArgument:ApplicationCommandArg = Lambda.find(applicationCommandArgs, arg -> arg.keyValue == cliArg.argKey);
				onValidArgSubmitted(foundApplicationArgument.targetProperty, cliArg.argValue);
			}
		}
	}

	private function getValidCLIArgs():Array<CLIArg> {
		var args:Array<String> = Sys.args();
		if (args.length == 0) {
			return [];
		} else if (args.indexOf("--help") > -1) {
			return [
				{
					argKey: "--help",
					argValue: ""
				}
			];
		} else if (args.length % 2 != 0) {
			// by definition there must be an even number of args
			// if not print error and set to --help arg
			outputArgErrorMessage("Bad Arguments");
			return [
				{
					argKey: "--help",
					argValue: ""
				}
			];
		} else {
			// if we are here we have found an even number of arg that does not contain --help
			var validArgs:Array<CLIArg> = new Array<CLIArg>();
			while (args.length > 0) {
				var argKey:String = args.shift();
				var argValue:String = args.shift();
				validArgs.push({
					argKey: argKey,
					argValue: argValue
				});
			}
			return validArgs;
		}
	}

	private function outputArgErrorMessage(errorMsg:String) {
		var line:String = outputFormatToColour("ERROR: " + errorMsg, FG_RED);
		Sys.println(line);
	}

	private function outputFormatToColour(input:String, colour:Int):String {
		return "\033[1;" + colour + "m" + input + " \033[0m";
	}

	private function toGreen(input:String):String {
		return outputFormatToColour(input, FG_GREEN);
	}

	private function printHelpAndExit() {
		var l:Array<String> = new Array<String>();

		l.push(toGreen(helpText_appName + " - " + helpText_version));
		l.push(toGreen("========================================"));

		l.push("");
		l.push("Usage:");
		l.push(INDENT + helpText_usage);

		l.push("");
		l.push("Description:");
		for (line in helpText_description) {
			l.push(INDENT + line);
		}

		l.push("");
		l.push("Options:");
		for (arg in applicationCommandArgs) {
			l.push(INDENT + arg.keyValue + TAB + arg.description);
		}

		l.push("");
		l.push("Examples:");
		for (line in helpText_examples) {
			l.push(INDENT + line);
		}

		while (l.length > 0) {
			Sys.println(l.shift());
		}

		Sys.exit(1);
	}
}

typedef CLIArg = {
	var argKey:String;
	var argValue:String;
}
