package game.components;

import flixel.math.FlxMath;

enum abstract AngerValue(Int) to Int {
    var OK = 0;
    var ANNOYED = 1;
    var ANGRY = 2;
    var PISSED = 3;
}

class MannyStateManager
{
    public var mannyState:Int = 0;
    public var angerStage:AngerValue = OK;
    public var rage:Float = 0.0;
    public var timesEnraged:Int = 0;
    public var rageTickPauseTimer:Float = 0; //used to "stun" manny's rage from building when delivering orders

    public var ragePerSecond:Float = 0.004;
    public var maxAnger:Int = PISSED;

    public function new()
    {

    }

    public function update(elapsed:Float)
    {
        if(angerStage == PISSED)
        {
            if(rage <= 0)
            {
                angerStage = ANGRY;
                angerThresholdCheck();
            }
            else
            {
                if(rageTickPauseTimer > 0) {
                    rageTickPauseTimer -= elapsed;
                }
                else {
                    addRage(ragePerSecond * elapsed);
                }
            }
        }
    }

    public function addRage(add:Float)
    {
        rage = Math.min(rage + add, 1);
        //trace("MANNY RAGE: " + (Std.int(rage * 100) * 0.01));
    }

    public function addAnger()
    {
        if(angerStage != maxAnger) { //increase manny's anger stage and check if he's angry enough to transform.
            angerStage++;
            angerThresholdCheck();
        }
        else { //if manny is already pissed, add more to his rage.
            addRage(0.1);
        }
    }

    public function decreaseRage(subt:Float)
    {
        rage -= subt;
    }

    private function angerThresholdCheck()
    {
        if(angerStage == PISSED && mannyState != 1)
        {
            rage = 0.15 + (0.8 * timesEnraged);
            timesEnraged++;
            mannyTransformAngryState();
        }
        if(angerStage != PISSED && mannyState != 0)
        {
            mannyTransformNeutralState();
        }
    }

    public function addToPauseTimer(add:Float, ?doNotExceed:Float)
    {
        rageTickPauseTimer += add;
        if(doNotExceed != null && rageTickPauseTimer > doNotExceed) {
            rageTickPauseTimer = doNotExceed;
        }
    }

    private function mannyTransformAngryState()
    {

    }

    private function mannyTransformNeutralState()
    {

    }


}