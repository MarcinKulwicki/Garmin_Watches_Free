import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class NukePip_FreeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        initializeDefaultDate();
    }

    function initializeDefaultDate() as Void {
        var year = SettingsHelper.getNumberProperty("SobrietyYear", 0);
        var month = SettingsHelper.getNumberProperty("SobrietyMonth", 0);
        var day = SettingsHelper.getNumberProperty("SobrietyDay", 0);
        
        var isInvalid = (year == 0 || month == 0 || day == 0) || 
                        !isValidDate(year, month, day);
        
        if (isInvalid) {
            var now = Time.now();
            var today = Gregorian.info(now, Time.FORMAT_SHORT);
            
            Application.Properties.setValue("SobrietyYear", today.year);
            Application.Properties.setValue("SobrietyMonth", today.month);
            Application.Properties.setValue("SobrietyDay", today.day);
            Application.Properties.setValue("SobrietyHour", today.hour);
            Application.Properties.setValue("SobrietyMinute", today.min);
        }
    }

    function isValidDate(year as Number, month as Number, day as Number) as Boolean {
        if (month < 1 || month > 12) { return false; }
        if (day < 1 || day > 31) { return false; }
        
        var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        if (month == 2 && isLeapYear(year)) {
            daysInMonth[1] = 29;
        }
        
        if (day > daysInMonth[month - 1]) {
            return false;
        }
        
        return true;
    }

    function isLeapYear(year as Number) as Boolean {
        if (year % 4 != 0) { return false; }
        if (year % 100 != 0) { return true; }
        if (year % 400 != 0) { return false; }
        return true;
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new NukePip_FreeView() ];
    }

    function onSettingsChanged() as Void {
        BackgroundManager.clearCache();
        WatchUi.requestUpdate();
    }

}

function getApp() as NukePip_FreeApp {
    return Application.getApp() as NukePip_FreeApp;
}