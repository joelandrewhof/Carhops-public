package game.components;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import game.objects.*;
import game.states.PlayState;

class CarhopsEntityParser
{
    //maybe this could be scripted later
    public static function loadEntity(data:EntityData):Void
    {
        switch data.name
        {
            case "Stall":
            {
                var obj = new Stall(data.x, data.y, data.values.id, data.values.orientation);
                PlayState.current.conductor.stalls.push(obj);
            }
            case "OrderTable":
            {
                var obj = new OrderTable(data.x, data.y);
                PlayState.current.orderTable = obj;
                PlayState.current.visMngr.addSprite(obj);
            }
        }
    }
}