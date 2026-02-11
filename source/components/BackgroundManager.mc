import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

module BackgroundManager {
    
    const BG_TYPE_IMAGE_MAX = 13;
    const BG_TYPE_SOLID = 14;
    
    var cachedBitmap = null;
    var cachedBitmapId = -1;
    
    function drawBackground(dc as Dc) as Void {
        // Pobieramy tło z aktualnego motywu milestone
        var theme = SobrietyTracker.getCurrentTheme();
        var bgId = theme[:backgroundId];
        
        // bgId == 0 oznacza czysty czarny kolor (Day Zero)
        if (bgId == 0) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.clear();
            return; // WAŻNE - nie wykonuj drawBitmapBackground!
        }
        
        drawBitmapBackground(dc, bgId);
    }
    
    function drawBitmapBackground(dc as Dc, bgId as Number) as Void {
        if (cachedBitmapId != bgId || cachedBitmap == null) {
            cachedBitmap = loadBackgroundBitmap(bgId);
            cachedBitmapId = bgId;
        }
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if (cachedBitmap != null) {
            var x = (dc.getWidth() - cachedBitmap.getWidth()) / 2;
            var y = (dc.getHeight() - cachedBitmap.getHeight()) / 2;
            dc.drawBitmap(x, y, cachedBitmap);
        }
    }
    
    function loadBackgroundBitmap(bgId as Number) {
        switch (bgId) {
            case 1: return Application.loadResource(Rez.Drawables.Background1);
            case 2: return Application.loadResource(Rez.Drawables.Background2);
            case 3: return Application.loadResource(Rez.Drawables.Background3);
            case 4: return Application.loadResource(Rez.Drawables.Background4);
            default: return Application.loadResource(Rez.Drawables.Background1);
        }
    }
    
    function clearCache() as Void {
        cachedBitmap = null;
        cachedBitmapId = -1;
    }
}