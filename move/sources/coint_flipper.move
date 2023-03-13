module coinflipper::CoinFlipper{
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use std::hash::sha2_256;
    use std::debug;
    use std::vector;
    use sui::event;
    use sui::coin::{Self, Coin};
    // use games::drand_lib::{derive_randomness, verify_drand_signature};
    // use std::option::{Self, Option};
    // use std::randomness;

    /// User doesn't have enough coins to play 
    const ENotEnoughMoney: u64 = 1;
    const EOutOfService: u64 = 2;
    const AmountOfCombinations: u8 = 2;

    const Counter: u64 = 2;

    const DRAND_PK: vector<u8> =
        x"868f005eb8e6e4ca0a47c8a77ceaa5309a47978a7c71bc5cce96366b5d7a569937c529eeda66c7293784a9402801af31";

    struct FlipperOwner has key, store
    {
        id: UID
        }

    struct GambleEvent has copy, drop
    {
        id: ID,
        winnings: u64,
        gambler: address,
        coin_side: u8,
        }

    struct Flipper has key,store 
    {
        id: UID,
        name: String,
        description: String,
        flipper_balance: Balance<SUI>,
        counter: u64
        }

    public fun name(self: &Flipper): String
    { 
        self.name  
        }

    public fun description(self: &Flipper): String
    { 
        self.description 
        }

    public fun casino_balance(self:  &Flipper): u64
    {
       balance::value<SUI>(&self.flipper_balance)
       }


    // initialize  Flipper
    fun init(ctx: &mut TxContext) {
        transfer::transfer(FlipperOwner{id: object::new(ctx)}, tx_context::sender(ctx));

        transfer::share_object(Flipper {
            id: object::new(ctx),
            name: string::utf8(b"CoinFlipper"),
            description: string::utf8(b"Coin Flipper gambler based on SUI-coin"),
            flipper_balance: balance::zero(),
            counter: 0
        });}



    // A function for admins to deposit money to the gambler so it can still function!  
    public entry fun depositToCasino(_:&FlipperOwner, flipper :&mut Flipper, amount: u64, payment: &mut Coin<SUI>){

        let availableCoins = coin::value(payment);
        assert!(availableCoins > amount, ENotEnoughMoney);

        let balance = coin::balance_mut(payment);
        let payment = balance::split(balance, amount);

        balance::join(&mut flipper.flipper_balance, payment);}

    // let's play a game
    public entry fun gamble(flipper: &mut Flipper, assumption:vector<u8>, bet: u64, wallet: &mut Coin<SUI>, ctx: &mut TxContext){

        // calculate max user earnings through the casino
        // let max_earnings = casino.cost_per_game ; // we calculate the maximum potential winnings on the casino.

        // Make sure Casino has enough money to support this gameplay.
        assert!(casino_balance(flipper) >= bet, EOutOfService);
        // make sure we have enough money to play a game!
        assert!(coin::value(wallet) >= bet, ENotEnoughMoney);


        // get balance reference
        let wallet_balance = coin::balance_mut(wallet);

        // get money from balance
        let payment = balance::split(wallet_balance, bet);

        // add to casino's balance.
        balance::join(&mut flipper.flipper_balance, payment);


        let uid = object::new(ctx);
        debug::print(ctx);


        let randomNums = pseudoRandomNumGenerator(&uid,flipper);
        let winnings = 0;

        let coin_side = *vector::borrow(&randomNums, 0);

        // debug::print(slot_1);

        if(coin_side == 0 && assumption == b"tails"){
            winnings = bet * 2  ; // calculate winnings + the money the user spent.
            let payment = balance::split(&mut flipper.flipper_balance, winnings); // get from casino's balance.
            balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!
            //add winnings to user's wallet
        } else if(coin_side == 1 && assumption == b"heads"){
            winnings = bet ; 
            let payment = balance::split(&mut flipper.flipper_balance, winnings); // get from casino's balance.
            balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!
            //add winnings to user's wallet
        };

        // emit event
        event::emit( GambleEvent{
            id: object::uid_to_inner(&uid),
            gambler: tx_context::sender(ctx),
            winnings,
            coin_side,
        });
        
        // delete unused id
        debug::print(flipper);
        object::delete(uid);

        debug::print(&coin_side);

        // now let's play   with luck!
    }
    
    public entry fun deposit(flipper :&mut Flipper, amount: u64, payment: &mut Coin<SUI>){

    let availableCoins = coin::value(payment);
        assert!(availableCoins > amount, ENotEnoughMoney);

        let balance = coin::balance_mut(payment);
        let payment = balance::split(balance, amount);

        balance::join(&mut flipper.flipper_balance, payment);
        
        }


    

    fun pseudoRandomNumGenerator(uid: &UID,flipper: &mut Flipper):vector<u8>{ 
        
        let any = sha2_256(DRAND_PK);
        debug::print(&any);
        
        // create random ID
        let random = object::uid_to_bytes(uid);
        // let rand = object::to_bytes(any);
        // debug::print(&rand);
        let num_id = flipper.counter ;
        let vec = vector::empty<u8>();
        // add 1 random numbers based on UID of next tx ID.
        vector::push_back(&mut vec, (*vector::borrow(&random, num_id) as u8) %AmountOfCombinations);
        flipper.counter =  flipper.counter + 1;
        if (flipper.counter == 5) { 
            flipper.counter = 0
            };
        debug::print(flipper);
        vec
        
    }
    /*
       A function for admins to get their profits.
    */
    public entry fun withdraw(_:&FlipperOwner, flipper: &mut Flipper, amount: u64, wallet: &mut Coin<SUI>){

        let availableCoins = casino_balance(flipper);
        assert!(availableCoins > amount, ENotEnoughMoney);

        let balance = coin::balance_mut(wallet);

        // split money from casino's balance.
        let payment = balance::split(&mut flipper.flipper_balance, amount);

        // execute the transaction
        balance::join(balance, payment);
    }
    // public entry fun complete( drand_sig: vector<u8>, drand_prev_sig: vector<u8>) {
    //     verify_drand_signature(drand_sig, drand_prev_sig, game.round);
    //     // The randomness is derived from drand_sig by passing it through sha2_256 to make it uniform.
    //     let digest = derive_randomness(drand_sig);
    //     game.winner = option::some(safe_selection(game.participants, &digest));
    // }

    // public entry fun close( drand_sig: vector<u8>, drand_prev_sig: vector<u8>) {
    //     assert!(game.status == IN_PROGRESS, EGameNotInProgress);
    //     verify_drand_signature(drand_sig, drand_prev_sig, closing_round(game.round));
    // }

    #[test_only]
    
    public fun init_for_testing(ctx: &mut TxContext) 
    {
        init(ctx);
    }

}

