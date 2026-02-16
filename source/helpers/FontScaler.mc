import Toybox.Graphics;
import Toybox.Application;
import Toybox.Lang;

module FontScaler {
    // Przeskalowane czcionki jako osobne zmienne
    var fontLarge = null;
    var fontMedium = null;
    var fontSmall = null;
    
    var currentWidth = 0;
    var currentHeight = 0;
    
    // Ładuje odpowiednie czcionki dla danej rozdzielczości
    function loadScaledFonts(width as Number, height as Number) as Void {
        currentWidth = width;
        currentHeight = height;
        
        // Używamy mniejszego wymiaru jako bazy
        var screenSize = (width < height) ? width : height;
        
        // Dobieramy czcionki na podstawie rozmiaru ekranu
        if (screenSize <= 395) {
            // 390x390 - małe ekrany (Venu 3S, Approach S50, etc.)
            fontLarge = Application.loadResource(Rez.Fonts.Orbitron70);   // 70pt dla czasu
            fontMedium = Application.loadResource(Rez.Fonts.Orbitron40);  // 40pt dla daty
            fontSmall = Application.loadResource(Rez.Fonts.Orbitron30);   // 30pt dla reszty
        }
        else if (screenSize <= 420) {
            // 416x416 - średnie ekrany (Venu 3, Venu 2S, FR165, etc.)
            fontLarge = Application.loadResource(Rez.Fonts.Orbitron85);   // 85pt dla czasu
            fontMedium = Application.loadResource(Rez.Fonts.Orbitron52);  // 52pt dla daty
            fontSmall = Application.loadResource(Rez.Fonts.Orbitron40);   // 40pt dla reszty
        }
        else if (screenSize <= 460) {
            // 454-456x456 - duże ekrany (Venu 2, Epix 2, FR265, etc.)
            fontLarge = Application.loadResource(Rez.Fonts.Orbitron102);  // 102pt dla czasu
            fontMedium = Application.loadResource(Rez.Fonts.Orbitron52);  // 52pt dla daty
            fontSmall = Application.loadResource(Rez.Fonts.Orbitron40);   // 40pt dla reszty
        }
        else if (screenSize <= 475) {
            // 471x471 - bardzo duże ekrany (Epix 2 Pro 47mm, FR965, etc.)
            fontLarge = Application.loadResource(Rez.Fonts.Orbitron102);  // 102pt dla czasu
            fontMedium = Application.loadResource(Rez.Fonts.Orbitron70);  // 70pt dla daty
            fontSmall = Application.loadResource(Rez.Fonts.Orbitron52);   // 52pt dla reszty
        }
        else {
            // 502x502+ - ekstra duże ekrany (Epix 2 Pro 51mm)
            fontLarge = Application.loadResource(Rez.Fonts.Orbitron102);  // 102pt dla czasu
            fontMedium = Application.loadResource(Rez.Fonts.Orbitron85);  // 85pt dla daty
            fontSmall = Application.loadResource(Rez.Fonts.Orbitron70);   // 70pt dla reszty
        }
    }
    
    // Zwraca odpowiednią czcionkę dla danego typu
    function getFontForSize(dc as Dc, fontType as Symbol) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Jeśli rozdzielczość się zmieniła, przeładuj czcionki
        if (width != currentWidth || height != currentHeight) {
            loadScaledFonts(width, height);
        }
        
        // Zwróć odpowiednią czcionkę
        if (fontType == :large) {
            return fontLarge;
        } else if (fontType == :medium) {
            return fontMedium;
        } else {
            return fontSmall;
        }
    }
    
    // Oblicza przeskalowany margines dla pól bocznych
    function getScaledMargin(dc as Dc, baseMargin as Number) as Number {
        var screenSize = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() : dc.getHeight();
        
        // Skalujemy margines proporcjonalnie do rozmiaru ekranu
        // Baza: 416x416 = margin 25
        var scale = screenSize.toFloat() / 416.0;
        var scaled = (baseMargin * scale).toNumber();
        
        // Minimalny margines
        if (scaled < 15) { scaled = 15; }
        // Maksymalny margines
        if (scaled > 35) { scaled = 35; }
        
        return scaled;
    }
}