//    _____  .__  .__  .__              __                
//   /  _  \ |  | |  | |__| _________ _/  |_  ___________ 
//  /  /_\  \|  | |  | |  |/ ___\__  \\   __\/  _ \_  __ \
// /    |    \  |_|  |_|  / /_/  > __ \|  | (  <_> )  | \/
// \____|__  /____/____/__\___  (____  /__|  \____/|__|   
//         \/            /_____/     \/                   
// DEX aggregator tests module for Alligator, made for Sui Mini Hackathon 2023 hosted by Sui & Patika.dev

#[test_only]
module alligator::tests {
    #[test]
    fun main_test() {
        use sui::test_scenario;
        use alligator::aggregator;
        use alligator::utils;
        use sui::transfer;
        use sui::coin::{Self, Coin, TreasuryCap};
        use std::vector;
        use alligator::mycoin::{MYCOIN};
        use alligator::mycoinb::{MYCOINB};

        let admin = @0xBABE;
        let swapper = @0xCAFE;
        let swap_platform1 = @0xDEAD1;
        let swap_platform2 = @0xDEAD2;

        let scenario_val = test_scenario::begin(admin);

        let scenario = &mut scenario_val;
        {
            alligator::admin::initTest(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, admin);
        {
            alligator::mycoin::initTest(test_scenario::ctx(scenario));
            alligator::mycoinb::initTest(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, admin);
        {
            let treasury1 = test_scenario::take_from_sender<TreasuryCap<MYCOIN>>(scenario);
            let treasury2 = test_scenario::take_from_sender<TreasuryCap<MYCOINB>>(scenario);

            coin::mint_and_transfer(&mut treasury1, 100000, admin, test_scenario::ctx(scenario));
            coin::mint_and_transfer(&mut treasury2, 100000, admin, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, treasury1);
            test_scenario::return_to_sender(scenario, treasury2);
        };

        test_scenario::next_tx(scenario, admin);
        {
            // Send tokens to swapper
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            let split = coin::split<MYCOIN>(&mut coinb, 100, test_scenario::ctx(scenario));
            transfer::public_transfer(split, swapper);
            test_scenario::return_to_sender(scenario, coinb);
        };

        test_scenario::next_tx(scenario, admin);
        {
            // Send tokens to swap_platform1
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            let coinb2 = test_scenario::take_from_sender<Coin<MYCOINB>>(scenario);
            let split = coin::split<MYCOIN>(&mut coinb, 200, test_scenario::ctx(scenario));
            let split2 = coin::split<MYCOINB>(&mut coinb2, 200, test_scenario::ctx(scenario));
            transfer::public_transfer(split, swap_platform1);
            transfer::public_transfer(split2, swap_platform1);
            test_scenario::return_to_sender(scenario, coinb);
            test_scenario::return_to_sender(scenario, coinb2);
        };

        test_scenario::next_tx(scenario, admin);
        {
            // Send tokens to swap_platform2
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            let coinb2 = test_scenario::take_from_sender<Coin<MYCOINB>>(scenario);
            let split = coin::split<MYCOIN>(&mut coinb, 200, test_scenario::ctx(scenario));
            let split2 = coin::split<MYCOINB>(&mut coinb2, 200, test_scenario::ctx(scenario));
            transfer::public_transfer(split, swap_platform2);
            transfer::public_transfer(split2, swap_platform2);
            test_scenario::return_to_sender(scenario, coinb);
            test_scenario::return_to_sender(scenario, coinb2);
        };

        test_scenario::next_tx(scenario, swapper);
        {
            let v = vector::empty<Coin<MYCOIN>>();
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            vector::push_back(&mut v, coinb);

            let lasted_coins = aggregator::aggregate_start<MYCOIN>(v, 50, swap_platform1, test_scenario::ctx(scenario));

            transfer::public_transfer(lasted_coins, swapper);
        };

        test_scenario::next_tx(scenario, swapper);
        {
            let v = vector::empty<Coin<MYCOIN>>();
            let weights = vector::empty<u64>();
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            vector::push_back(&mut v, coinb);

            vector::push_back(&mut weights, 20);
            vector::push_back(&mut weights, 80);

            let lasted_coins = utils::split_coin_by_weights(v, weights, test_scenario::ctx(scenario));

            assert!(vector::length(&lasted_coins) == 2, 99);

            transfer::public_transfer(utils::merge_coins(lasted_coins, test_scenario::ctx(scenario)), swapper);
        };

        test_scenario::next_tx(scenario, swapper);
        {
            let coinb = test_scenario::take_from_sender<Coin<MYCOIN>>(scenario);
            aggregator::aggregate_end<MYCOIN>(&coinb, 50);

            transfer::public_transfer(coinb, swapper);
        };

        test_scenario::end(scenario_val);
    }
}