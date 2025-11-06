package game.components;

import game.objects.*;
import game.states.PlayState;
//tracks the player's inventory, both held orders and items.

class Inventory
{
    public var orders:Array<Order>;
    public var capacity:Int = 4;

    public function new()
    {
        orders = new Array<Order>();
    }

    public function updateHUD()
    {
        PlayState.current.hud.invtHUD.updateFromInventory();
    }

    public function addOrder(order:Order):Bool
    {
        if(orders.length >= capacity)
            return false;
        orders.push(order);
        updateHUD();
        return true;
    }

    public function getOrder(ticket:Int):Order
    {
        for (o in orders)
        {
            if(o.ticket == ticket)
                return o;
        }
        trace('Could not find an order with ticket #${ticket} in the inventory');
        return null;
    }

    public function getOrderFromStall(stall:String):Order
    {
        for(o in orders)
        {
            if(o.destination == stall)
                return o;
        }
        trace('Could not find an order to stall ${stall} in the inventory');
        return null;
    }

    public function removeOrder(ticket:Int):Order
    {
        var newO = new Array<Order>();
        var old:Order = new Order(-1, "N/A"); //null order
        for (i in 0...orders.length)
        {
            if(orders[i].ticket == ticket) {
                old = orders[i];
            }
            else {
                newO.push(orders[i]);
            }
        }
        orders = newO;
        updateHUD();
        return old;
    }
}