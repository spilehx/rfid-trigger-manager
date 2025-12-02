package spilehx.rfidtriggerserver.managers.serverviewmanager;

import spilehx.config.RFIDTriggerAdminImg;
import spilehx.rfidtriggerserver.managers.ServerViewManager.ServerViewPage;

@:xml('
    <box>
  		<hbox id="logoContainer" width="30%" height="30%" horizontalAlign="center" verticalAlign="center">
            <image id="logoImg" height="100%" width ="100%" horizontalAlign="center" verticalAlign="center" scaleMode="fitheight" />
        </hbox>  
    </box>
')
class LogoSplashServerViewPage extends ServerViewPage {
	private static final WINDOW_W_CENT:Int = 20;
	private static final WINDOW_H_CENT:Int = 30;

	override private function setupContent() {
		logoImg.resource = RFIDTriggerAdminImg.getBitmapData(RFIDTriggerAdminImg.NEW_LOGO_IMG);
		setWindowSizeToPercent(WINDOW_W_CENT,WINDOW_H_CENT);	
	}
}