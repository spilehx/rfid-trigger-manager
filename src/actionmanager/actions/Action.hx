package actionmanager.actions;

class Action {

	@:isVar public var type(get, null):String;

	public function new() {
        this.type = "base";

    }

	public function start() {
        trace("STARTING "+type);
    }

	public function stop() {
        trace("Stopping "+type);
    }


    public function startWhileAlreadyRunning() {
        trace("startWhileAlreadyRunning "+type);
    }

  

    

	function get_type():String {
		return type;
	}
}
