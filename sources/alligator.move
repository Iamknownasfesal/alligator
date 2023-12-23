//    _____  .__  .__  .__              __                
//   /  _  \ |  | |  | |__| _________ _/  |_  ___________ 
//  /  /_\  \|  | |  | |  |/ ___\__  \\   __\/  _ \_  __ \
// /    |    \  |_|  |_|  / /_/  > __ \|  | (  <_> )  | \/
// \____|__  /____/____/__\___  (____  /__|  \____/|__|   
//         \/            /_____/     \/                   
// DEX aggregator module for Alligator, made for Sui Mini Hackathon 2023 hosted by Sui & Patika.dev

module alligator::aggregator {
    use sui::object::{UID, ID};
    use sui::tx_context::TxContext;
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::event;
    use std::type_name;
    use alligator::utils::{is_sufficient, split_coins_and_transfer_rest};
    use alligator::admin::{Fee, get_fee};

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

    struct TakeFeeEvent<T> has copy, drop {
        coin_type: T,
        amount: u64
    }

    const E_LESS_THAN_FEE: u64 = 1;

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

    public entry fun take_fee<T>(in: Coin<T>, fee: &Fee, receiver: address, ctx: &mut TxContext): Coin<T> {
        let curr_fee = get_fee(fee);

        assert!(coin::value<T>(&in) < curr_fee, E_LESS_THAN_FEE);

        let split = coin::split<T>(&mut in, curr_fee, ctx);

        transfer::public_transfer<Coin<T>>(split, receiver);

        event::emit(TakeFeeEvent {
            coin_type: type_name::get<T>(),
            amount: curr_fee
        });

        in
    }
}