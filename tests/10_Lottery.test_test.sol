// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/10_Lottery.sol";

contract LotteryTest {
   
    address acc0 = TestsAccounts.getAccount(0); //owner by default
    address acc1 = TestsAccounts.getAccount(1);

    uint16 MIN_LOTTERY_GAMBLE = 1000;
    Lottery public lotteryToTest;
    function beforeAll () public {
        lotteryToTest = new Lottery("testLottery", address(this), MIN_LOTTERY_GAMBLE);
    }

    function checkLotteryIsRunning () public {
        Assert.equal(lotteryToTest.isLive(), true, "lottery is live");
    }

    function checkMinimumRequirement () public {
        Assert.equal(lotteryToTest.getMinimumEntryRequirement(), 1000, "lottery minimum requirement");
        Assert.equal(lotteryToTest.getMinimumEntryRequirement(), 1000 wei, "lottery minimum requirement in wei");
    }

    function checkParticipateRegistration () public payable {
        lotteryToTest.participate("account-1");
        Assert.equal(lotteryToTest.getEntrants(), 1, "one participant in the lottery");
        Assert.equal(lotteryToTest.getLastEntrant().name, "account-1", "last entrant has the correct name");
        Assert.equal(lotteryToTest.getLastEntrant().entryCount, 1, "last entrant is only registered once");
    }

}
