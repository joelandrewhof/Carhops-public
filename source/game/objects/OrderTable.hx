package game.objects;

import crowbar.objects.TopDownSprite;
import game.objects.Order;
import game.states.PlayState;

//spawns orders. not directly but some global manager should do it.

class OrderTable extends TopDownSprite
{
    public var spawnX:Int = 20;
    public var spawnY:Int = 20;
    public final orderSpacing:Int = 128;
    //spawn trays as part of the table sprite group
    public var trays:Array<OrderTray>;

    public function new(x:Int, y:Int)
    {
        super(x,y);
        loadSprite("objects/test_table");

        trays = new Array<OrderTray>();
    }

    public function spawnOrderTray(order:Order)
    {
        var tray = new OrderTray(spawnX + (orderSpacing * trays.length), spawnY, order);
        trays.push(tray);
        this.add(tray);
        
    }

    public function removeOrderTray(ticket:Int)
    {

    }
}