import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

class NukePip_FreeView extends WatchUi.WatchFace {
    private var fontRegular;
    private var fontSmall;
    private var font40;
    private var currentFont = 1;
    private var isLowPowerMode = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        loadFonts();
    }

    function loadFonts() as Void {
        var choice = SettingsHelper.getNumberProperty("FontChoice", 1);
        currentFont = choice;
        
        fontRegular = Application.loadResource(Rez.Fonts.OrbitronRegular);
        fontSmall = Application.loadResource(Rez.Fonts.OrbitronSmall);
        font40 = Application.loadResource(Rez.Fonts.Orbitron40);
    }

    function onUpdate(dc as Dc) as Void {
        var fontChoice = SettingsHelper.getNumberProperty("FontChoice", 1);
        if (fontChoice != currentFont) { 
            loadFonts(); 
        }

        if (isLowPowerMode) {
            drawLowPowerMode(dc);
            return;
        }

        // Rysujemy tło z aktualnego motywu milestone
        BackgroundManager.drawBackground(dc);
        
        // Rysujemy sekundnik z kolorami baterii z motywu
        SecondsIndicator.draw(dc);
        
        var centerX = dc.getWidth() / 2;
        
        // GÓRNY - Data
        FieldRenderer.drawField(dc, "Upper", centerX, dc.getHeight() / 7, 
                                font40, Graphics.TEXT_JUSTIFY_CENTER);
        
        // ŚRODEK - Czas
        FieldRenderer.drawField(dc, "Middle", centerX, dc.getHeight() * 4 / 10, 
                                fontRegular, Graphics.TEXT_JUSTIFY_CENTER);
        
        // DÓŁ - Kroki
        FieldRenderer.drawField(dc, "Lower", centerX, dc.getHeight() * 13 / 16, 
                                fontSmall, Graphics.TEXT_JUSTIFY_CENTER);
        
        // LEWA STRONA - Dni trzeźwości
        FieldRenderer.drawSideField(dc, "Left", dc.getHeight() * 6 / 10, true, fontSmall);
        
        // PRAWA STRONA - Temperatura lub Powiadomienia (wybór użytkownika)
        FieldRenderer.drawSideField(dc, "Right", dc.getHeight() * 6 / 10, false, fontSmall);
    }

    function drawLowPowerMode(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var timeString = DataHelper.getTimeString();
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, fontRegular, timeString, 
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        isLowPowerMode = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        isLowPowerMode = true;
        WatchUi.requestUpdate();
    }
}