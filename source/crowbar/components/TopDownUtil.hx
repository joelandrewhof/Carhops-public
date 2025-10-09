package crowbar.components;

import crowbar.states.game.TopDownState;
import flixel.FlxObject;

//various utilities for stuff in the overworld.
class TopDownUtil
{
    public static function isPlayerTilemapCollideAfterMove(x:Float, y:Float):Array<Bool>
    {
        return isPlayerTilemapCollideAtCoords(TopDownState.current.playerHitbox.x + x, TopDownState.current.playerHitbox.y + y);
    }

    public static function isPlayerTilemapCollideAtCoords(x:Float, y:Float):Array<Bool>
    {
        return twoObjectOverlapCheck(TopDownState.current.playerHitbox, TopDownState.current.room.collisionGrid, x, y);
    }

    public static function isPlayerColOverlapAfterMove(col:Collision, x:Float, y:Float):Array<Bool>
    {
        return isPlayerColOverlapAtCoords(col, TopDownState.current.playerHitbox.x + x, TopDownState.current.playerHitbox.y + y);
    }
    
    public static function isPlayerColOverlapAtCoords(col:Collision, x:Float, y:Float):Array<Bool>
    {
        return spriteAndCollisionCheck(TopDownState.current.playerHitbox, col, x, y);
    }

    //checks if two FlxObjects are overlapping each other. works for tilemap collision.
    public static function twoObjectOverlapCheck(obj:FlxObject, collision:FlxObject, ?x:Float = 0, ?y:Float = 0):Array<Bool>
    {
        var bumpX:Bool = false;
        var bumpY:Bool = false;
        var prevX:Float = obj.x;
        var prevY:Float = obj.y;
        obj.x = x;
        if(collision.overlaps(obj, false, TopDownState.current.camGame))
        {
            bumpX = true;
        }
        obj.x = prevX;
        obj.y = y;
        if(collision.overlaps(obj, false, TopDownState.current.camGame))
        {
            bumpY = true;
        }
        obj.y = prevY;
        return [bumpX, bumpY];
    }

    //takes a collision object instead of an flxobject. works with the Collision class
    public static function spriteAndCollisionCheck(spr:FlxSprite, collision:Collision, ?x:Float = 0, ?y:Float = 0):Array<Bool>
    {
        var bumpX:Bool = false;
        var bumpY:Bool = false;
        var prevX:Float = spr.x;
        var prevY:Float = spr.y;
        spr.x = x;
        if(collision.checkOverlap(spr))
        {
            bumpX = true;
        }
        spr.x = prevX;
        spr.y = y;
        if(collision.checkOverlap(spr))
        {
            bumpY = true;
        }
        spr.y = prevY;
        return [bumpX, bumpY];
    }
}