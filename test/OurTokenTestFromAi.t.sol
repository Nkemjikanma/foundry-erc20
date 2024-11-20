// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant TRANSFER_AMOUNT = 10 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    // Basic Balance Tests
    function testInitialBalance() public {
        assertEq(
            ourToken.balanceOf(address(this)),
            ourToken.totalSupply() - STARTING_BALANCE
        );
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    // Transfer Tests
    function testTransferToken() public {
        vm.prank(bob);
        bool success = ourToken.transfer(alice, TRANSFER_AMOUNT);
        assertTrue(success);
        assertEq(ourToken.balanceOf(alice), TRANSFER_AMOUNT);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - TRANSFER_AMOUNT);
    }

    function testFailTransferInsufficientBalance() public {
        vm.prank(bob);
        ourToken.transfer(alice, STARTING_BALANCE + 1);
    }

    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.transfer(address(0), TRANSFER_AMOUNT);
    }

    // Allowance Tests
    function testInitialAllowance() public {
        assertEq(ourToken.allowance(bob, alice), 0);
    }

    function testApprove() public {
        vm.prank(bob);
        bool success = ourToken.approve(alice, TRANSFER_AMOUNT);
        assertTrue(success);
        assertEq(ourToken.allowance(bob, alice), TRANSFER_AMOUNT);
    }

    function testIncreaseAllowance() public {
        vm.startPrank(bob);
        ourToken.approve(alice, TRANSFER_AMOUNT);
        bool success = ourToken.increaseAllowance(alice, TRANSFER_AMOUNT);
        vm.stopPrank();

        assertTrue(success);
        assertEq(ourToken.allowance(bob, alice), TRANSFER_AMOUNT * 2);
    }

    function testDecreaseAllowance() public {
        vm.startPrank(bob);
        ourToken.approve(alice, TRANSFER_AMOUNT * 2);
        bool success = ourToken.decreaseAllowance(alice, TRANSFER_AMOUNT);
        vm.stopPrank();

        assertTrue(success);
        assertEq(ourToken.allowance(bob, alice), TRANSFER_AMOUNT);
    }

    // TransferFrom Tests
    function testTransferFromWithAllowance() public {
        // Bob approves Alice
        vm.prank(bob);
        ourToken.approve(alice, TRANSFER_AMOUNT);

        // Alice transfers from Bob to Carol
        vm.prank(alice);
        bool success = ourToken.transferFrom(bob, carol, TRANSFER_AMOUNT);

        assertTrue(success);
        assertEq(ourToken.balanceOf(carol), TRANSFER_AMOUNT);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - TRANSFER_AMOUNT);
        assertEq(ourToken.allowance(bob, alice), 0);
    }

    function testFailTransferFromWithoutAllowance() public {
        vm.prank(alice);
        ourToken.transferFrom(bob, carol, TRANSFER_AMOUNT);
    }

    function testFailTransferFromAboveAllowance() public {
        // Bob approves Alice for TRANSFER_AMOUNT
        vm.prank(bob);
        ourToken.approve(alice, TRANSFER_AMOUNT);

        // Alice tries to transfer more than allowed
        vm.prank(alice);
        ourToken.transferFrom(bob, carol, TRANSFER_AMOUNT + 1 ether);
    }

    // Event Tests
    function testTransferEvent() public {
        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, TRANSFER_AMOUNT);
        ourToken.transfer(alice, TRANSFER_AMOUNT);
    }

    function testApprovalEvent() public {
        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, TRANSFER_AMOUNT);
        ourToken.approve(alice, TRANSFER_AMOUNT);
    }

    // Additional Edge Cases
    function testZeroTransfer() public {
        vm.prank(bob);
        bool success = ourToken.transfer(alice, 0);
        assertTrue(success);
        assertEq(ourToken.balanceOf(alice), 0);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testTransferToSelf() public {
        vm.prank(bob);
        bool success = ourToken.transfer(bob, TRANSFER_AMOUNT);
        assertTrue(success);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }
}
