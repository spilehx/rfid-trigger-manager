package spilehx.rfidtriggeradmin.page.components;

import haxe.Json;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.TableView;
import haxe.ui.components.Column;
import haxe.ui.data.ArrayDataSource;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
		<tableview id="cardsTable" width="100%" height="100%">
			<header width="100%">
				<column id="colA" text="ID" width="100%" />
				<column id="colB" text="Name" width="100%" />
				<column id="colC" text="Enabled" width="100%" />
				<column id="colD" text="Active" width="100%" />
				<column id="colE" text="Command" width="100%" />
				<column id="colF" text="Action" width="100%" />
				<column id="colG" text="Trigger" width="100%" />
			</header>

			<StaticItemRenderer id="colA"/>
			<NameItemRenderer id="colB" />
			<CheckItemRenderer id="colC"/>
			<StaticItemRenderer id="colD" />
			<CommandItemRenderer id="colE"/>
			<ActionItemRenderer id="colF"/>
			<TriggerItemRenderer id="colG"/>
		</tableview>
			
	</box>
')
class CardsListSection extends Box {
	private var cardColumns:Array<CardColumn>;

	public function new() {
		super();

		// Define cols in table
		cardColumns = new Array<CardColumn>();
		cardColumns.push(new CardColumn("colA", "ID", "id", 10));
		cardColumns.push(new CardColumn("colB", "Name", "name", 20));
		cardColumns.push(new CardColumn("colC", "Enabled", "enabled", 10));
		cardColumns.push(new CardColumn("colD", "Active", "active", 10));
		cardColumns.push(new CardColumn("colE", "Command", "command", 20));
		cardColumns.push(new CardColumn("colF", "Command", "action", 20));
		cardColumns.push(new CardColumn("colG", "Trigger", "trigger", 20));

		this.registerEvent(UIEvent.SHOWN, onShown);

		setup();
	}

	private function setup() {
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function onShown(e) {
		setupTable(cardsTable);
		this.registerEvent(UIEvent.RESIZE, onResize);
	}

	private function onResize(e) {
		// LOG("ON onResize     ---");
	}

	private function setupTable(table:TableView) {
		table.clearContents();
		for (cardColumn in cardColumns) {
			cardColumn.addToTable(table);
		}
	}

	private var tableDataSource:ArrayDataSource<Dynamic>;
	private var rows:Array<CardRow>;

	private function updateRows(table:TableView, settings:SettingsData) {
		var cards:Array<CardData> = settings.cards;

		if (cards.length > 0) {
			if (rows == null) {
				rows = new Array<CardRow>();
			}

			if (tableDataSource == null) {
				tableDataSource = new ArrayDataSource<Dynamic>();
			}

			tableDataSource = cast table.dataSource;

			for (card in cards) { // each card is a row
				var rowDataItem:Dynamic = getDataSourceRow(card);
				var newRow:CardRow = new CardRow(rowDataItem, card.id);
				var storedRow:CardRow = getRowCardId(card.id);

				if (storedRow == null) {
					// New card row
					newRow.rowId = rows.length;
					newRow.updated = true;
					rows.push(newRow);
				} else {
					var wasUpdated:Bool = rowDataUpdated(storedRow, newRow);
					var storedIndex:Int = rows.indexOf(storedRow);
					rows[storedIndex].updated = wasUpdated;

					if (wasUpdated == true) {
						rows[storedIndex].rowDataItem = newRow.rowDataItem;
					}
				}

				// now update the dataSource
				for (row in rows) {
					if (tableDataSource.get(row.rowId) == null) {
						tableDataSource.add(row.rowDataItem);
					} else {
						// if (row.updated == true) {
						tableDataSource.update(row.rowId, row.rowDataItem);
						// }
					}
				}
			}
		}
	}

	private function rowDataUpdated(row:CardRow, newRow:CardRow):Bool {
		var fields = Reflect.fields(row.rowDataItem);

		for (field in fields) {
			var currentValue = Reflect.getProperty(row.rowDataItem, field);
			var newValue = Reflect.getProperty(newRow.rowDataItem, field);

			if (currentValue != newValue) {
				return true;
			}
		}
		return false;
	}

	private function getRowCardId(cardId:String):CardRow {
		var id:Int = -1;
		for (row in rows) {
			if (row.cardId == cardId) {
				return row;
			}
		}

		return null;
	}

	private function getDataSourceRow(card:CardData):Dynamic {
		var rowDataItem:Dynamic = {};

		for (cardColumn in cardColumns) {
			var colId:String = cardColumn.colId;
			var dataField:String = cardColumn.dataField;
			var data = Reflect.getProperty(card, dataField);
			// set row data
			Reflect.setField(rowDataItem, colId, data);
		}

		// //static items
		// Reflect.setField(rowDataItem, colId, data);


		return rowDataItem;
	}

	private function onUpdate(settings:SettingsData) {
		updateRows(cardsTable, settings);
	}
}

class CardRow {
	public var rowId:Int;
	public var updated:Bool;

	@:isVar public var rowDataItem(default, default):Dynamic;
	@:isVar public var cardId(default, null):String;

	public function new(rowDataItem:Dynamic, cardId:String) {
		this.rowDataItem = rowDataItem;
		this.cardId = cardId;
	}
}

class CardColumn {
	@:isVar public var titleText(default, null):String;
	@:isVar public var dataField(default, null):String;
	@:isVar public var type(default, null):String;
	@:isVar public var percentWidth(default, null):Float;
	@:isVar public var colId(default, null):String;
	@:isVar public var column(default, null):Column;

	public function new(colId:String, titleText:String, dataField:String, percentWidth:Float, type:String = "") {
		this.titleText = titleText;
		this.dataField = dataField;
		this.type = type;
		this.percentWidth = percentWidth;
		this.colId = colId;
	}

	public function addToTable(table:TableView) {
		/////////
		// var column = table.addColumn(this.colId);
		// column.id = this.colId;
		// column.text = this.titleText;
		// column.width = (table.width / 100) * percentWidth;
		// this.column = column;
	}
}
