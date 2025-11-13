package spilehx.rfidtriggeradmin.tools;

import js.html.Element;
import haxe.ui.events.UIEvent;

import haxe.Constraints.Function;
import haxe.Timer;
import haxe.ui.core.Component;

using haxe.ui.animation.AnimationTools;

class AnimateEffect {
	private static final bounceBackInAnimCss:String = '@keyframes ANIM_ID {
		0% {
			animation-timing-function: ease-in;
			opacity: 0;
			transform: scale(3);
		}

		38% {
			animation-timing-function: ease-out;
			opacity: 1;
			transform: scale(1);
		}

		55% {
			animation-timing-function: ease-in;
			transform: scale(1.5);
		}

		72% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}

		81% {
			animation-timing-function: ease-in;
			transform: scale(1.24);
		}

		89% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}

		95% {
			animation-timing-function: ease-in;
			transform: scale(1.04);
		}

		100% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}
	}';

	private static final bounceForwardInAnimCss:String = '@keyframes ANIM_ID {
		0% {
			animation-timing-function: ease-in;
			opacity: 0;
			transform: scale(0);
		}

		38% {
			animation-timing-function: ease-out;
			opacity: 1;
			transform: scale(1);
		}

		55% {
			animation-timing-function: ease-in;
			transform: scale(0.7);
		}

		72% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}

		81% {
			animation-timing-function: ease-in;
			transform: scale(0.84);
		}

		89% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}

		95% {
			animation-timing-function: ease-in;
			transform: scale(0.95);
		}

		100% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}
	}';

	private static final fadeForwardInAnimCss:String = '@keyframes ANIM_ID {
		0% {
			opacity: 0;
			transform: scale(0.6);
		}

		100% {
			opacity: 1;
			transform: scale(1);
		}
	}';

	private static final fadeForwardOutAnimCss:String = '@keyframes ANIM_ID {
		0% {
			opacity: 1;
			transform: scale(1);
		}

		100% {
			opacity: 0;
			transform: scale(0.6);
		}
	}';

	private static final attensionHeartBeatAnimCss:String = '@keyframes ANIM_ID {
		0% {
			animation-timing-function: ease-out;
			transform: scale(1);
			transform-origin: center center;
		}

		5% {
			animation-timing-function: ease-in;
			transform: scale(0.91);
		}

		10% {
			animation-timing-function: ease-out;
			transform: scale(0.98);
		}

		23% {
			animation-timing-function: ease-in;
			transform: scale(0.87);
		}

		35% {
			animation-timing-function: ease-out;
			transform: scale(1);
		}

		100% {
			transform: scale(1); 
		}
	}';

	private static final attensionFadeAnimCss:String = '@keyframes ANIM_ID {
		0% {
			opacity: 1;
		}

		50% {
			opacity: 0.8;
		}

		100% {
			opacity: 1;
		}
	}';

	private static final attensionFadeStrongAnimCss:String = '@keyframes ANIM_ID {
		0% {
			opacity: 1;
		}

		50% {
			opacity: 0.3;
		}

		100% {
			opacity: 1;
		}
	}';

	public static function bounceInBack(component:Component, ?duration:Float = 1, ?delay:Float = 0) {
		var animId:String = "bounceBackInAnimCss";
		var animCssString:String = animId + " " + duration + "s ease 0s 1 normal forwards";

		if (delay > 0) {
			component.opacity = 0;
			var initialStatDelayTimer:Timer = new Timer(Math.floor(delay * 1000));
			initialStatDelayTimer.run = function() {
				initialStatDelayTimer.stop();
				initialStatDelayTimer = null;
				component.opacity = 1;
				triggerCssAnim(component, animId, bounceBackInAnimCss, animCssString);
			}
		} else {
			triggerCssAnim(component, animId, bounceBackInAnimCss, animCssString);
		}
	}

	public static function bounceInForward(component:Component, ?duration:Float = .8, ?onComplete:Function = null) {
		var animId:String = "bounceForwardInAnimCss";
		var animCssString:String = animId + " " + duration + "s ease-in 0s 1 normal forwards";

		triggerCssAnim(component, animId, bounceForwardInAnimCss, animCssString, onComplete);
	}

	public static function fadeInForward(component:Component, ?duration:Float = .5, ?onComplete:Function = null) {
		component.hidden = false;
		var animId:String = "fadeForwardInAnimCss";
		var animCssString:String = animId + " " + duration + "s cubic-bezier(0.5, 0, 0.75, 0) 0s 1 normal forwards";

		triggerCssAnim(component, animId, fadeForwardInAnimCss, animCssString, onComplete);
	}

	public static function fadeOutForward(component:Component, ?duration:Float = .5, ?onComplete:Function = null) {
		var animId:String = "fadeForwardOutAnimCss";
		var animCssString:String = animId + " " + duration + "s cubic-bezier(0.5, 0, 0.75, 0) 0s 1 normal forwards";

		triggerCssAnim(component, animId, fadeForwardOutAnimCss, animCssString, onComplete);
	}

	public static function attensionHeartBeat(component:Component, ?loop:Bool = true, ?duration:Float = 3, ?nCycles:Int = 1, ?onComplete:Function = null) {
		var animId:String = "attensionHeartBeatAnimCss";
		var nCycles:String = loop ? "infinite" : Std.string(nCycles);
		var animCssString:String = animId + " " + duration + "s ease 0s " + nCycles + " normal forwards";

		triggerCssAnim(component, animId, attensionHeartBeatAnimCss, animCssString, onComplete);
	}

	public static function attensionFade(component:Component, ?loop:Bool = true, ?duration:Float = 1.5, ?strong:Bool = false) {
		if (strong == true) {
			var animId:String = "attensionFadeStrongAnimCss";
			var nCycles:String = loop ? "infinite" : "1";
			var animCssString:String = animId + " " + duration + "s ease 0s " + nCycles + " normal forwards";

			triggerCssAnim(component, animId, attensionFadeStrongAnimCss, animCssString);
		} else {
			var animId:String = "attensionFadeAnimCss";
			var nCycles:String = loop ? "infinite" : "1";
			var animCssString:String = animId + " " + duration + "s ease 0s " + nCycles + " normal forwards";

			triggerCssAnim(component, animId, attensionFadeAnimCss, animCssString);
		}
	}

	public static function cancelAnimation(component:Component) {
		component.element.style.animation = "";
	}

	private static function triggerCssAnim(component:Component, animId:String, cssString:String, triggerString:String, ?onComplete:Function = null) {
		var head:Element = js.Browser.document.getElementsByTagName("head")[0];
		var hasStyle:Bool = false;
		for (child in head.children) {
			if (child.id == animId) {
				hasStyle = true;
				break;
			}
		}
		if (hasStyle == false) {
			var style = js.Browser.document.createStyleElement();
			style.id = animId;
			style.type = 'text/css';
			style.innerHTML = cssString.split("ANIM_ID").join(animId);
			head.appendChild(style);
		}

		component.element.style.animation = triggerString;

		var clearUp:Dynamic->Void = function(?e) {
			component.element.style.animation = "";

			if (onComplete != null) {
				onComplete();
			}
		}

		component.element.addEventListener("animationend", clearUp);
		component.registerEvent(UIEvent.HIDDEN, clearUp);
		component.registerEvent(UIEvent.COMPONENT_REMOVED_FROM_PARENT, clearUp);
	}

	public static function shake(component:Component) {
		component.shake("both");
	}

	public static function shakeHorizontal(component:Component) {
		component.shake("horizontal");
	}

	public static function fadeOut(component:Component, onEnd:Void->Void = null, hide:Bool = true) {
		component.fadeOut(function():Void {
			if (onEnd != null) {
				onEnd();
			}
		}, hide);
	}

	public static function fadeIn(component:Component, onEnd:Void->Void = null, show:Bool = true) {
		component.fadeIn(function():Void {
			if (onEnd != null) {
				onEnd();
			}
		}, show);
	}

	public static function fadeInOut(component:Component, ?delay:Int = 2000) {
		component.fadeIn(function() {
			var delayTimer:Timer = new Timer(delay);
			delayTimer.run = function() {
				delayTimer.stop();
				delayTimer = null;
				component.fadeOut();
			}
		});
	}

	public static function transitionIn(component:Component, from:Dynamic, ?shakeAfter:Bool = true, ?fadeOutDur:Int = 1000) {
		var steps:Int = 20;

		var xOrigin:Float = component.left;
		var xFrom:Float = component.left + from.x;
		var xDelta:Float = component.left - xFrom;
		var xStep:Float = xDelta / steps;

		var yOrigin:Float = component.top;
		var yFrom:Float = component.top + from.y;
		var yDelta:Float = component.top - yFrom;
		var yStep:Float = yDelta / steps;

		var opacityStep:Float = 1 / steps;

		component.left = xFrom;
		component.top = yFrom;

		component.show();
		component.opacity = 0;

		component.show();

		executeAfterDelay(10, function() {
			component.top += yStep;
			component.left += xStep;
			component.opacity += opacityStep;
		}, steps, function() {
			component.top = yOrigin;
			component.left = xOrigin;
			component.opacity = 1;
			if (shakeAfter == true) {
				shake(component);

				if (fadeOutDur > 0) {
					executeAfterDelay(fadeOutDur, function() {
						fadeOut(component);
					});
				}
			}
		});
	}

	public static function executeAfterDelay(delay:Int, action:Function, ?nTimes:Int = 0, ?onFinished:Function = null) {
		var times:Int = 0;
		var delayTimer:Timer = new Timer(delay);
		delayTimer.run = function() {
			action();
			times++;
			if (times >= nTimes) {
				delayTimer.stop();
				delayTimer = null;
				if (onFinished != null) {
					onFinished();
				}
			}
		}
	}

	public static function animateValue(startValue:Float, endValue:Float, action:Float->Void, ?duration:Int = 2000, ?onFinished:Function = null):Timer {
		var steps:Int = 300;
		var difference:Float = endValue - startValue;
		var stepValue:Float = difference / steps;
		var currentValue:Float = startValue;
		var stepSpeed:Int = Math.round(duration / steps);
		var currentStep:Int = 0;
		var valueTimer:Timer = new Timer(stepSpeed);
		valueTimer.run = function() {
			difference = endValue - currentValue;
			// stepValue = (difference / steps);
			// stepValue = (difference / steps - (currentStep));
			currentValue += stepValue;
			action(currentValue);
			currentStep++;
			if (currentStep >= steps) {
				action(endValue);
				valueTimer.stop();
				valueTimer = null;
				if (onFinished != null) {
					onFinished();
				}
			}
		}

		return valueTimer;
	}

	public static function tweenValue(startValue:Float, endValue:Float, action:Float->Void, ?duration:Int = 100, ?onFinished:Function = null):Void {
		var ease:Float->Float = function(t:Float):Float {
			// easeInOutCubic
			if (t < 0.5) {
				return 4 * t * t * t;
			} else {
				return 1 - Math.pow(-2 * t + 2, 3) / 2;
			}
		};

		var startStamp:Float = Timer.stamp(); // seconds
		var totalMs:Float = duration;
		var range:Float = endValue - startValue;
		var tickMs:Int = 16;
		var timer:Timer = new Timer(tickMs);
		timer.run = function() {
			var now:Float = Timer.stamp();
			var elapsedMs:Float = (now - startStamp) * 1000.0;
			// Clamp progress to [0,1]
			var t:Float = elapsedMs / totalMs;
			if (t < 0) {
				t = 0;
			}
			if (t > 1) {
				t = 1;
			}
			var v:Float = startValue + range * ease(t);
			action(v);
			if (t >= 1) {
				timer.stop();
				// Ensure exact final value
				action(endValue);
				if (onFinished != null) {
					onFinished();
				}
			}
		};
	}

	public static function clickEffect(component:Component, down:Bool) {
		var posVal:Float = 1;

		if (down == true) {
			posVal = posVal * -1;
		}

		component.left -= posVal;
		component.top -= posVal;
	}
}
