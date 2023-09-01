// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    address public USER = makeAddr("DucAnhLe");
    uint256 constant public SEND_VALUE = 0.1 ether;
    uint256 constant public START_BALANCE = 100 ether;
    uint256 constant public GAS_PRICE = 1;
    address public owner;


    function setUp() external {
        owner = msg.sender;
        DeployFundMe deployFundMe = new DeployFundMe();
        console.log('Initial Sender is: %s', msg.sender);
        console.log('Initial balance: %s', msg.sender.balance);
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.getMinimumUSD(), 5e18);
    }

    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }


    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{     
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        assertEq(startingFundMeBalance, SEND_VALUE);

        // Act
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance - startingOwnerBalance, SEND_VALUE);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), START_BALANCE); // prank + deal
            fundMe.fund{value: SEND_VALUE}();
        }

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        

        // Act

        vm.startPrank(fundMe.getOwner());  
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);

    }

    function testCheaperWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), START_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        

        // Act

        vm.startPrank(fundMe.getOwner());  
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);

    }





    


    


}