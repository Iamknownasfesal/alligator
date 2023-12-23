//    _____  .__  .__  .__              __                
//   /  _  \ |  | |  | |__| _________ _/  |_  ___________ 
//  /  /_\  \|  | |  | |  |/ ___\__  \\   __\/  _ \_  __ \
// /    |    \  |_|  |_|  / /_/  > __ \|  | (  <_> )  | \/
// \____|__  /____/____/__\___  (____  /__|  \____/|__|   
//         \/            /_____/     \/                   
// DEX aggregator module for Alligator, made for Sui Mini Hackathon 2023 hosted by Sui & Patika.dev

module alligator::aggregator {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use std::type_name;
    use alligator::utils::{is_sufficient, split_coins_and_transfer_rest};
    use sui::coin::{Coin};

    struct Aggregator has key {
        id: UID,
        admin: ID
    }

    struct AggregateStartEvent<T> has copy, drop {
        coin_type: T,
        amount: u64
    }

    struct AggregateEndEvent<T> has copy, drop {
        coin_type: T,
        amount: u64
    }

    struct AdminCap has key { id: UID }
    
    fun init(ctx: &mut TxContext) {
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public entry fun aggregate_start<T>(coins: vector<Coin<T>>, amount: u64, receiver: address, ctx: &mut TxContext): Coin<T>{
        event::emit(AggregateStartEvent {
            coin_type: type_name::get<T>(),
            amount: amount
        });

        split_coins_and_transfer_rest<T>(coins, amount, receiver, ctx)
    }   

    public entry fun aggregate_end<T>(coin: &Coin<T>,amount: u64) {
        event::emit(AggregateEndEvent {
            coin_type: type_name::get<T>(),
            amount: amount
        });

        is_sufficient<T>(coin, amount)
    }
}