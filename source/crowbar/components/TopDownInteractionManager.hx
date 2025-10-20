package crowbar.components;


import flixel.FlxBasic;
import haxe.ds.StringMap;
import crowbar.components.TopDownUtil;
import crowbar.states.game.TopDownState;
import crowbar.objects.NPC;
import crowbar.objects.LoadingZone;
import crowbar.objects.Interactable;
import flixel.group.FlxGroup;

//manages objects interacting with each other in the overworld, like collision, etc.
class TopDownInteractionManager extends FlxBasic
{

    public function new()
    {
        super();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        playerMoveAndCollide(); //moves player while checking for collision
        loadingZoneCheck(); //checks if the player has entered a loading zone, updates and starts a room transition if so
    }

    //adds all interactables from the overworld to the list of them to track here.
    //includes everything that should be tracked normally, like signs, NPCs, followers, etc.
    public function setupInteractables()
    {
        //removed
    }

    //manages player movement and collision.
    //in the future, might want to add all collision objects to a general dynamic list, not check groups of them like this
    public function playerMoveAndCollide()
    {
        var futurePos:Array<Float> = TopDownState.current.playerController.calculateMove();

        //ROOM COLLISION MAP
        var dirCol = TopDownUtil.isPlayerTilemapCollideAfterMove(futurePos[0], futurePos[1]);

        //NPCS


        //if we can at least move in a direction
        if(!dirCol[0] || !dirCol[1])
        {
            TopDownState.current.playerController.move(dirCol[0], dirCol[1]);
        }
    }

    public function loadingZoneCheck()
    {
        //removed
    }

    //quick function to make bool overrides easier. orCheck will check if either of the bools is [true/false] and set it to that
    private function getBoolArrayOr(ary1:Array<Bool>, ary2:Array<Bool>, ?orCheck:Bool = true):Array<Bool>
    {
        if(ary1.length != ary2.length)
            return [false, false];
        for(i in 0...ary1.length)
        {
            if(ary1[i] == orCheck || ary2[i] == orCheck)
                ary1[i] = orCheck;
        }
        return ary1;
    }
}