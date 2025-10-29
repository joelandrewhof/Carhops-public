package crowbar.components;

import lime.media.FlashAudioContext;
import crowbar.objects.TopDownCharacter;

class ScriptedWalkMovement extends WalkMovement
{

    public var scriptInputList:Array<ScriptInput>;

    public function new(controller:CharacterController)
    {
        super(controller);
        name = "ScriptedWalkMovement";
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateScriptedMove(elapsed);
    }

    public function updateScriptedMove(elapsed:Float)
    {
        if(scriptInputList.length > 0)
            {
                var leadInput = scriptInputList[0].getParameters();
                setMoving(leadInput[0], leadInput[0]);
                setRunning(leadInput[1]);
                //timer function
                scriptInputList[0] = ScriptInput(leadInput[0], leadInput[1], leadInput[2] - elapsed);
                if(leadInput[2] - elapsed <= 0.0)
                {
                    scriptInputList.shift();
                }
            }
    }

    public function addScriptInput(direction:String, running:Bool, time:Float)
    {
        scriptInputList.push(ScriptInput(direction, running, time));
    }
}