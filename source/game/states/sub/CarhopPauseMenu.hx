package game.states.sub;

import crowbar.states.sub.PauseMenu;
import game.states.*;

class CarhopPauseMenu extends PauseMenu
{
    public function new()
    {
        super();

        SoundManager.playSound("clack");
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.ACCEPT)
        {
            SoundManager.playSound("select");
            switch(menu.selection) {
                case 0: {
                    resume();
                }
                case 1: {
                    FlxG.switchState(new PlayState());
                }
                case 2: {
                    FlxG.switchState(new MainMenuState());
                }
            }
        }

        if(Controls.BACK) {
            resume();
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