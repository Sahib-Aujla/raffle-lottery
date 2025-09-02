// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    event RaffleEntered(address indexed player);

    uint256 subscriptionId;
    bytes32 gasLane;
    uint256 automationUpdateInterval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2_5;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant LINK_BALANCE = 100 ether;

    function setUp() external {
        DeployRaffle deploy = new DeployRaffle();
        (raffle, helperConfig) = deploy.deployRaffle();

        vm.deal(PLAYER, STARTING_USER_BALANCE);

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        subscriptionId = config.subscriptionId;
        gasLane = config.gasLane;
        automationUpdateInterval = config.automationUpdateInterval;
        raffleEntranceFee = config.raffleEntranceFee;
        callbackGasLimit = config.callbackGasLimit;
        vrfCoordinatorV2_5 = config.vrfCoordinatorV2_5;
    }

    function testRaffleStateIsOpen() external view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRafflePlayer() external {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        address player = raffle.getPlayer(0);
        assertEq(player, PLAYER);
    }

    function testEnterRaffleRevert() external {
        vm.prank(PLAYER);
        vm.expectRevert();
        raffle.enterRaffle();
    }

    function testRaffleEnteredEvent() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);

        raffle.enterRaffle{value: raffleEntranceFee}();
    }

    modifier setVmWarp() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);

        _;
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
        vm.warp(block.timestamp + automationUpdateInterval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Act / Assert
        //assert(raffle.getRaffleState()==Raffle.RaffleState.CALCULATING);
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: raffleEntranceFee}();
    }

    //test CheckUpKeep
    function testCheckUpKeepReturnFalse() external setVmWarp {
        raffle.performUpkeep("");
        (bool upkeepNeeded,) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeedReturnTrue() external setVmWarp {
        (bool upkeepNeeded,) = raffle.checkUpkeep("");
        assert(upkeepNeeded);
    }

    function testPerformUpkeepRequestId() external setVmWarp {
        vm.recordLogs();
        raffle.performUpkeep(""); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        // requestId = raffle.getLastRequestId();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }

    function testGetRaffleState() external view {
        Raffle.RaffleState state = raffle.getRaffleState();
        assert(Raffle.RaffleState.OPEN == state);
    }

    function testGetNumWords() external view {
        uint256 num = raffle.getNumWords();
        assertEq(num, 1);
    }

    function testGetRequestConfirmations() external view {
        uint256 num = raffle.getRequestConfirmations();
        assertEq(num, 3);
    }

    function testGetRecentWinner() external view {
        address recentWinner = raffle.getRecentWinner();
        assertEq(recentWinner, address(0));
    }

    function testGetPlayer() external setVmWarp {
        address addres = raffle.getPlayer(0);
        assertEq(addres, PLAYER);
    }

    function testGetLastTimeStamp() external view {
        uint256 timeStamp = raffle.getLastTimeStamp();
        assertEq(timeStamp, block.timestamp);
    }

    function testGetInterval() external view {
        assertEq(raffle.getInterval(), automationUpdateInterval);
    }

    function testGetEntranceFee() external view {
        assertEq(raffle.getEntranceFee(), raffleEntranceFee);
    }

    function testGetNumberOfPlayers() external view {
        assertEq(raffle.getNumberOfPlayers(), 0);
    }

    //fulfill Random Words
    function testFulfillRandomWords() external setVmWarp {}
}
