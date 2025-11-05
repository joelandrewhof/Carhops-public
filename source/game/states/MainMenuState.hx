package game.states;

import flixel.FlxState;
import crowbar.display.CrowbarText;
import crowbar.ui.ScrollSelectionList;

class MainMenuState extends FlxState
{

    public var title:CrowbarText;

    public var menu:ScrollSelectionList;

    override function create()
    {
        super.create();

        title = new CrowbarText(0, 0, 0, "CARHOPS", 96);
        add(title);


        menu = new ScrollSelectionList(Std.int(FlxG.width * 0.5), Std.int(FlxG.height * 0.5));
        menu.addOption("START");
        menu.addOption("OPTIONS");
        menu.addOption("EXIT");
        add(menu);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.ACCEPT)
        {
            switch(menu.selection) {
                case 0: {
                    FlxG.switchState(new PlayState());
                }
                case 1: {}
                case 2: {
                    Sys.exit(0);
                }
            }
        }

        if(Controls.UI_DOWN_P) {
            menu.addToSelection(1);
            SoundManager.playSound("tick");
        }
        if(Controls.UI_UP_P) {
            menu.addToSelection(-1);
            SoundManager.playSound("tick");
        }

    }
}