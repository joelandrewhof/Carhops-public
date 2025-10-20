package game.objects;

import crowbar.objects.TopDownSprite;
import crowbar.components.Interactable;
import game.objects.Order;
import game.components.Inventory;

class OrderTray extends TopDownSprite
{
    public var refOrder:Order;

    public function new(x:Int, y:Int, order:Order)
    {
        super(x, y);
        refOrder = order;

        loadSprite("images/objects/test_order.png");
    }

    public function onPickup(inv:Inventory)
    {
        inv.addOrder(refOrder);
    }
}