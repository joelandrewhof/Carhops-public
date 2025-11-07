package crowbar.states.sub;

import crowbar.display.CrowbarText;
import flixel.FlxSubState;
import crowbar.ui.ScrollSelectionList;
//import crowbar.states.TopDownState;
//import crowbar.states.MainMenuState;

class PauseMenu extends FlxSubState
{
    public var bg:FlxSprite;
    public var title:CrowbarText;
    public var menu:ScrollSelectionList;

    public function new()
    {
        super();

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        bg.alpha = 0.4;
        add(bg);

        title = new CrowbarText(0, 0, 0, "PAUSED", 96);
        title.updateHitbox();
        title.setPosition((FlxG.width * 0.5) - title.width * 0.5, (FlxG.height * 0.3) - title.height * 0.5);
        add(title);

        createMenu();

    }

    public function createMenu()
    {
        menu = new ScrollSelectionList(title.x, title.y + 200);
        menu.addOption("RESUME");
        menu.addOption("RESTART");
        menu.addOption("QUIT TO TITLE");
        add(menu);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

    }

    function resume():Void {
        trace("resuming");
		FlxG.state.closeSubState();
	}
}