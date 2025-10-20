package game.components;

import game.objects.*;
import game.states.PlayState;

//DO LATER AS PART OF GAMEPLAY
//keeps track of game elements and makes decisions

class PlayConductor
{
    public var orders:Array<Order>;
    public var stalls:Array<Stall>;
    public var nextOrder:Int = 1;

    public function new()
    {
        
    }

    public function getVacantStalls():Array<Stall>
    {
        var vacants:Array<Stall> = new Array<Stall>();
        for(s in stalls) {
            if(!s.occupied)
                vacants.push(s);
        }
        return vacants;
    }

    public function createCustomer():Null<CustomerCar>
    {
        var vacants:Array<Stall> = getVacantStalls();
        if(vacants.length <= 0)
            return null;
        var s:Int = FlxG.random.int(0, vacants.length - 1);

        var car = new CustomerCar(vacants[s].spawnX, vacants[s].spawnY, vacants[s].id);
        PlayState.current.customers.add(car);
        vacants[s].setOccupied(true);
        return car;
    }

    public function createOrderEntire()
    {
        if(getVacantStalls().length <= 0)
            return;
        else
            spawnOrderTray(createOrderToCustomer(createCustomer()));
    }

    public function createOrderToCustomer(customer:CustomerCar):Order
    {
        var order = new Order(nextOrder, customer.stallID);
        nextOrder++;
        return order;
    }

    public function getVacantCustomer()
    {
        for(c in PlayState.current.customers)
        {
            if(!c.ordered)
                return c;
        }
        return null;
    }

    public function spawnOrderTray(order:Order)
    {
        PlayState.current.orderTable.spawnOrderTray(order);
    }
}