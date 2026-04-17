package game.ui;

import flixel.group.FlxSpriteGroup;
import game.ui.*;

class CarhopHUD extends FlxSpriteGroup
{
    public var invtHUD:InventoryHUD;
    //public var scoreHUD:ScoreHUD;
    public var staminaBar:StaminaBar;
    public var tipsHUD:TipsHUD;
    public var orderRating:OrderRating;
    public var angerHUD:AngerHUD;
    public var timeHUD:TimeHUD;

    public function new()
    {
        super(0, 0);
        invtHUD = new InventoryHUD(FlxG.width - 130, 30);
        add(invtHUD);

        staminaBar = new StaminaBar(50, 650);
        staminaBar.x = ((FlxG.width * 0.5) - (staminaBar.width * 0.5));
        add(staminaBar);

        tipsHUD = new TipsHUD(40, 560);
        add(tipsHUD);
        tipsHUD.numWhole.updateNumbers();
        tipsHUD.numDec.updateNumbers();

        orderRating = new OrderRating(150, 450);
        add(orderRating);

        angerHUD = new AngerHUD(0, 0);
        angerHUD.x = FlxG.width - angerHUD.base.width;
        angerHUD.y = FlxG.height - angerHUD.base.height;
        angerHUD.rageGauge.updateNeedlePosition();
        angerHUD.startX = angerHUD.x;
        angerHUD.rageToggleTween(false, 0.01);
        add(angerHUD);

        timeHUD = new TimeHUD();
        add(timeHUD);
    }
}