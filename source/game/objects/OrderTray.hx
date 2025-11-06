package game.objects;

import crowbar.objects.TopDownSprite;
import crowbar.components.Interactable;
import game.objects.Order;
import game.components.Inventory;
import game.states.PlayState;

class OrderTray extends TopDownSprite
{
    public var assigned:Bool = false;
    public var refOrder:Order;
    public var interactable:Interactable;

    private final _interactableThickness:Int = 30;

    public function new(x:Int, y:Int, ?order:Order)
    {
        super(x, y);

        loadFromYaml('objects/tray');
        updateHitbox();
        
        if(order != null)
            assignOrder(order);

        setVisual();

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

    public function assignOrder(order:Order)
    {
        refOrder = order;
        assigned = true;
    }

    public function onPickup()
    {
        trace("Order " + refOrder.destination + " has been picked up");
        SoundManager.playSound("select");
        PlayState.current.inventory.addOrder(refOrder);
        this.destroy();
    }

    //probably temporary anyways
    public function setVisual()
    {
        if(!assigned || refOrder == null) {
            sprite.animation.play("empty");
            return;
        }

        var s = "food";
        s += (refOrder.items.food > 0 ? "F_" : "E_");
        s += 'drink' + (refOrder.items.drinks > 0 ? "F" : "E");

        sprite.animation.play(s);
        updateHitbox();
    }
}