package game.states.sub;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
import flixel.FlxState;
import crowbar.display.CrowbarSprite;
import game.components.Score;

class GameOverSubState extends FlxSubState
{
    public var black:FlxSprite;
    public var white:FlxSprite;

    public var playerDyingSprite:CrowbarSprite;
    public var mannySprite:CrowbarSprite;

    public var firedTxt:CrowbarSprite;
    public var deadTxt:CrowbarSprite;

    public var bg:CrowbarSprite;
    public var vignette:CrowbarSprite;

    public var retryTxt:CrowbarSprite;
    public var quitTxt:CrowbarSprite;

    public var sceneStage:Int = 0;
    public var selection:Int = 0;
    public var selectInputEnabled = false;

    public var deadTxtTimer:Float = 0.0;
    public var deadTxtInterval:Float = 0.4;

    public function new()
    {
        super();
    }

    override function create()
    {
        black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);

        bg = new CrowbarSprite(0, 0).loadSprite("images/gameOver/deathScreen_logan");
        bg.scale.set(0.6667, 0.6667);
        bg.updateHitbox();
        bg.setPosition(0, FlxG.height * 1.4);

        vignette = new CrowbarSprite(0, 0).loadSprite("images/gameOver/vignette", true);
        vignette.scale.set(0.6667, 0.6667);
        vignette.updateHitbox();
        vignette.setPosition(0, 0);
        vignette.visible = false;
        vignette.animation.addByPrefix('vignette', 'vignette', 8);
        vignette.animation.play('vignette');

        firedTxt = new CrowbarSprite(0, 0).loadSprite("images/gameOver/fired", true);
        firedTxt.x = (FlxG.width * 0.5) - (firedTxt.width * 0.5);
        firedTxt.y = (FlxG.height * 0.5) - (firedTxt.height * 0.5);
        firedTxt.animation.addByPrefix('fired', 'fired', 8);
        firedTxt.animation.play('fired');

        deadTxt = new CrowbarSprite(0, 0).loadSprite("images/gameOver/dead", true);
        deadTxt.x = (FlxG.width * 0.5) - (deadTxt.width * 0.5);
        deadTxt.y = firedTxt.y + (firedTxt.height * 1.3);
        deadTxt.animation.addByPrefix('dead', 'dead', 8);
        deadTxt.animation.play('dead');
        deadTxt.alpha = 0.0;

        retryTxt = new CrowbarSprite(0, 0).loadSprite("images/gameOver/retry", true);
        retryTxt.x = (FlxG.width * 0.2);
        retryTxt.y = (FlxG.height * 0.8);
        retryTxt.animation.addByPrefix('retry', 'retry', 8);
        retryTxt.animation.play('retry');
        retryTxt.visible = false;

        quitTxt = new CrowbarSprite(0, 0).loadSprite("images/gameOver/quit", true);
        quitTxt.x = (FlxG.width * 0.8 - quitTxt.width);
        quitTxt.y = retryTxt.y;
        quitTxt.animation.addByPrefix('quit', 'quit', 8);
        quitTxt.animation.play('quit');
        quitTxt.visible = false;

        add(black);
        add(bg);
        add(vignette);
        add(firedTxt);
        add(deadTxt);
        add(retryTxt);
        add(quitTxt);
        add(white);

        optionSwitch();

        part2();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(selectInputEnabled)
        {
            if(Controls.UI_RIGHT_P)
                changeSelection(1);
            else if(Controls.UI_LEFT_P)
                changeSelection(-1);

            if(Controls.ACCEPT)
                accept();
            if(Controls.BACK || FlxG.keys.justPressed.ESCAPE)
            {
                quitToMenu();
            }
        }

        deadTxtTimer -= elapsed;
        if(deadTxtTimer < 0) {
            deadTxtTimer += deadTxtInterval + FlxG.random.float(-0.1, 0.1);
            deadTextEffect(elapsed);
        }
    }

    public function part2()
    {
        sceneStage = 2;
        trace("PART 2");

        white.alpha = 1.3;
        FlxTween.tween(white, {alpha: 0.0}, 0.8, {
            onUpdate:function(twn:FlxTween) {
                white.color = FlxColor.fromRGBFloat(1.0, 1.5 * white.alpha, 1.5 * white.alpha, white.alpha);
            }
        });
        vignette.visible = true;
        new FlxTimer().start(1.8, function(tmr:FlxTimer){
            part3();
        });
    }

    public function part3()
    {
        sceneStage = 3;
        trace("PART 3");

        white.visible = false;

        retryTxt.alpha = 0.0;
        quitTxt.alpha = 0.0;
        retryTxt.visible = true;
        quitTxt.visible = true;

        FlxTween.tween(firedTxt, {y: FlxG.height * 0.1}, 1.8, {
            ease: FlxEase.sineInOut, 
            onUpdate: function(twn:FlxTween){
                deadTxt.y = firedTxt.y + (firedTxt.height * 0.85);
            }});
        
        new FlxTimer().start(1.0, function(tmr:FlxTimer){
            FlxTween.tween(deadTxt, {alpha: 1.0}, 1.5);
        });
        FlxTween.tween(bg, {y: 0}, 2.5, {ease: FlxEase.sineOut});
        new FlxTimer().start(2.0, function(tmr:FlxTimer){
            FlxTween.tween(retryTxt, {alpha: 1.0}, 1.0);
            FlxTween.tween(quitTxt, {alpha: 0.5}, 1.0);
            part4();
        });
    }

    public function part4()
    {
        sceneStage = 4;
        selectInputEnabled = true;
    }

    private function deadTextEffect(elapsed:Float)
    {
        deadTxt.angle = FlxG.random.float(-2.0, 2.0);
        deadTxt.x = (FlxG.width * 0.5) - (deadTxt.width * 0.5);
        deadTxt.y = firedTxt.y + (firedTxt.height * 0.85);
        deadTxt.x += FlxG.random.float(-3.0, 3.0);
        deadTxt.y += FlxG.random.float(-3.0, 3.0);
    }

    public function changeSelection(input:Int)
    {
        SoundManager.playSound("tick");
        selection += input;
        if(selection > 1)
            selection = 0;
        if(selection < 0)
            selection = 1;

        optionSwitch();
    }
    
    public function optionSwitch()
    {
        var opts = [retryTxt, quitTxt];
        for(i in 0...opts.length)
        {
            FlxTween.cancelTweensOf(opts[i]);
            FlxTween.tween(opts[i], {alpha: (i == selection ? 1.0 : 0.5)}, 0.6, {
                ease:FlxEase.circOut, 
                onUpdate:function(twn:FlxTween){
                    var p = Math.sqrt(opts[i].alpha);
                    opts[i].scale.set(p, p);
                }});
        }
    }

    public function accept()
    {
        switch(selection)
        {
            case 0:
            {
                SoundManager.playSound("clack");
                retry();
            }
            case 1:
            {
                SoundManager.playSound("cancel");
                quitToMenu();
            }
        }
    }

    public function skipCutscene()
    {

    }

    public function retry()
    {
        Score.clearActive();
        FlxG.switchState(new PlayState());
    }

    public function quitToMenu()
    {
        FlxG.switchState(new MainMenuState());
    }


}