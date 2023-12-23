//    _____  .__  .__  .__              __                
//   /  _  \ |  | |  | |__| _________ _/  |_  ___________ 
//  /  /_\  \|  | |  | |  |/ ___\__  \\   __\/  _ \_  __ \
// /    |    \  |_|  |_|  / /_/  > __ \|  | (  <_> )  | \/
// \____|__  /____/____/__\___  (____  /__|  \____/|__|   
//         \/            /_____/     \/                   
// DEX aggregator admin & fee module for Alligator, made for Sui Mini Hackathon 2023 hosted by Sui & Patika.dev

module alligator::admin {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::package;

    struct AdminCap has store, key { id: UID }
    struct Fee has key {
        id: UID,
        current_fee: u64,
        receiver: address
    }

    struct FeeData has drop {}

    fun init(otw: FeeData, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
        transfer::public_transfer<AdminCap>(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public fun initialize_fee(_: &AdminCap, receiver: address, fee: u64, ctx: &mut TxContext) {
        transfer::share_object(Fee {
            id: object::new(ctx),
            current_fee: fee,
            receiver: receiver
        })
    }

    public fun get_fee(fee: &Fee): u64 {
        fee.current_fee
    }

    public fun update_fee(_: &AdminCap, fee: &mut Fee, new_fee: u64, _: &mut TxContext) {
        fee.current_fee = new_fee;
    }

    public fun add_admin(_: &AdminCap, receiver: address, ctx: &mut TxContext) {
        transfer::public_transfer<AdminCap>(AdminCap {
            id: object::new(ctx)
        }, receiver)
    }
}