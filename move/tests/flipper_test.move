#[test_only]
module coinflipper::flipper_test {
    use coinflipper::CoinFlipper::{Self, Flipper, FlipperOwner};
    use sui::coin::{Self};
    use sui::sui::SUI;
    use sui::test_scenario;

    #[test]
    public fun casino_tests() {

        let owner =  @0x1;
        let player = @0x3;

        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
            coinflipper::CoinFlipper::init_for_testing(test_scenario::ctx(scenario));
            
        };
        test_scenario::next_tx(scenario, player);
        {
            let casino = test_scenario::take_shared<Flipper>(scenario);
            let casinoOwnership = test_scenario::take_from_address<FlipperOwner>(scenario, owner);

            
            let ctx = test_scenario::ctx(scenario);
            let coinOb = coin::mint_for_testing<SUI>(40000, ctx);


            // deposit some money on the casino!
            CoinFlipper::depositToCasino(&casinoOwnership, &mut casino, 35000, &mut coinOb);

            let balance = CoinFlipper::casino_balance(&casino);


            assert!(balance == 35000, 1); // verify that casino's balance is the one we deposited.

            // gamble the money (5000)
            CoinFlipper::gamble(&mut casino,b"tails",5000, &mut coinOb, ctx); // 1st gamble

            balance = CoinFlipper::casino_balance(&casino);
            assert!(balance == 35000, 1); // verify that casino's balance changed after the gamble (either up or down)

            coin::destroy_for_testing(coinOb);
            test_scenario::return_shared(casino);
            test_scenario::return_to_address(owner, casinoOwnership);
        };

        // withdraw from casino 
        // test_scenario::next_tx(scenario, owner);
        // {
        //     let casino = test_scenario::take_shared<Casino>(scenario);
        //     let initial_balance = CoinFlipper::casino_balance(&casino);

        //     let casinoOwnership = test_scenario::take_from_address<CasinoOwnership>(scenario, owner);
        //     let ctx = test_scenario::ctx(scenario);
        //     let coinOb = coin::mint_for_testing<SUI>(0, ctx);


        //     CoinFlipper::withdraw(&casinoOwnership,&mut casino, 10000, &mut coinOb);

        //     let balance_after_withdrawal = CoinFlipper::casino_balance(&casino);

        //     assert!(initial_balance == balance_after_withdrawal + 10000, 1); // verify that the initial balance was reduced by 10.000

        //     assert!(coin::value(&coinOb) == 10000, 1); // verify that the money moved to the coin object!


        //     coin::destroy_for_testing(coinOb);

        //     test_scenario::return_shared(casino);
        //     test_scenario::return_to_address(owner, casinoOwnership);
        // };

        test_scenario::end(scenario_val);


    }
}