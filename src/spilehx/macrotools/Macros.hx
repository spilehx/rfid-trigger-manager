package spilehx.macrotools;

class Macros {
	public static macro function fileAsString(path:String):ExprOf<String> {
		var content:String = "";

		if (sys.FileSystem.exists(path) == true) {
			content = sys.io.File.getContent(path);
		}

		return macro $v{content};
	}
}
