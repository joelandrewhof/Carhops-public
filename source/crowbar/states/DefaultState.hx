package crowbar.states;

import crowbar.states.game.TopDownState;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
//crowbar testing
import crowbar.display.CrowbarSprite;
import crowbar.display.CrowbarText;

class DefaultState extends FlxState
{
	var doCtrlCheck:Bool = true;

    override public function create()
	{
		super.create();

		var spr:FlxSprite = new FlxSprite(100, 100).makeGraphic(1080, 520, FlxColor.BLUE);
		add(spr);

		var hello:CrowbarText = new CrowbarText(0, 0, "This is the default state", 48);
		hello.screenCenter();
		add(hello);
		hello.setBorder(5, 0xFFFF0000);

		var cbar:CrowbarSprite = new CrowbarSprite(800, 300);
		cbar.loadGraphic(Paths.image('engine/icon64'));
		cbar.updateHitbox();
		add(cbar);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(Controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('engine/bip'));
		}

		if(Controls.BACK)
		{
			FlxG.switchState(new TopDownState());
		}
		
		
	}
}