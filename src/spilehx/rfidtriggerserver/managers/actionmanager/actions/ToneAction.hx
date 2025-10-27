package spilehx.rfidtriggerserver.managers.actionmanager.actions;

class ToneAction extends Action {
	override public function start() {
		super.start();

		var durationSecs:Float = Std.parseFloat(command);

		if(Math.isNaN(durationSecs)){
			// not supplied or not a valid Int value
			durationSecs = 1;
		}

		// play -n synth 5 sine 440 

		triggerProcessFromStingCommand("play -n synth "+durationSecs+" sine 440");
	}
}
