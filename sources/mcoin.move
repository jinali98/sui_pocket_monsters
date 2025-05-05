module sui_pocket_monsters::mcoin;

use std::option::none;
use std::string::{Self, String};
use sui::balance::{Self, Balance};
use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::sui::SUI;
use sui::token;

// Store for the in game currency
public struct McoinStore has key {
    id: UID,
    profits: Balance<SUI>,
    mcoin_treasury: TreasuryCap<MCOIN>,
}

// OTW to create the in game currency
public struct MCOIN has drop {}

fun init(otw: MCOIN, ctx: &mut TxContext) {
    let (treasury_cap, coin_metadata) = create_in_game_currency(otw, ctx);

    let (mut policy, cap) = token::new_policy(&treasury_cap, ctx);

    // TODO : decide on policies
    token::allow(&mut policy, &cap, token::spend_action(), ctx);

    // allow actions to buy mcoin
    token::allow(&mut policy, &cap, buy_mcoin_action(), ctx);

    // create and share the McoinStore
    transfer::share_object(McoinStore {
        id: object::new(ctx),
        profits: balance::zero(),
        mcoin_treasury: treasury_cap,
    });

    transfer::public_freeze_object(coin_metadata);
    transfer::public_transfer(cap, ctx.sender());
    token::share_policy(policy);
}

fun create_in_game_currency(
    otw: MCOIN,
    ctx: &mut TxContext,
): (TreasuryCap<MCOIN>, CoinMetadata<MCOIN>) {
    let (treasury_cap, coin_metadata) = coin::create_currency(
        otw,
        9,
        b"MCOIN",
        b"Monster Coin",
        b"In game currency for pocket monsters",
        none(),
        ctx,
    );

    (treasury_cap, coin_metadata)
}

// custom action to buy mcoin
public fun buy_mcoin_action(): String {
    string::utf8(b"buy")
}
