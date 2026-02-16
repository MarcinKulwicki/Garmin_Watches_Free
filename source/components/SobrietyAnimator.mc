import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

module SobrietyAnimator {
    var animationTimer = null;
    var currentAnimatedValue = 0;
    var targetValue = 0;
    var isAnimating = false;
    var animationCallback = null;
    var milestones = null;
    var currentMilestoneIndex = 0;
    
    const ANIMATION_FRAME_DELAY_MS = 80; // ~12 FPS
    const QUICK_FRAME_DELAY_MS = 120; // Dla małych liczb
    
    function startAnimation(targetDays as Number, callback as Method) as Void {
        if (targetDays <= 0) {
            return;
        }
        
        stopAnimation();
        
        currentAnimatedValue = 0;
        targetValue = targetDays;
        isAnimating = true;
        animationCallback = callback;
        currentMilestoneIndex = 0;
        
        milestones = generateMilestones(targetDays);
        
        var frameDelay = (targetDays <= 20) ? QUICK_FRAME_DELAY_MS : ANIMATION_FRAME_DELAY_MS;
        
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
        milestones = null;
        currentMilestoneIndex = 0;
    }
    
    function onAnimationTick() as Void {
        if (!isAnimating || milestones == null) {
            stopAnimation();
            return;
        }
        
        if (currentMilestoneIndex >= milestones.size()) {
            currentAnimatedValue = targetValue;
            stopAnimation();
            if (animationCallback != null) {
                animationCallback.invoke();
            }
            return;
        }
        
        currentAnimatedValue = milestones[currentMilestoneIndex];
        currentMilestoneIndex++;
        
        if (animationCallback != null) {
            animationCallback.invoke();
        }
    }
    
    function generateMilestones(target as Number) as Array {
        var result = [0];
        
        // 1-10 dni: każdy dzień (0,1,2,3,4...)
        if (target <= 10) {
            for (var i = 1; i <= target; i++) {
                result.add(i);
            }
            return result;
        }
        
        // 11-99 dni: najpierw dziesiątki, potem jedności
        if (target <= 99) {
            var finalTens = (target / 10).toNumber() * 10;
            var finalOnes = target % 10;
            
            // Animuj dziesiątki (10, 20, 30, 40...)
            for (var i = 10; i <= finalTens; i += 10) {
                result.add(i);
            }
            
            // Animuj jedności (jeśli są)
            if (finalOnes > 0) {
                for (var i = 1; i <= finalOnes; i++) {
                    result.add(finalTens + i);
                }
            }
            
            return result;
        }
        
        // 100-999 dni: najpierw setki, potem dziesiątki, potem jedności
        if (target <= 999) {
            var finalHundreds = (target / 100).toNumber() * 100;
            var remainder = target % 100;
            var finalTens = (remainder / 10).toNumber() * 10;
            var finalOnes = remainder % 10;
            
            // Animuj setki (100, 200, 300...)
            for (var i = 100; i <= finalHundreds; i += 100) {
                result.add(i);
            }
            
            // Animuj dziesiątki (finalHundreds + 10, +20, +30...)
            if (finalTens > 0) {
                for (var i = 10; i <= finalTens; i += 10) {
                    result.add(finalHundreds + i);
                }
            }
            
            // Animuj jedności
            if (finalOnes > 0) {
                var base = finalHundreds + finalTens;
                for (var i = 1; i <= finalOnes; i++) {
                    result.add(base + i);
                }
            }
            
            return result;
        }
        
        // 1000+ dni: tysiące, setki, dziesiątki, jedności
        var finalThousands = (target / 1000).toNumber() * 1000;
        var remainder = target % 1000;
        var finalHundreds = (remainder / 100).toNumber() * 100;
        remainder = remainder % 100;
        var finalTens = (remainder / 10).toNumber() * 10;
        var finalOnes = remainder % 10;
        
        // Animuj tysiące
        for (var i = 1000; i <= finalThousands; i += 1000) {
            result.add(i);
        }
        
        // Animuj setki
        if (finalHundreds > 0) {
            for (var i = 100; i <= finalHundreds; i += 100) {
                result.add(finalThousands + i);
            }
        }
        
        // Animuj dziesiątki
        if (finalTens > 0) {
            var base = finalThousands + finalHundreds;
            for (var i = 10; i <= finalTens; i += 10) {
                result.add(base + i);
            }
        }
        
        // Animuj jedności
        if (finalOnes > 0) {
            var base = finalThousands + finalHundreds + finalTens;
            for (var i = 1; i <= finalOnes; i++) {
                result.add(base + i);
            }
        }
        
        // Upewnij się że kończymy na target
        if (result[result.size() - 1] != target) {
            result.add(target);
        }
        
        return result;
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
