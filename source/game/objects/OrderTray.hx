package game.objects;

import crowbar.objects.TopDownSprite;
import crowbar.objects.Interactable;
import game.objects.Order;
import game.components.Inventory;
import game.states.PlayState;

class OrderTray extends TopDownSprite
{
    public var refOrder:Order;
    public var interactable:Interactable;

    private final _interactableThickness:Int = 30;

    public function new(x:Int, y:Int, order:Order)
    {
        super(x, y);
        refOrder = order;

        loadSprite("images/objects/test_order.png");
        updateHitbox();

        interactable = new Interactable(0, 0, 
            this.width + (_interactableThickness * 2), this.height + (_interactableThickness * 2));
        interactable.overrideCheck = true; //so we have access to functions in this class
        add(interactable);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(interactable.interactionCheck())
        {
            onPickup();
        }
    }

    public function onPickup()
    {
        trace("Order " + refOrder.destination + " has been picked up");
        PlayState.current.inventory.addOrder(refOrder);
        this.destroy();
    }
}