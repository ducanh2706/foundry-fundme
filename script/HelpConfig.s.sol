// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";


contract HelpConfig is Script {

    struct NetworkConfig{
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainetConfig();
        } else{
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }


    function getSepoliaNetworkConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory sepoliaNetworkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetworkConfig;
    }

    function getMainetConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory ethNetworkConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethNetworkConfig;
    }

    function getOrCreateAnvilNetworkConfig() public returns(NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}