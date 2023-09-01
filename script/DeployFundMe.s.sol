// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe) {
        HelpConfig helpConfig = new HelpConfig();
        (address ethUsdPriceFeed) = helpConfig.activeNetworkConfig();
        console.log('Sender is: %s', msg.sender);
        vm.startBroadcast();
        console.log('Sender is: %s', msg.sender);
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        console.log('Owner is: %s', fundMe.getOwner());
        vm.stopBroadcast();
        return fundMe;
    }

}