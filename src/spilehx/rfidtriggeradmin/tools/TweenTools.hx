package spilehx.rfidtriggeradmin.tools;

import haxe.Constraints.Function;
import haxe.Timer;

class TweenTools {
	public static function tweenValue(startValue:Float, endValue:Float, action:Float->Void, ?duration:Int = 100, ?onFinished:Function = null):Void {
		var steps:Int = 150;
		var timeStep:Int = Math.round(duration / steps);
		var valueArray:Array<Float> = getTweenValueArray(startValue, endValue, steps);
		var timer:Timer = new Timer(timeStep);
		timer.run = function() {
			if (valueArray.length > 0) {
				action(valueArray.shift());
			} else {
				timer.stop();
				// Ensure exact final value
				action(endValue);
				if (onFinished != null) {
					onFinished();
				}
			}
		};
	}

	private static function ease(t:Float):Float {
		// easeInOutCubic
		if (t < 0.5) {
			return 4 * t * t * t;
		} else {
			return 1 - Math.pow(-2 * t + 2, 3) / 2;
		}
	};

	public static function getTweenValueArray(start:Float, end:Float, steps:Int = 100):Array<Float> {
		var result:Array<Float> = [];
		for (i in 0...steps) {
			var t = i / (steps - 1); // normalized 0..1
			var et = ease(t); // eased t
			var value = start + (end - start) * et;
			result.push(value);
		}

		return result;
	}
}
