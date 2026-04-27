package game.states.sub;

import flixel.util.FlxTimer;
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

    override function create()
    {
        black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);

        bg = new CrowbarSprite(0, 0, "gameOver/deathScreen_logan");
        bg.y = FlxG.height * 1.4;

        vignette = new CrowbarSprite(0, 0, "gameOver/vignette");
        vignette.scale.set(0.6667, 0.6667);
        vignette.visible = false;

        firedTxt = new CrowbarSprite(0, 0, "gameOver/fired");
        firedTxt.x = (FlxG.width * 0.5) - (firedTxt.width * 0.5);
        firedTxt.y = (FlxG.height * 0.5) - (firedTxt.height * 0.5);

        deadTxt = new CrowbarSprite(0, 0, "gameOver/dead");
        deadTxt.x = (FlxG.width * 0.5) - (deadTxt.width * 0.5);
        deadTxt.y = firedTxt.y + (firedTxt.height * 1.3);

        retryTxt = new CrowbarSprite(0, 0, "gameOver/retry");

        quitTxt = new CrowbarSprite(0, 0, "gameOver/quit");


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

    public function part2()
    {
        white.alpha = 1.0;
        FlxTween.tween(white, {alpha: 0.0, green: 0.0, blue: 0.0}, 0.8);
        vignette.visible = true;
        new FlxTimer().start(1.0, function(tmr:FlxTimer){
            part3();
        });
    }

    public function part3()
    {
        FlxTween.tween(firedTxt, {y: FlxG.height * 0.1}, 1.0, {
            ease: FlxEase.circInOut, 
            onUpdate: function(twn:FlxTween){
                deadTxt.y = firedTxt.y + (firedTxt.height * 1.3);
            }});
        FlxTween.tween(deadTxt, {alpha: 1.0}, 1.0, {ease: FlxEase.circInOut});
        FlxTween.tween(bg, {y: 0}, 1.4);
        new FlxTimer().start(0.5, function(tmr:FlxTimer){
            FlxTween.tween(retryTxt, {alpha: 1.0}, 0.5);
            FlxTween.tween(quitTxt, {alpha: 1.0}, 0.5);
        });
    }

    public function part4()
    {

    }


}