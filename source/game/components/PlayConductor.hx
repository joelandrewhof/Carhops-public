package game.components;

import game.objects.*;
import game.states.PlayState;

//DO LATER AS PART OF GAMEPLAY
//keeps track of game elements and makes decisions

class PlayConductor
{
    public var orders:Array<Order>;
    public var stalls:Array<Stall>;
    public var customers:Array<CustomerCar>;
    public var nextOrder:Int = 1;

    public function new()
    {
        orders = new Array<Order>();
        stalls = new Array<Stall>();
        customers = new Array<CustomerCar>();
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

    private function createCustomer(stall:Stall):CustomerCar
    {
        var car = new CustomerCar(stall.spawnX, stall.spawnY, stall.id);
        PlayState.current.customers.add(car);
        stall.setOccupied(true);
        return car;
    }

    private function createCustomerAtRandomStall():CustomerCar
    {
        var vacants = getVacantStalls();
        return createCustomer(vacants[FlxG.random.int(0, vacants.length - 1)]);
    }

    public function createOrderEntire()
    {
        if(getVacantStalls().length <= 0)
        {
            trace("Notice: no vacant stalls left, cancelling order");
            return;
        }
        else
        {
            spawnOrderTray(createOrderToCustomer(createCustomerAtRandomStall()));
        }
    }

    public function createOrderToCustomer(customer:CustomerCar):Order
    {
        var order = new Order(nextOrder, customer.stallID);
        nextOrder++;
        orders.push(order);
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