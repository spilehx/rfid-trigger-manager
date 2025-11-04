package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers;

import spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto.InputItemRenderer;
import haxe.ui.events.UIEvent;

class ActionItemRenderer extends InputItemRenderer {
	private override function addEvents() {
		valueComponent.registerEvent(UIEvent.CHANGE, function(e) {
			submitUpdate("action", valueComponent.text);
		});
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (updateInProgress == false) {
			if (data != null) {
				var value = Reflect.field(data, this.id);
				valueComponent.text = value;
			}
		}
	}
}
