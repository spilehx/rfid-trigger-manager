package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers;

import spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto.InputItemRenderer;
import haxe.ui.events.UIEvent;

class CommandItemRenderer extends InputItemRenderer {
	private override function addEvents() {
		valueComponent.registerEvent(UIEvent.CHANGE, function(e) {
			submitUpdate("command", valueComponent.text);
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
