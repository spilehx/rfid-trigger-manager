package spilehx.rfidtriggeradmin.page.components;

import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.containers.ScrollView;
import spilehx.rfidtriggeradmin.page.components.cardslistcomponents.CardListRow;
import haxe.ui.events.UIEvent;
import spilehx.rfidtriggerserver.managers.settings.CardData;
import spilehx.rfidtriggerserver.managers.settings.SettingsData;
import haxe.ui.containers.Box;

@:xml('
   	<box width="100%" height="100%" >
	 	<vbox id="tableContainer" width="100%" height="100%" >
			<hbox id="headerRow" horizontalAlign="center" width="95%" hidden="true">
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="left" height="100%" width="100%" text="ID" style="font-size: 18px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Name" style="font-size: 18px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Active" style="font-size: 18px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text="Command" style="font-size: 18px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="center" horizontalAlign="center" height="100%" width="100%" text="Action" style="font-size: 18px;font-bold: true;"/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
				<box width="100%" height="100%">
					<label textAlign="left" horizontalAlign="center" height="100%" width="100%" text=""/>
				</box>
			</hbox>
			<scrollview id="cardScrollView" width="100%" contentWidth="100%" hidden="true"/>
		
		</vbox>
		<vbox id="loadingContent" width="100%" horizontalAlign="center" verticalAlign="center">
			<spinner horizontalAlign="center" />
			<label textAlign="center" horizontalAlign="center" width="100%" id="waitingLabel"/>
		</vbox>	
	</box>
')
class CardsListSection extends Box {
	private static final COL_WIDTHS:Array<Int> = [5, 10, 15, 5, 30, 20, 5, 5, 5];

	private var cardListRows:Array<CardListRow>;

	public function new() {
		super();
		cardListRows = new Array<CardListRow>();
		this.registerEvent(UIEvent.SHOWN, onShown);

	
		//TEST

		var tot:Int = 0;
		for(v in COL_WIDTHS){
			tot += v;
		}

		LOG("TOTAL COLS---> "+tot);


	}

	private function onShown(e) {
		setup();
		RFIDTriggerAdminConfigManager.instance.registerSettingUpdate(onUpdate);
	}

	private function setup() {
		cardScrollView.borderSize = 0;
		headerRow.height = getRowHeight()*.5;
		this.backgroundColor = RFIDTriggerAdminSettings.SECTION_BG_COLOUR;
		cardScrollView.backgroundColor = this.backgroundColor;
		waitingLabel.text = RFIDTriggerAdminText.CARDLIST_SECTION_WAITING_FOR_LOAD;
	}

	private function onResize(e) {
		// LOG("ON onResize     ---");
	}

	private function onUpdate(settings:SettingsData) {
		if (settings.cards.length > 0) {
			if (loadingContent.parentComponent != null) { // remove loader if there
				loadingContent.parentComponent.removeComponent(loadingContent);
				headerRow.hidden = false;
				cardScrollView.hidden = false;
			}
			populateRows(settings);
		}
	}

	private function populateRows(settings:SettingsData) {
		var cards:Array<CardData> = settings.cards;

		for (card in cards) {
			var cardListRow:CardListRow = getRowById(card.id);
			if (cardListRow == null) {
				cardListRow = addCardListRow(card);
			}
			cardListRow.card = card;
			cardListRow.update();
		}

		cardScrollView.height = getRowHeight() * RFIDTriggerAdminSettings.CARDLIST_SECTION_VISIBLE_ROWS;
		updateColWidths();
	}

	private function updateColWidths() {
		for (i in 0...headerRow.childComponents.length) {
			if (i < COL_WIDTHS.length - 1) {
				var ch:Component = headerRow.childComponents[i];
				ch.percentWidth = COL_WIDTHS[i];
			}
		}

		for (cardListRow in cardListRows) {
			cardListRow.updateColWidths(COL_WIDTHS);
		}
	}

	private function addCardListRow(card:CardData):CardListRow {
		var cardListRow:CardListRow = new CardListRow(card);
		cardListRows.push(cardListRow);

		cardScrollView.addComponent(cardListRow);
		cardListRow.height = getRowHeight();
		return cardListRow;
	}

	private function getRowById(cardId:String):CardListRow {
		for (cardListRow in cardListRows) {
			if (cardListRow.cardId == cardId) {
				return cardListRow;
			}
		}

		return null;
	}

	private function getRowHeight():Float {
		return (tableContainer.height / (RFIDTriggerAdminSettings.CARDLIST_SECTION_VISIBLE_ROWS + 1)); // +1 to accomadate header
	}
}
