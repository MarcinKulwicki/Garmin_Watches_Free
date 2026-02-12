import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

module SobrietyAnimator {
    var animationTimer = null;
    var currentAnimatedValue = 0;
    var targetValue = 0;
    var isAnimating = false;
    var animationCallback = null;
    
    const MAX_ANIMATION_DURATION_MS = 1500; // 1.5 sekundy maksymalnie
    const MIN_FRAME_DELAY_MS = 16; // ~60 FPS
    const MAX_FRAME_DELAY_MS = 80; // Najwolniejsza animacja
    
    function startAnimation(targetDays as Number, callback as Method) as Void {
        if (targetDays <= 0) {
            return; // Nie animujemy dla 0 lub ujemnych wartości
        }
        
        stopAnimation(); // Zatrzymaj poprzednią animację jeśli istnieje
        
        currentAnimatedValue = 0;
        targetValue = targetDays;
        isAnimating = true;
        animationCallback = callback;
        
        // Oblicz optymalne tempo animacji
        var frameDelay = calculateFrameDelay(targetDays);
        
        // Tworzymy wrapper callback który wywołuje naszą funkcję
        var timerCallback = new Lang.Method(SobrietyAnimator, :onAnimationTick);
        
        animationTimer = new Timer.Timer();
        animationTimer.start(timerCallback, frameDelay, true);
    }
    
    function stopAnimation() as Void {
        if (animationTimer != null) {
            animationTimer.stop();
            animationTimer = null;
        }
        isAnimating = false;
        animationCallback = null;
    }
    
    function onAnimationTick() as Void {
        if (!isAnimating) {
            stopAnimation();
            return;
        }
        
        // Zwiększ wartość - im bliżej celu, tym mniejszy skok
        var remaining = targetValue - currentAnimatedValue;
        var increment;
        
        if (targetValue <= 30) {
            // Dla małych liczb - po 1
            increment = 1;
        } else if (targetValue <= 100) {
            // Dla średnich - po 2-3
            increment = (remaining > 10) ? 2 : 1;
        } else {
            // Dla dużych - dynamiczny skok
            increment = (remaining / 20).toNumber();
            if (increment < 1) { increment = 1; }
            if (increment > 10) { increment = 10; }
        }
        
        currentAnimatedValue += increment;
        
        // Nie przekraczaj celu
        if (currentAnimatedValue >= targetValue) {
            currentAnimatedValue = targetValue;
            stopAnimation();
        }
        
        // Wywołaj callback aby odświeżyć widok
        if (animationCallback != null) {
            animationCallback.invoke();
        }
    }
    
    function calculateFrameDelay(days as Number) as Number {
        // Oblicz ile klatek potrzebujemy
        var totalFrames;
        
        if (days <= 30) {
            totalFrames = days; // Każdy dzień = 1 klatka
        } else if (days <= 100) {
            totalFrames = 30 + ((days - 30) / 2); // Pierwsze 30 + reszta co 2
        } else {
            totalFrames = 30 + 35 + ((days - 100) / 10); // Pierwsze 30 + 35 + reszta co 10
        }
        
        // Oblicz delay aby zmieścić się w MAX_ANIMATION_DURATION_MS
        var frameDelay = (MAX_ANIMATION_DURATION_MS / totalFrames).toNumber();
        
        // Ogranicz do rozsądnych wartości
        if (frameDelay < MIN_FRAME_DELAY_MS) {
            frameDelay = MIN_FRAME_DELAY_MS;
        } else if (frameDelay > MAX_FRAME_DELAY_MS) {
            frameDelay = MAX_FRAME_DELAY_MS;
        }
        
        return frameDelay;
    }
    
    function getCurrentValue() as Number {
        return currentAnimatedValue;
    }
    
    function isCurrentlyAnimating() as Boolean {
        return isAnimating;
    }
    
    function forceComplete() as Void {
        if (isAnimating) {
            currentAnimatedValue = targetValue;
            stopAnimation();
            if (animationCallback != null) {
                animationCallback.invoke();
            }
        }
    }
}