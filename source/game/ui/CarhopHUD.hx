package game.ui;

import flixel.group.FlxSpriteGroup;
import game.ui.*;

class CarhopHUD extends FlxSpriteGroup
{
    public var invtHUD:InventoryHUD;

    public function new()
    {
        super(0, 0);
        invtHUD = new InventoryHUD(FlxG.width - 130, 30);
        add(invtHUD);
    }
}