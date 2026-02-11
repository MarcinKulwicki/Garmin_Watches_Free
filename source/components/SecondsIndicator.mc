import Toybox.Graphics;
import Toybox.System;
import Toybox.Math;
import Toybox.Lang;

module SecondsIndicator {
    const TICK_LENGTH = 12;
    const TICK_WIDTH = 4;
    const TICK_OVERFLOW = 10;
    const MAX_TICKS = 60;

    function draw(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var tickCount = clockTime.sec + 1;
        
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();
        
        // Pobieramy kolor z aktualnego motywu
        var theme = SobrietyTracker.getCurrentTheme();
        var tickColor = getBatteryColorFromTheme(battery, theme);
        
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var outerRadius = dc.getWidth() / 2 + TICK_OVERFLOW;
        var innerRadius = outerRadius - TICK_LENGTH - TICK_OVERFLOW;
        
        dc.setColor(tickColor, Graphics.COLOR_TRANSPARENT);
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        
        for (var i = 0; i < tickCount; i++) {
            drawTick(dc, centerX, centerY, outerRadius, innerRadius, i);
        }
        
        if (dc has :setAntiAlias) { dc.setAntiAlias(false); }
    }

    function drawTick(dc as Dc, cx as Number, cy as Number, 
                      outerR as Number, innerR as Number, index as Number) as Void {
        var angle = -90 + (index * 360.0 / MAX_TICKS);
        var angleRad = Math.toRadians(angle);
        var cosA = Math.cos(angleRad);
        var sinA = Math.sin(angleRad);
        
        var outerX = cx + (outerR * cosA);
        var outerY = cy + (outerR * sinA);
        var innerX = cx + (innerR * cosA);
        var innerY = cy + (innerR * sinA);
        
        var perpX = sinA * TICK_WIDTH / 2;
        var perpY = -cosA * TICK_WIDTH / 2;
        
        dc.fillPolygon([
            [outerX - perpX, outerY - perpY],
            [outerX + perpX, outerY + perpY],
            [innerX + perpX, innerY + perpY],
            [innerX - perpX, innerY - perpY]
        ]);
    }

    // Zwraca kolor baterii z motywu (z interpolacją)
    function getBatteryColorFromTheme(batteryPercent as Number, theme as Dictionary) as Number {
        var colorFull = theme[:batteryFullColor];
        var colorMid = theme[:batteryMidColor];
        var colorLow = theme[:batteryLowColor];
        
        if (batteryPercent >= 30) {
            var ratio = (100 - batteryPercent) / 70.0;
            return interpolateColor(colorFull, colorMid, ratio);
        } else {
            var ratio = (30 - batteryPercent) / 30.0;
            return interpolateColor(colorMid, colorLow, ratio);
        }
    }

    // Interpolacja między dwoma kolorami
    function interpolateColor(color1 as Number, color2 as Number, ratio as Float) as Number {
        var r1 = (color1 >> 16) & 0xFF;
        var g1 = (color1 >> 8) & 0xFF;
        var b1 = color1 & 0xFF;
        
        var r2 = (color2 >> 16) & 0xFF;
        var g2 = (color2 >> 8) & 0xFF;
        var b2 = color2 & 0xFF;
        
        var r = (r1 + ((r2 - r1) * ratio)).toNumber();
        var g = (g1 + ((g2 - g1) * ratio)).toNumber();
        var b = (b1 + ((b2 - b1) * ratio)).toNumber();
        
        if (r > 255) { r = 255; } else if (r < 0) { r = 0; }
        if (g > 255) { g = 255; } else if (g < 0) { g = 0; }
        if (b > 255) { b = 255; } else if (b < 0) { b = 0; }
        
        return (r << 16) | (g << 8) | b;
    }
}