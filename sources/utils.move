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
    use sui::tx_context::{TxContext};
    use sui::pay;

    public fun is_sufficient<T>(coin: &Coin<T>, amount: u64) {
        let balance = coin::value(coin);

        if (balance < amount) {
            abort 0
        }
    }

    public fun merge_coins<T>(coins: vector<Coin<T>>, ctx: &mut TxContext): Coin<T> {
        let payer = coin::zero<T>(ctx);
        pay::join_vec<T>(&mut payer, coins);

        payer
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