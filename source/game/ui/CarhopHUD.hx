package game.ui;

import flixel.group.FlxSpriteGroup;
import game.ui.*;

class CarhopHUD extends FlxSpriteGroup
{
    public var invtHUD:InventoryHUD;
    public var scoreHUD:ScoreHUD;
    public var staminaBar:StaminaBar;
    public var tipsHUD:TipsHUD;

    public function new()
    {
        super(0, 0);
        invtHUD = new InventoryHUD(FlxG.width - 130, 30);
        add(invtHUD);

        scoreHUD = new ScoreHUD(FlxG.width - 300, FlxG.height - 100);
        add(scoreHUD);

        staminaBar = new StaminaBar(50, 650);
        add(staminaBar);

        tipsHUD = new TipsHUD(40, 560);
        add(tipsHUD);
        tipsHUD.numWhole.updateNumbers();
        tipsHUD.numDec.updateNumbers();
    }
}