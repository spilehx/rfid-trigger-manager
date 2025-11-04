package spilehx.rfidtriggeradmin;

import spilehx.macrotools.Macros;
import haxe.macro.Expr;

class RFIDTriggerAdminHTMLGenerator {
	private static var ENV_KEY_adminHTMLFileName:String = "adminHTMLFileName";
	private static var ENV_KEY_outputFolderPath:String = "outputFolderPath";

	public static macro function generateHtmlFile():Expr {
		// var outputFolderPath = Std.string(Macros.getEnvVar(ENV_KEY_outputFolderPath));
		// var adminHTMLFileName = Std.string(Macros.getEnvVar(ENV_KEY_adminHTMLFileName));
		var outputFolderPath = Macros.getEnvVar(ENV_KEY_outputFolderPath);
		var adminHTMLFileName = Macros.getEnvVar(ENV_KEY_adminHTMLFileName);
		var fullHTMLFilePath = outputFolderPath + "/" + adminHTMLFileName;
		Macros.ensureFolder(outputFolderPath);
		Macros.writeFile(getContent(), fullHTMLFilePath);

		return macro {};
	}

	private static function getContent():String {
		var html:HtmlItem = new HtmlItem("html");
		var head:HtmlItem = new HtmlItem("head");
		var body:HtmlItem = new HtmlItem("body");

		// header
		var title:HtmlItem = new HtmlItem("title");
		title.addInnerHTML("RFID ADMIN");
		head.addChild(title);

		head.addChild(getStyleTag());

		// var script:HtmlItem = new HtmlItem("script");
		// script.addAttribute("src", "./main.js");
		// head.addChild(script);

		var script:HtmlItem = new HtmlItem("script");
		script.addInnerHTML("$ADMIN_PAGE_SCRIPT_TAG");
		head.addChild(script);

		html.addChild(head);

		// Body
		var applicationDivParent:HtmlItem = new HtmlItem("div");
		applicationDivParent.addAttribute("class", "centerContent");

		var applicationDiv:HtmlItem = new HtmlItem("div");
		applicationDiv.addAttribute("id", "app");

		applicationDivParent.addChild(applicationDiv);
		applicationDiv.addAttribute("class", "centerContent");

		body.addChild(applicationDivParent);

		html.addChild(body);

		return html.toString(true);
	}

	private static function getStyleTag():HtmlItem {
		var style:HtmlItem = new HtmlItem("style");

		style.addInnerHTML("
            body {
                background-color: #1c0730;
                overflow: hidden;
            }


			.centerContent {
				height: 100%;
				width: 100%;

				position: absolute; /* Allows precise positioning */
				top: 50%;
				left: 50%;
				transform: translate(
					-50%,
					-50%
				); /* Centers the div by moving it back by 50% of its own width and height */
			}


        ");

		return style;
	}
}

class HtmlItem {
	private static var INDENT_PREFIX:String = "    ";

	private var tag:String;
	private var contentItems:Array<String>;
	private var htmlStringBuffer:StringBuf;
	private var attributes:Array<HtmlItemAttribute>;
	private var closeTag:String;

	public function new(tag:String) {
		this.tag = tag;
		closeTag = '</' + tag + '>';

		contentItems = new Array<String>();
		attributes = new Array<HtmlItemAttribute>();
		htmlStringBuffer = new StringBuf();
	}

	public function toArray(indent:Bool = false):Array<String> {
		var lines:Array<String> = new Array<String>();

		lines.push(getOpenTagWithAttributes());

		for (contentItem in contentItems) {
			lines.push(contentItem);
		}

		lines.push(closeTag);

		if (indent == true) {
			for (i in 0...lines.length) {
				var s:String = lines[i];
				lines[i] = INDENT_PREFIX + s;
			}
		}

		return lines;
	}

	private function getOpenTagWithAttributes() {
		if (attributes.length > 0) {
			var attString:String = "";
			for (attribute in attributes) {
				attString += attribute.toString() + " ";
			}

			return '<' + tag + ' ' + attString + '>';
		}
		return '<' + tag + '>';
	}

	public function addChild(child:HtmlItem) {
		contentItems = contentItems.concat(child.toArray(true));
	}

	public function addInnerHTML(inner:String) {
		contentItems = [inner];
	}

	public function addAttribute(key:String, value:String) {
		attributes.push(new HtmlItemAttribute(key, value));
	}

	private function addTobuffer(str:String) {
		htmlStringBuffer.add(str);
		htmlStringBuffer.add("\n");
	}

	public function toString(addDocType:Bool = false):String {
		var allLines:Array<String> = toArray();
		if (addDocType == true) {
			allLines.unshift('<!DOCTYPE html>');
		}

		for (line in allLines) {
			addTobuffer(line);
		}

		return htmlStringBuffer.toString();
	}
}

class HtmlItemAttribute {
	private var key:String;
	private var value:String;

	public function new(key:String, value:String) {
		this.key = key;
		this.value = value;
	}

	public function toString():String {
		return key + "=" + "\"" + value + "\"";
	}
}
