// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Raffle {
    error NotEnoughEthSent();
    error NotEnoughTimePassed();

    event RaffleEntered(address indexed player);
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private lastTimestamp;

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        lastTimestamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        if (block.timestamp - lastTimestamp < i_interval) {
            revert NotEnoughTimePassed();
        }

        lastTimestamp = block.timestamp;
    }

    //Getter Function
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
