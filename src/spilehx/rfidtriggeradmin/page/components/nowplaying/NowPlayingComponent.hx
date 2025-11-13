package spilehx.rfidtriggeradmin.page.components.nowplaying;

import spilehx.rfidtriggeradmin.tools.AnimateEffect;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggeradmin.tools.UiFilterEffects;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
		<hbox width="95%" height="95%" verticalAlign="center" horizontalAlign="center">
        	<NowPlayingImageComponent id="nowPlayingComponent" height="90%" width="30%" verticalAlign="center"/>	
			<box height="100%" width="70%" verticalAlign="center">
				<label id="nowPlayingLabel" verticalAlign="center" horizontalAlign="center"/>
			</box>	
		</hbox>
	</box>
')
class NowPlayingComponent extends Box {
	private var activeCardId:String;

	private static final FADE_DUR:Float = .5;

	public function new() {
		super();
		setup();
		this.registerEvent(UIEvent.SHOWN, onShown);
	}

	private function setup() {
		this.opacity = 0;
		this.borderRadius = 5;
		this.borderColor = RFIDTriggerAdminSettings.SECTION_BORDER_COLOUR;
		this.borderSize = 2;

		RFIDTriggerAdminSettings.SET_FONT_M(nowPlayingLabel, true);
	}

	private function onShown(e) {
		UiFilterEffects.addDepth(this, true);
	}

	public function update() {
		var activeCard:CardData = RFIDTriggerAdminConfigManager.instance.getActiveCard();
		if (activeCard != null) {
			if (activeCardId != activeCard.id) {
				activeCardId = activeCard.id;
				nowPlayingComponent.update();

				nowPlayingLabel.text = activeCard.name;
				this.opacity = 1;
				AnimateEffect.fadeInForward(this, FADE_DUR, function() {
					this.opacity = 1;
				});
			}
		} else {
			activeCardId = "";
			if (this.opacity != 0) {
				AnimateEffect.fadeOut(this, function() {
					this.opacity = 0;
				},false);
			}
		}
	}
}
