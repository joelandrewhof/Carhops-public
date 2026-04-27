package game.states.sub;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
import flixel.FlxState;
import crowbar.display.CrowbarSprite;

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
        retryTxt.alpha = 0.0;

        quitTxt = new CrowbarSprite(0, 0).loadSprite("images/gameOver/quit", true);
        quitTxt.x = (FlxG.width * 0.8 - quitTxt.width);
        quitTxt.y = retryTxt.y;
        quitTxt.animation.addByPrefix('quit', 'quit', 8);
        quitTxt.animation.play('quit');
        quitTxt.alpha = 0.0;

        add(black);
        add(bg);
        add(vignette);
        add(firedTxt);
        add(deadTxt);
        add(retryTxt);
        add(quitTxt);
        add(white);

        part2();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function part2()
    {
        white.alpha = 1.3;
        FlxTween.tween(white, {alpha: 0.0}, 0.8, {
            onUpdate:function(twn:FlxTween) {
                white.color = FlxColor.fromRGBFloat(1.0, 2 * white.alpha, 2 * white.alpha, white.alpha);
            }
        });
        vignette.visible = true;
        trace("PART 2");
        new FlxTimer().start(1.8, function(tmr:FlxTimer){
            part3();
        });
    }

    public function part3()
    {
        trace("PART 3");
        white.visible = false;
        FlxTween.tween(firedTxt, {y: FlxG.height * 0.1}, 1.8, {
            ease: FlxEase.sineInOut, 
            onUpdate: function(twn:FlxTween){
                deadTxt.y = firedTxt.y + (firedTxt.height * 0.85);
            }});
        
        new FlxTimer().start(1.0, function(tmr:FlxTimer){
            FlxTween.tween(deadTxt, {alpha: 1.0}, 1.5);
        });
        FlxTween.tween(bg, {y: 0}, 1.4, {ease: FlxEase.sineOut});
        new FlxTimer().start(2.0, function(tmr:FlxTimer){
            FlxTween.tween(retryTxt, {alpha: 1.0}, 1.0);
            FlxTween.tween(quitTxt, {alpha: 1.0}, 1.0);
        });
    }

    public function part4()
    {

    }


}