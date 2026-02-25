package game.ui;

import flixel.input.keyboard.FlxKey;
import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import game.components.Score;

class OrderRating extends FlxTypedSpriteGroup<CrowbarSprite>
{
    public var doubleTriple:CrowbarSprite;
    public var home:CrowbarSprite;
    public var run:CrowbarSprite;

    public var timeBonus:CrowbarSprite;
    public var streakFire:CrowbarSprite;
    public var streakText:CrowbarSprite;

    public var lastCombo:Int;

    public var fadeTween:FlxTween;
    public var landTween:FlxTween;
    public var bonusTweenIn:FlxTween;

    public var spinning:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        directAlpha = true;

        doubleTriple = new CrowbarSprite(0, 0);
        doubleTriple.loadFromYaml("ui/double_triple");

        home = new CrowbarSprite(0, 0);
        home.loadFromYaml("ui/homerun");
        home.animation.play("home-loop");

        run = new CrowbarSprite(190, -85);
        run.loadFromYaml("ui/homerun");
        run.animation.play("run-loop");

        add(doubleTriple);
        add(home);
        add(run);

        doubleTriple.visible = false;
        home.visible = false;
        run.visible = false;

        streakText = new CrowbarSprite(0, 50, "images/ui/streak_text");

        streakFire = new CrowbarSprite(0, 50);
        streakFire.loadSprite("images/ui/streak_fire", true);
        streakFire.addAtlasAnim("loop", "streak_fire", 12, true);
        streakFire.playAnim("loop");

        timeBonus = new CrowbarSprite(0, 0, "images/ui/time_bonus");

        add(timeBonus);
        add(streakFire);
        add(streakText);

        timeBonus.visible = false;
        streakFire.visible = false;
        streakText.visible = false;

    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateRatingAnimation();

        if(spinning) 
        {
            if(doubleTriple.angularVelocity < 1000) {
                doubleTriple.angularVelocity += 5000 * elapsed;
            }
            if(doubleTriple.angularVelocity > 1000 && doubleTriple.angle > 80 && doubleTriple.angle < 100) {
                animTripleFinish();
            }
        }

        updateSecondaries();

        lastCombo = Score.combo;
    }

    public function positionElements(x:Float, y:Float)
    {
        this.setPosition(x, y);
        doubleTriple.setPosition(0 + x, 0 + y);
        home.setPosition(0 + x, 0 + y);
        run.setPosition(home.x + 190, home.y - 85);

        timeBonus.setPosition(80 + x, 130 + x);
        streakText.setPosition(timeBonus.x + 70, timeBonus.y + 55);
        streakFire.setPosition(streakText.x - 30, streakText.y - 55);
    }

    public function updateRatingAnimation()
    {
        if(lastCombo < Score.combo) //if combo increased, add it
        {
            bonusTween();
            switch(Score.combo)
            {
                case 1: {
                        animStartup();
                        positionElements(100, 400);
                    }
                case 2:
                    animDouble();
                case 3:
                    animTripleStart();
                case 4:
                    animHomerunStart();
            }
            if(Score.combo > 4) {
                animHomerunBump();
            }
        }
        else if(lastCombo > Score.combo) //break combo
        {
            fadeOut();
        }
    }

    public function updateSecondaries()
    {
        animTimeBonus();
        animStreakBonus();
    }

    public function bonusTween()
    {
        bonusTweenIn = FlxTween.num(0.0, 1.2, 0.3, {
            ease:FlxEase.circOut
        }, _bonusNumTwnFunc);
    }

    private function _bonusNumTwnFunc(num:Float){
        //these if's will make it so it doesn't fade back in on subsequent combos.
        if(timeBonus.alpha < num)
            timeBonus.alpha = num;
        if(streakText.alpha < num)
            streakText.alpha = num;
        if(streakFire.alpha < num )
            streakFire.alpha = num;
        timeBonus.x = this.x + 80 - (50 * num);
        streakText.x = this.x + 200 - (75 * num);
        streakFire.x = streakText.x - 30;
    }

    public function animTimeBonus()
    {
        if(Score.combo > 0 && Score.lastTimeBonus > 0)
        {
            if(!timeBonus.visible) {
                timeBonus.visible = true;

            }
            
        }
        else if(Score.lastTimeBonus <= 0)
        {
            timeBonus.visible = false;
            timeBonus.alpha = 0.0;
        }
    }

    public function animStreakBonus()
    {
        if(Score.combo > 0 && Score.lastStreakBonus > 0)
        {
            streakText.visible = true;
            streakFire.visible = true;

            /*
            if(streakTweenIn == null || !streakTweenIn.active)
            {
                streakTweenIn = FlxTween.tween(streakText, {x: streakText.x - 50, alpha: 1.0}, 0.3);
            }
            */
        }
        else if(Score.lastStreakBonus <= 0)
        {
            streakText.visible = false;
            streakFire.visible = false;
            streakText.alpha = 0.0;
            streakFire.alpha = 0.0;
        }
    }

    public function animClear()
    {

    }

    public function invisibleAll(?twn:FlxTween)
    {
        home.visible = false;
        run.visible = false;
        doubleTriple.visible = false;
        streakText.visible = false;
        streakFire.visible = false;
        timeBonus.visible = false;
        streakText.alpha = 0.0;
        streakFire.alpha = 0.0;
        timeBonus.alpha = 0.0;
    }

    public function fadeOut()
    {
        fadeTween = FlxTween.tween(this, {alpha: 0.0}, 0.3, {onComplete: invisibleAll});
    }

    public function animStartup()
    {
        if(fadeTween != null)
            fadeTween.cancel();
        this.alpha = 1.0;
    }

    public function animDouble()
    {
        trace("double!");
        animStartup();
        doubleTriple.angle = 0;

        doubleTriple.visible = true;
        doubleTriple.animation.play("double-in");
        doubleTriple.animation.finishCallback = function(name:String) {
            doubleTriple.animation.play("double-loop");};
        
        home.visible = false;
        run.visible = false;
    }

    public function animTripleStart()
    {
        trace("triple!!");
        animStartup();
        doubleTriple.visible = true;
        spinning = true;
    }

    public function animTripleFinish()
    {
        spinning = false;
        doubleTriple.angularVelocity = 0;
        doubleTriple.angle = 0;

        doubleTriple.animation.play("triple-in");
        doubleTriple.animation.finishCallback = function(name:String) {
            doubleTriple.animation.play("triple-loop");};
        
        home.visible = false;
        run.visible = false;
    }

    public function animHomerunStart()
    {
        trace("homerun!!");
        animStartup();
        home.visible = true;
        run.visible = true;

        home.animation.play("home-loop");
        run.animation.play("run-loop");

        home.scale.set(1.2, 1.2);
        run.scale.set(1.2, 1.2);

        FlxG.sound.play(AssetHelper.getAsset("audio/sfx/homerun_bat.ogg", SOUND), 0.8);

        landTween = FlxTween.num(1.2, 0.7, 0.25, {ease: FlxEase.circIn, onComplete: animHomerunFinish}, _landTweenFunc);
        
    }

    private function _landTweenFunc(value:Float) {
        home.scale.set(value, value);
        run.scale.set(value, value);
    }

    public function animHomerunFinish(twn:FlxTween)
    {
        animHomerunBump();

        //camera shake
        this.camera.shake(0.008, 0.2, function() {
            this.camera.shake(0.002, 0.2, function() {
                this.camera.shake(0.0004, 0.3);
            });
        });

        doubleTriple.visible = false;
    }

    public function animHomerunBump()
    {
        //animations
        home.animation.play("home-bump");
        home.animation.finishCallback = function(name:String) {
            home.animation.play("home-loop");};

        run.animation.play("run-bump");
        run.animation.finishCallback = function(name:String) {
            run.animation.play("run-loop");};
    }
}