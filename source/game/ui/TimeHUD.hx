package game.ui;

import crowbar.display.CrowbarText;
import flixel.group.FlxSpriteGroup;
import game.states.PlayState;

class TimeHUD extends FlxSpriteGroup
{
    public var timeDisplayTest:CrowbarText; //make this a sprite
    public var timeRemaining:CrowbarText;

    public function new()
    {
        super();

        timeDisplayTest = new CrowbarText(0, 0, 0, "", 24);
        timeRemaining = new CrowbarText(0, 30, 0, "", 24);

        add(timeDisplayTest);
        add(timeRemaining);

    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var string = PlayState.current.levelTime.getTimeString();
        timeDisplayTest.text = string;

        timeRemaining.text = getTimeRemainingText();
    }

    public function getTimeRemainingText():String
    {
        var text = "";
        //before shift
        if(PlayState.current.levelTime.elapsedMinutes < 0)
        {
            text = "SHIFT STARTS IN ";
            text += formatMinutes(Std.int(Math.abs(PlayState.current.levelTime.elapsedMinutes))+1);
        }
        else if(PlayState.current.levelTime.isItOvertime())
        {
            text = "OVERTIME ";
            text += formatMinutes(Std.int(PlayState.current.levelTime.elapsedMinutes - PlayState.current.levelTime.shiftLength));
        }
        else
        {
            text = "SHIFT ENDS IN ";
            text += formatMinutes(Std.int(PlayState.current.levelTime.shiftLength - PlayState.current.levelTime.elapsedMinutes)+1);
        }

        return text;
    }

    public static function formatMinutes(mins:Int):String
    {
        var string = "";
        if(mins >= 60) {
            string += Math.floor(mins / 60);
            string += "h ";
        }
        string += mins % 60;
        string += "m";
        return string;
    }
}