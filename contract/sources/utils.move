//    _____  .__  .__  .__              __                
//   /  _  \ |  | |  | |__| _________ _/  |_  ___________ 
//  /  /_\  \|  | |  | |  |/ ___\__  \\   __\/  _ \_  __ \
// /    |    \  |_|  |_|  / /_/  > __ \|  | (  <_> )  | \/
// \____|__  /____/____/__\___  (____  /__|  \____/|__|   
//         \/            /_____/     \/                   
// DEX aggregator utils module for Alligator, made for Sui Mini Hackathon 2023 hosted by Sui & Patika.dev

module alligator::utils {
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::pay;
    use std::vector;

    const E_NON_SUFFICIENT_BALANCE: u64 = 1;

    public fun is_sufficient<T>(coin: &Coin<T>, amount: u64) {
        let balance = coin::value(coin);

        assert!(balance >= amount, E_NON_SUFFICIENT_BALANCE)
    }

    public fun merge_coins<T>(coins: vector<Coin<T>>, ctx: &mut TxContext): Coin<T> {
        let payer = coin::zero<T>(ctx);
        pay::join_vec<T>(&mut payer, coins);

        payer
    }

    public fun transfer_or_destroy_coin<T>(coin: Coin<T>, ctx: &mut TxContext) {
        if (coin::value<T>(&coin) == 0) {
            coin::destroy_zero<T>(coin);
        } else {
            transfer::public_transfer<Coin<T>>(coin, tx_context::sender(ctx));
        }
    }

    public fun split_coin_by_weights<T>(coins: vector<Coin<T>>, weights: vector<u64>, ctx: &mut TxContext): vector<Coin<T>> {
        let merged = merge_coins<T>(coins, ctx);
        let value = coin::value<T>(&merged);
        let vec = vector::empty<Coin<T>>();

        vector::reverse<u64>(&mut weights);

        if(!vector::is_empty<u64>(&weights)) {
            let i = 0;

            while (i < vector::length<u64>(&weights)) {
                let weight = vector::pop_back(&mut weights);

                let amount = value * weight / 100;

                let coin = coin::split<T>(&mut merged, amount, ctx);
                vector::push_back<Coin<T>>(&mut vec, coin);
            }
        };

        transfer_or_destroy_coin<T>(merged, ctx);
        vec
    }

    public fun split_coin_and_transfer_rest<T>(in: Coin<T>, amount: u64, receiver: address, ctx: &mut TxContext): Coin<T> {
        if (coin::value<T>(&in) == amount) {
            in
        } else {
            let split = coin::split<T>(&mut in, amount, ctx);
            transfer::public_transfer<Coin<T>>(split, receiver);

            in
        }
    }

    public fun split_coins_and_transfer_rest<T>(coins: vector<Coin<T>>, amount: u64, receiver: address, ctx: &mut TxContext): Coin<T> {
        split_coin_and_transfer_rest<T>(merge_coins<T>(coins, ctx), amount, receiver, ctx)
    }
}