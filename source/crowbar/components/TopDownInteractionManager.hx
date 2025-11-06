package crowbar.components;


import flixel.FlxBasic;
import haxe.ds.StringMap;
import crowbar.components.TopDownUtil;
import crowbar.states.game.TopDownState;
import crowbar.objects.NPC;
import crowbar.objects.LoadingZone;
import crowbar.components.Interactable;
import flixel.group.FlxGroup;

//manages objects interacting with each other in the overworld, like collision, etc.
class TopDownInteractionManager extends FlxBasic
{

    public var collisionArray:Array<Collision>;
    public var interactableArray:Array<Interactable>;

    public function new()
    {
        super();

        collisionArray = new Array<Collision>();
        interactableArray = new Array<Interactable>();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        loadingZoneCheck(); //checks if the player has entered a loading zone, updates and starts a room transition if so
        playerInteractableCheck();
    }

    //adds all interactables from the overworld to the list of them to track here.
    //includes everything that should be tracked normally, like signs, NPCs, followers, etc.
    public function setupInteractables()
    {
        //removed
    }

    //manages player movement and collision.
    //in the future, might want to add all collision objects to a general dynamic list, not check groups of them like this

    public function loadingZoneCheck()
    {
        //removed
    }

    public function playerInteractableCheck():Bool
    {
        if(Controls.ACCEPT) {
            for(i in interactableArray)
            {
                var a = i.collision.checkOverlap(TopDownState.current.playerHitbox);
                if(a) {
                    i.addClick(true);
                    return true;
                }
            }
        }
        return false;
    }

    public function playerCollisionCheck(requestMoveX:Float, requestMoveY:Float):Array<Bool>
    {
        var dirCol = TopDownUtil.isPlayerTilemapCollideAfterMove(requestMoveX, requestMoveY);
        for(c in collisionArray)
        {
            var d = TopDownUtil.isPlayerColOverlapAfterMove(c, requestMoveX, requestMoveY);
            if(d[0]) dirCol[0] = true;
            if(d[1]) dirCol[1] = true;
        }

        return dirCol;
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