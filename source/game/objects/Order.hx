package game.objects;

typedef OrderItems = 
{
    food:Float, //in lbs
    drinks:Int //in quantity
}

class Order
{
    //orders have associated stalls
    public var ticket:Int;
    public var destination:String;
    public var items:OrderItems;
    public var weight:Float; //probably important later
    public var satisfied:Bool = false;
    public var inInventory:Bool = false;

    public final maxDrinks:Int = 4;
    public final maxFood:Float = 10.0;

    public var basePatience:Float = 30.0;
    public var patience:Float;
    public var unheldDrainResist:Float = 0.67; //patience drains slower when order is not in the inventory.

    public function new(ticket:Int, dest:String)
    {
        this.ticket = ticket;
        destination = dest;

        patience = basePatience;

        setRandomItems();
    }

    public function setItems(food:Float = 0.0, drinks:Int = 0)
    {
        if(food < 0) 
            food = 0;
        else if(food > maxFood) 
            food = maxFood;
        if(drinks < 0) 
            drinks = 0;
        else if(drinks > maxDrinks) 
            drinks = maxDrinks;

        items = {food: food, drinks: drinks};
    }

    public function drainPatience(elapsed:Float)
    {
        var drain = elapsed * (inInventory ? 1 : (1 - unheldDrainResist));
        patience -= drain;
    }

    public function setRandomItems()
    {
        var f = FlxG.random.getObject([0.0, 0.0, 3.0, 10.0]);
        var d = (f == 0 ? 1 : FlxG.random.int(0, 1));
        setItems(f, d);
    }
}