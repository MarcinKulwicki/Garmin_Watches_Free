import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

module SobrietyTracker {
    
    const MILESTONES = [
        { :id => 0, :minDays => 0,   :maxDays => 0,   :name => "Day Zero" },
        { :id => 1, :minDays => 1,   :maxDays => 6,   :name => "First Week" },
        { :id => 2, :minDays => 7,   :maxDays => 29,  :name => "First Month" },
        { :id => 3, :minDays => 30,  :maxDays => 89,  :name => "90 Days" },
        { :id => 4, :minDays => 90,  :maxDays => 179, :name => "6 Months" },
        { :id => 5, :minDays => 180, :maxDays => 364, :name => "First Year" },
        { :id => 6, :minDays => 365, :maxDays => 99999, :name => "Beyond Year" }
    ];
    
    // Predefiniowane motywy - użytkownik wybiera tylko ID (1-20)
    const THEMES = {
        // 1. Black (tło: black)
        1 => { :bg => 1, :sobrietyColor => 10, :textColor => 2, :battFull => 10, :battMid => 9, :battLow => 7 },
        
        // 2. Blue Ocean (tło: blue)
        2 => { :bg => 2, :sobrietyColor => 56, :textColor => 2, :battFull => 71, :battMid => 25, :battLow => 11 },
        
        // 3. Green Forest (tło: green)
        3 => { :bg => 3, :sobrietyColor => 47, :textColor => 2, :battFull => 43, :battMid => 25, :battLow => 11 },
        
        // 4. Pink Sunset (tło: pink)
        4 => { :bg => 4, :sobrietyColor => 94, :textColor => 1, :battFull => 88, :battMid => 25, :battLow => 11 },
        
        // 5. Clean Minimal (tło: clean)
        5 => { :bg => 5, :sobrietyColor => 71, :textColor => 2, :battFull => 66, :battMid => 25, :battLow => 11 },
        
        // 6. Gold Elegance (tło: gold)
        6 => { :bg => 6, :sobrietyColor => 29, :textColor => 1, :battFull => 30, :battMid => 25, :battLow => 11 },
        
        // 7. Super Green (tło: supergreen)
        7 => { :bg => 7, :sobrietyColor => 39, :textColor => 2, :battFull => 40, :battMid => 25, :battLow => 11 },
        
        // 8. Pure White (tło: white)
        8 => { :bg => 8, :sobrietyColor => 82, :textColor => 2, :battFull => 71, :battMid => 25, :battLow => 11 },
        
        // 9. Green Red Black (tło: black)
        9 => { :bg => 1, :sobrietyColor => 24, :textColor => 64, :battFull => 64, :battMid => 31, :battLow => 24 },
        
        // 10. Blue Contrast (tło: blue)
        10 => { :bg => 2, :sobrietyColor => 29, :textColor => 1, :battFull => 56, :battMid => 25, :battLow => 11 },
        
        // 11. Royal Blue (tło: green)
        11 => { :bg => 3, :sobrietyColor => 71, :textColor => 1, :battFull => 66, :battMid => 25, :battLow => 11 },
        
        // 12. Sea Green (tło: pink)
        12 => { :bg => 4, :sobrietyColor => 54, :textColor => 1, :battFull => 47, :battMid => 25, :battLow => 11 },
        
        // 13. Deep Pink (tło: clean)
        13 => { :bg => 5, :sobrietyColor => 94, :textColor => 2, :battFull => 88, :battMid => 25, :battLow => 11 },
        
        // 14. Banana Yellow (tło: gold)
        14 => { :bg => 6, :sobrietyColor => 35, :textColor => 1, :battFull => 29, :battMid => 25, :battLow => 11 },
        
        // 15. Turquoise (tło: supergreen)
        15 => { :bg => 7, :sobrietyColor => 58, :textColor => 1, :battFull => 56, :battMid => 25, :battLow => 11 },
        
        // 16. Orchid (tło: white)
        16 => { :bg => 8, :sobrietyColor => 85, :textColor => 2, :battFull => 82, :battMid => 25, :battLow => 11 },
        
        // 17. Pink Power (tło: black)
        17 => { :bg => 1, :sobrietyColor => 94, :textColor => 88, :battFull => 85, :battMid => 25, :battLow => 11 },
        
        // 18. Chocolate (tło: blue)
        18 => { :bg => 2, :sobrietyColor => 30, :textColor => 1, :battFull => 104, :battMid => 25, :battLow => 11 },
        
        // 19. Sky Blue (tło: clean)
        19 => { :bg => 5, :sobrietyColor => 75, :textColor => 2, :battFull => 66, :battMid => 25, :battLow => 11 },
        
        // 20. Violet Rose (tło: white)
        20 => { :bg => 8, :sobrietyColor => 98, :textColor => 2, :battFull => 82, :battMid => 25, :battLow => 11 }
    };

    // Zwraca liczbę pełnych dni trzeźwości
    function getDaysSober() as Number {
        var startMoment = getStartMoment();
        var now = Time.now();
        
        var duration = now.subtract(startMoment);
        var days = duration.value() / 86400; // 86400 sekund = 1 dzień
        
        return days.toNumber();
    }

    // Zwraca aktualny milestone (0-6)
    function getCurrentMilestone() as Number {
        var days = getDaysSober();
        
        for (var i = 0; i < MILESTONES.size(); i++) {
            var milestone = MILESTONES[i];
            if (days >= milestone[:minDays] && days <= milestone[:maxDays]) {
                return milestone[:id];
            }
        }
        
        return 6; // Domyślnie ostatni milestone
    }

    // Zwraca pełną konfigurację motywu dla aktualnego milestone
    function getCurrentTheme() as Dictionary {
        var milestone = getCurrentMilestone();
        
        // Milestone 0 (Day Zero) - zawsze czarny/biały, ale respektujemy wybór użytkownika dla motywu
        if (milestone == 0) {
            return {
                :backgroundId => 0,
                :foregroundColor => 0xFFFFFF,
                :sobrietyColor => 0xFFFFFF,
                :batteryFullColor => 0x008000,
                :batteryMidColor => 0xFFFF12,
                :batteryLowColor => 0x6E0300
            };
        }
        
        // Milestones 1-6 - pobierz wybór użytkownika (Theme_1 do Theme_10)
        var themeChoice = SettingsHelper.getNumberProperty("Milestone" + milestone + "Theme", 1);
        
        // Pobierz predefiniowany motyw
        var theme = THEMES.get(themeChoice);
        if (theme == null) {
            theme = THEMES.get(1); // Fallback do Theme_1
        }
        
        return {
            :backgroundId => theme[:bg],
            :foregroundColor => getColorFromChoice(theme[:textColor]),
            :sobrietyColor => getColorFromChoice(theme[:sobrietyColor]),
            :batteryFullColor => getColorFromChoice(theme[:battFull]),
            :batteryMidColor => getColorFromChoice(theme[:battMid]),
            :batteryLowColor => getColorFromChoice(theme[:battLow])
        };
    }

    // Pobiera kolor z PRESET_COLORS na podstawie wyboru
    function getColorFromChoice(choice as Number) as Number {
        if (choice >= 1 && choice <= 112) {
            return ColorHelper.PRESET_COLORS[choice - 1];
        }
        return 0xFFFFFF; // Domyślnie biały
    }

    // Tworzy i waliduje Moment startu z ustawień użytkownika
    function getStartMoment() as Moment {
        var year = SettingsHelper.getNumberProperty("SobrietyYear", 0);
        var month = SettingsHelper.getNumberProperty("SobrietyMonth", 0);
        var day = SettingsHelper.getNumberProperty("SobrietyDay", 0);
        var hour = SettingsHelper.getNumberProperty("SobrietyHour", 0);
        
        // Jeśli nie ustawiono - zwróć aktualny czas
        if (year == 0 || month == 0 || day == 0) {
            return Time.now();
        }
        
        // Walidacja daty
        if (!isValidDate(year, month, day)) {
            return Time.now();
        }
        
        // Tworzenie Moment
        var options = {
            :year => year,
            :month => month,
            :day => day,
            :hour => hour,
            :minute => 0,
            :second => 0
        };
        
        var startMoment;
        try {
            startMoment = Gregorian.moment(options);
        } catch (e) {
            return Time.now();
        }
        
        // Sprawdź czy data nie jest w przyszłości
        var now = Time.now();
        if (startMoment.greaterThan(now)) {
            return now;
        }
        
        return startMoment;
    }

    // Waliduje datę (sprawdza czy istnieje)
    function isValidDate(year as Number, month as Number, day as Number) as Boolean {
        if (month < 1 || month > 12) { return false; }
        if (day < 1 || day > 31) { return false; }
        
        // Sprawdzamy maksymalną liczbę dni w miesiącu
        var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        
        // Rok przestępny
        if (month == 2 && isLeapYear(year)) {
            daysInMonth[1] = 29;
        }
        
        if (day > daysInMonth[month - 1]) {
            return false;
        }
        
        return true;
    }

    // Sprawdza czy rok jest przestępny
    function isLeapYear(year as Number) as Boolean {
        if (year % 4 != 0) { return false; }
        if (year % 100 != 0) { return true; }
        if (year % 400 != 0) { return false; }
        return true;
    }

    // Zwraca nazwę aktualnego milestone
    function getCurrentMilestoneName() as String {
        var milestone = getCurrentMilestone();
        return MILESTONES[milestone][:name];
    }
}