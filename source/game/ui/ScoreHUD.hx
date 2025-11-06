package game.ui;

import crowbar.display.CrowbarText;
import flixel.group.FlxSpriteGroup;
import game.components.Score;

class ScoreHUD extends FlxSpriteGroup
{
    public var score:CrowbarText;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        score = new CrowbarText(0, 0, 0, "SCORE: 0", 48);
        add(score);
    }

    public function updateScoreDisplay()
    {
        score.text = "SCORE: " + Score.score;
    }
}

