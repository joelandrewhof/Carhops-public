package game.objects;

import crowbar.objects.TopDownSprite;
import game.objects.Order;
import game.components.Inventory;

class OrderTray extends TopDownSprite
{
    public var refOrder:Order;

    public function new(x:Int, y:Int, order:Order)
    {
        super(x, y);
        refOrder = order;

        loadSprite("objects/test_order");
    }

    public function onPickup(inv:Inventory)
    {
        inv.addOrder(refOrder);
    }
}