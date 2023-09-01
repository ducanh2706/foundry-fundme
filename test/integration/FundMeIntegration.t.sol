// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";


contract FundMeIntegrationTest is Test{
    FundMe fundMe;

    address public USER = makeAddr("DucAnhLe");
    uint256 constant public SEND_VALUE = 0.1 ether;
    uint256 constant public START_BALANCE = 100 ether;
    uint256 constant public GAS_PRICE = 1;
    address public owner;

    function setUp() external {
        owner = msg.sender;
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE);
    }

    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        console.log(address(fundMe).balance);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);

        console.log(address(fundMe).balance);
        // address funder = fundMe.getFunder(0);
    }
}