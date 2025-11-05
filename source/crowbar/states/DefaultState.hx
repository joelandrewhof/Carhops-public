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
import crowbar.ui.ScrollSelectionList;

class DefaultState extends FlxState
{
	var doCtrlCheck:Bool = true;

	var sel:ScrollSelectionList;

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

		sel = new ScrollSelectionList(800, 500);
		sel.addOption("NO");
		sel.addOption("YES");
		sel.addOption("NO");
		sel.setAllHoverFields({color: 0xFFFFFF00}, 0.2);
		add(sel);
		sel.changeSelection(0);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(Controls.ACCEPT)
		{
			if(sel.selection == 1)
				FlxG.switchState(new TopDownState());
		}

		if(Controls.UI_DOWN_P)
			sel.addToSelection(1);
		if(Controls.UI_UP_P)
			sel.addToSelection(-1);
		
	}
}