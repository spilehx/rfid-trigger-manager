package spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers;

import haxe.ui.components.DropDown;
import haxe.ui.data.DataSource;
import spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto.EditableItemRenderer;
import spilehx.rfidtriggeradmin.page.components.tableviewitemrenderers.proto.InputItemRenderer;
import haxe.ui.events.UIEvent;
@:xml('
<item-renderer>
  
	<dropdown id="actionDropDown" width="100%" >
  
    </dropdown>
</item-renderer>
')
class ActionItemRenderer extends EditableItemRenderer {
	private override function addEvents() {
		actionDropDown.registerEvent(UIEvent.CHANGE, function(e) {
			// LOG_OBJECT(e);
		});
	}

	private override function onDataChanged(data:Dynamic) {
		super.onDataChanged(data);
		if (updateInProgress == false) {
			if (data != null) {

				var value = Reflect.field(data, this.id);

				 var items = [];//:Array<DataSource>  = new Array<DataSource>();
				 for(a in RFIDTriggerAdminConfigManager.instance.settings.avalibleCardActions){
					var item = {};
					Reflect.setField(item,"text", a);
// AHHHHH haxeUI is a pain to do simple things!!!
	
					items.push(item);
				
					
				 }

				 // DropDown
					actionDropDown.dataSource.data = items;

			}
		}
	}
}
