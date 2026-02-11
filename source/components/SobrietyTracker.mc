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
        // Podstawowe motywy (1-10)
        1 => { :bg => 1, :sobrietyColor => 30, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Gold accent (zmienione z Blue)
        2 => { :bg => 2, :sobrietyColor => 43, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Lime Green accent
        3 => { :bg => 3, :sobrietyColor => 29, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Yellow accent
        4 => { :bg => 4, :sobrietyColor => 25, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Orange accent
        5 => { :bg => 1, :sobrietyColor => 82, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Purple accent
        6 => { :bg => 2, :sobrietyColor => 66, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Blue accent (przeniesione tutaj)
        7 => { :bg => 3, :sobrietyColor => 11, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Red accent
        8 => { :bg => 4, :sobrietyColor => 93, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Magenta accent
        9 => { :bg => 1, :sobrietyColor => 56, :textColor => 1, :battFull => 40, :battMid => 30, :battLow => 11 },  // Cyan accent
        10 => { :bg => 2, :sobrietyColor => 1, :textColor => 2, :battFull => 66, :battMid => 82, :battLow => 11 }, // Light mode (White text on dark)
        
        // Dodatkowe motywy (11-20)
        11 => { :bg => 3, :sobrietyColor => 71, :textColor => 1, :battFull => 66, :battMid => 56, :battLow => 82 }, // Royal Blue
        12 => { :bg => 4, :sobrietyColor => 54, :textColor => 1, :battFull => 40, :battMid => 43, :battLow => 29 }, // Sea Green
        13 => { :bg => 1, :sobrietyColor => 94, :textColor => 1, :battFull => 93, :battMid => 82, :battLow => 11 }, // Deep Pink
        14 => { :bg => 2, :sobrietyColor => 36, :textColor => 1, :battFull => 29, :battMid => 25, :battLow => 11 }, // Banana Yellow
        15 => { :bg => 3, :sobrietyColor => 58, :textColor => 1, :battFull => 56, :battMid => 66, :battLow => 82 }, // Turquoise
        16 => { :bg => 4, :sobrietyColor => 85, :textColor => 1, :battFull => 82, :battMid => 93, :battLow => 94 }, // Orchid
        17 => { :bg => 1, :sobrietyColor => 48, :textColor => 2, :battFull => 40, :battMid => 29, :battLow => 11 }, // Lawn Green (light bg)
        18 => { :bg => 2, :sobrietyColor => 104, :textColor => 1, :battFull => 101, :battMid => 25, :battLow => 11 }, // Chocolate
        19 => { :bg => 3, :sobrietyColor => 75, :textColor => 2, :battFull => 66, :battMid => 56, :battLow => 82 }, // Sky Blue (light bg)
        20 => { :bg => 4, :sobrietyColor => 98, :textColor => 1, :battFull => 93, :battMid => 94, :battLow => 11 }  // Pale Violet Red
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
        var minute = SettingsHelper.getNumberProperty("SobrietyMinute", 0);
        
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
            :minute => minute,
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