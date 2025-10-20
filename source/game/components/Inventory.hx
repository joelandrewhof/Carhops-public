package game.components;

import game.objects.*;
//tracks the player's inventory, both held orders and items.

class Inventory
{
    public var orders:Array<Order>;

    public function new()
    {
        orders = new Array<Order>();
    }

    public function addOrder(order:Order)
    {
        
    }
}