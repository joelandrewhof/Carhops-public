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
    public var cost:Int = 0; //cost in cents; adds to the score, affects tips
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
        generateCost();
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
        var f = FlxG.random.getObject([0.0, 3.0, 6.0, 10.0], [0.4, 0.2, 0.25, 0.15]);
        var d = (f == 0 ? 1 : FlxG.random.int(0, 1));
        setItems(f, d);
    }

    public function generateCost():Int
    {
        //for now cost calculation will be simplified, only based on food and drinks.
        //specific items for these may be made later, or not depending on complexity.
        cost = Std.int((items.food * 300) + (items.drinks * 150));
        return cost;
    }
}