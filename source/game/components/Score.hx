package game.components;

class Score
{
    public static var score:Int = 0;

    public static function addScore(base:Int)
    {
        score += base;
    }

    public static function clearActive()
    {
        score = 0;
    }

}