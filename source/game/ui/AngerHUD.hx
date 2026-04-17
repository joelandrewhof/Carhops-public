package game.ui;

import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup;
import game.states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class AngerHUD extends FlxSpriteGroup
{
    public var base:CrowbarSprite;
    public var rageGauge:RageGauge;
    public var angerTextBase:CrowbarSprite;
    public var angerOdometer:Odometer;
    public var showingRage:Bool = true;

    public var startX:Float;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        startX = x;
        base = new CrowbarSprite(0, 0, "images/ui/anger_base");
        add(base);

        rageGauge = new RageGauge(180, 10);
        add(rageGauge);

        angerTextBase = new CrowbarSprite(18, 125, "images/ui/anger_text_base");
        add(angerTextBase);

        angerOdometer = new Odometer(18, 125, "images/ui/anger_text", 4);
        add(angerOdometer);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        rageGauge.percent = PlayState.current.manny.stateManager.rage;

        if(showingRage && rageGauge.percent <= 0.0) {
            rageToggleTween(false);
        }
        else if(!showingRage && rageGauge.percent > 0.0) {
            rageToggleTween(true);
        }

        if(PlayState.current.manny.stateManager.getAngerInt() != angerOdometer.index)
        {
            setAngerOdometer(PlayState.current.manny.stateManager.getAngerInt());
        }
    }

    public function setAngerOdometer(anger:Int)
    {
        angerOdometer.updateIndex(anger);
    }

    public function rageToggleTween(enraged:Bool, ?time:Float = 1.0)
    {
        var newX = (enraged ? startX : startX + 170);
        FlxTween.tween(this, {x: newX}, time, {ease: FlxEase.circOut});
        showingRage = enraged;
    }
}