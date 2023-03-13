<script setup >
import { useWallet } from "../helpers/wallet";
import { ref, onMounted, onUnmounted, reactive } from 'vue'
import { casinoAddress, moduleAddress } from "../helpers/constants";
import { useUiStore } from "../stores/ui";
import { useAuthStore } from "../stores/auth";
const { executeMoveCall, getAddress, getSuitableCoinId } = useWallet();
const authStore = useAuthStore();
const coin_sides = reactive([
    {
        heads: "heads",
        tails: "tails"
    },
    {
        id: 0,
        started: false,
        randomSlides: [],
        ended: false
    },
])
const gameStatuses = {
    STANDBY: 'STANDBY',
    LOSS: 'LOSS',
    WIN: 'WIN'
}
const gameStatus = ref(gameStatuses.STANDBY);
const gameStarted = ref(false);
const isLoading = ref(false);
const gameResultsObject = ref({});
const gameResults = ref([]);
const totalGames = ref(0);
const uiStore = useUiStore();
const bid = ref("10000")
const selectedSide = ref("heads")
let coin_s = ref("H")

const flip = () => {
    var flipTimeout;
    var coin = document.getElementById("coin");
    var coinContainer = document.getElementById("coin-container");
    var result = document.getElementById("result");
    button.onclick = () => {
        coin.classList.remove("flip");
        coinContainer.classList.remove("flip");
        result.innerHTML = executeGamble();
        if (!coin.classList.contains("flip")) {
            coin.classList.add("flip");
            coinContainer.classList.add("flip");
            result.innerHTML = "";
        }
    };
}
const executeGamble = () => {
    const address = getAddress();
    if (!address) return;
    if (gameStarted.value) return;
    // resetGame();
    gameStarted.value = true;
    isLoading.value = true;

    var coin = document.getElementById("coin");
    var coinContainer = document.getElementById("coin-container");
    var result = document.getElementById("result");
    if (!coin.classList.contains("flip")) {
        coin.classList.add("flip");
        coinContainer.classList.add("flip");
        result.innerHTML = "";
    }
    const coinId = getSuitableCoinId(6000)
    executeMoveCall({
        packageObjectId: moduleAddress,
        module: 'CoinFlipper',
        typeArguments: [],
        arguments: ["0x8e65d94ad0b9fb993b69acb03d53f4a1034c31c3", selectedSide.value, bid.value, coinId],
        function: 'gamble',
        gasBudget: 1000
    }).then(res => {
        totalGames.value++;
        const status = res?.effects?.status?.status;
        console.log(res?.effects?.status?.status)
        coin.classList.remove("flip");
        coinContainer.classList.remove("flip");
        if (status === 'success') {
            let SuizinoEventResult = res?.effects?.events?.find(x => x.moveEvent) || {};
            console.log(SuizinoEventResult)
            // return SuizinoEventResult
            let fields = SuizinoEventResult?.moveEvent?.fields;
            let side = fields.coin_side ? "Heads" : "Tails"
            coin_s = side[0]

            result.innerHTML = side;f
            gameResultsObject.value = fields;
            gameResults.value = [fields.slot_1,];


            checkGameStatus()
            // We just mark all slots as "started" and we let the interval that is already running
            // take care of showing the results. To make it more smooth,
            // for (let [index, slot] of wheelSlots.entries()) {
            //     slot.started = true;
            //     // setTimeout(()=>{
            //     //
            //     // }, (index+1) * 600); // start wih 300ms difference
            // }

        } else {
            uiStore.setNotification(res?.effects?.status?.error);
            // resetGame();
        }
    }).catch(e => {
        // resetGame();

        uiStore.setNotification(e.message);
    })
}
const checkGameStatus = () => {
    gameStarted.value = false;
    isLoading.value = false;
    let hasWon = true;
    let icon = null;
    gameStatus.value = gameResultsObject.value.winnings > 0 ? gameStatuses.WIN : gameStatuses.LOSS;

    if (gameStatus.value === gameStatuses.WIN) {
        uiStore.setNotification("Congratulations 🎉! You won " + gameResultsObject.value.winnings + " MIST!", "success")
    }
    if (gameStatus.value === gameStatuses.LOSS) {
        uiStore.setNotification("😔 You were unlucky this time. maybe try an extra try?")
    }
}
</script>

<template>
    <div
        class="lucky-wheel-slot bg-white overflow-hidden dark:bg-gray-700 h-[250px] md:h-[320px] rounded-lg shadow flex items-center justify-center">
        <h2> The result is</h2>
        <div id="coin-container">
            <div id="coin"> {{ coin_s }} </div>
        </div>
        <h2 id="result">tails</h2>
        <br>
    </div>
    <!-- <button @click="flip">Flip</button> -->
    <div class="mt-6 text-center">
        <button v-if="!authStore.hasWalletPermission"
            class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center text-white px-5 py-2 rounded-full"
            @click="authStore.toggleWalletAuthModal = true">
            <div v-html="logo" class="logo-icon"></div> Connect your wallet to start playing!
        </button>

        <button v-else
            class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center text-white px-5 py-2 rounded-full"
            :class="isLoading || !authStore.hasWalletPermission ? 'opacity-70 cursor-default hover:px-5' : ''"
            @click="executeGamble">

            <div v-if="isLoading">
                <svg aria-hidden="true" class="w-5 h-5 text-gray-200 animate-spin dark:text-white fill-gray-800"
                    viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path
                        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                        fill="currentColor" />
                    <path
                        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                        fill="currentFill" />
                </svg>
            </div>
            <span v-else class="flex items-center">
                <div v-html="logo" class="logo-icon"></div>
                {{ totalGames === 0 ? 'GUESS... ' + selectedSide : 'PLAY AGAIN' }} <span class="ml-2 text-sm">({{
                    bid
                }} Mist)
                </span>
            </span>

        </button>
        <br>
        <h1>Select you bid and guess </h1>
        <div v-if="authStore.hasWalletPermission"
            class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center text-white px-5 py-2 rounded-full">
            <select
                class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center border-2 text-white px-5 py-2 rounded-full"
                v-model="selectedSide" placeholder="Выберите сторону">
                <option value="heads" selected="selected">Heads</option>
                <option value="tails">Tails</option>
            </select>
            <br>
            <input
                class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center border-2 text-white px-5 py-2 rounded-full"
                v-model="bid" @keypress="isNumber(uiStore.setNotification('only digit accept'))"
                placeholder="Введите вашу ставку">
        </div>
        <!-- <p class="text-xs mt-5">Double you bid</p> -->
    </div>
    <!-- 
                                                                                                                                                                                <div class="flip-button">
                                                                                                                                                                                    <select v-model="selectedSide" placeholder="Выберите сторону"
                                                                                                                                                                                        class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center text-white px-5 py-2 rounded-full">
                                                                                                                                                                                        <option value="heads" selected="selected">Heads</option>
                                                                                                                                                                                        <option value="tails">Tails</option>
                                                                                                                                                                                    </select>
                                                                                                                                                                                    <br>
                                                                                                                                                                                    <input
                                                                                                                                                                                        class="bg-gray-800 mx-auto ease-in-out duration-500 hover:px-10 dark:bg-gray-800 flex items-center text-white px-5 py-2 rounded-full"
                                                                                                                                                                                        v-model="bid" @keypress="isNumber(uiStore.setNotification('only digit accept'))"
                                                                                                                                                                                        placeholder="Введите вашу ставку">
                                                                                                                                                                                </div> -->
</template>
<style scoped>
@import url(https://fonts.googleapis.com/css?family=Open+Sans:300,400,700);



.container_coin {
    /* background: #1a1a1a; */
    position: relative;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    margin: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 10px;


}

/* .btn {
    justify-content: center;
} */

/* h2 {
    color: #fafafa;
    font-family: "Open Sans", sans-serif;
} */

#coin {
    font: 50px "Open Sans", sans-serif;
    color: #543f00;
    margin: 10px;
    padding: 22px 40px;
    background-color: #ffc107;
    border-color: #876500;
    border-width: 5px;
    border-style: solid;
    border-radius: 60px;
}

#coin.flip {
    -webkit-animation: flipcoin 0.2s linear infinite;
    animation: flipcoin 0.2s linear infinite;
}

#coin-container {
    transform: scale(0.5, 0.5);
}

#coin-container.flip {
    animation: enlarge 0.5s linear alternate-reverse infinite;
}

#result:after {
    content: "!";
}

@-webkit-keyframes enlarge {
    from {
        transform: scale(0.5, 0.5);
    }

    from {
        transform: scale(1, 1);
    }
}

@keyframes enlarge {
    from {
        transform: scale(0.5, 0.5);
    }

    from {
        transform: scale(1, 1);
    }
}

@-webkit-keyframes flipcoin {
    from {
        transform: rotateX(0deg);
    }

    to {
        transform: rotateX(359deg);
    }
}

@keyframes flipcoin {
    from {
        transform: rotateX(0deg);
    }

    to {
        transform: rotateX(359deg);
    }
}
</style>