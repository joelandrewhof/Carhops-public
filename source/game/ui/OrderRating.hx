package game.ui;

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

    public var lastCombo:Int;

    public var fadeTween:FlxTween;
    public var landTween:FlxTween;

    public var spinning:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

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

        lastCombo = Score.combo;
    }

    public function updateRatingAnimation()
    {
        if(lastCombo < Score.combo) //if combo increased, add it
        {
            switch(Score.combo)
            {
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

    public function animClear()
    {

    }

    public function fadeOut()
    {
        fadeTween = FlxTween.tween(this, {alpha: 0.0}, 0.3);
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