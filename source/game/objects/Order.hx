package game.objects;

class Order
{
    //orders have associated stalls
    public var ticket:Int;
    public var destination:String;
    public var weight:Float; //probably important later

    public function new(ticket:Int, dest:String)
    {
        this.ticket = ticket;
        destination = dest;
    }
}