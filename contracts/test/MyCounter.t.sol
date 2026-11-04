// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MyCounter} from "../MyCounter.sol";

contract MyCounterTest is Test {
    MyCounter internal counter;
    address internal owner = makeAddr("owner");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    address internal constant FIXED_OWNER = 0x0F9Ec279D6c990493805391ed2a7Ac6fb89eEe26;

    event Incremented(uint256 newValue);

    function setUp() public {
        counter = new MyCounter(owner);
    }

    // ---- Deployment ----

    function test_StartsAtZero() public view {
        assertEq(counter.number(), 0);
    }

    function test_ConstructorSetsOwner() public view {
        assertEq(counter.owner(), owner);
    }

    function test_FixedOwnerAddressCanOwnAndIncrement() public {
        MyCounter c = new MyCounter(FIXED_OWNER);
        assertEq(c.owner(), FIXED_OWNER);
        assertEq(c.number(), 0);

        vm.prank(FIXED_OWNER);
        c.increment();
        assertEq(c.number(), 1);

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner));
        c.increment();
    }

    function test_RevertWhen_ConstructorOwnerIsZero() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        new MyCounter(address(0));
    }

    // ---- increment ----

    function test_OwnerIncrementIncreasesNumberByOne() public {
        vm.prank(owner);
        counter.increment();
        assertEq(counter.number(), 1);

        vm.prank(owner);
        counter.increment();
        assertEq(counter.number(), 2);
    }

    function test_IncrementEmitsIncremented() public {
        vm.expectEmit(false, false, false, true, address(counter));
        emit Incremented(1);
        vm.prank(owner);
        counter.increment();

        vm.expectEmit(false, false, false, true, address(counter));
        emit Incremented(2);
        vm.prank(owner);
        counter.increment();
    }

    function test_RevertWhen_NonOwnerIncrements() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        counter.increment();
        assertEq(counter.number(), 0);
    }

    // ---- ownership transfer ----

    function test_TransferOwnershipEmitsAndUpdatesOwner() public {
        vm.expectEmit(true, true, false, false, address(counter));
        emit Ownable.OwnershipTransferred(owner, alice);
        vm.prank(owner);
        counter.transferOwnership(alice);
        assertEq(counter.owner(), alice);
    }

    function test_NewOwnerCanIncrementAndOldOwnerCannot() public {
        vm.prank(owner);
        counter.transferOwnership(alice);

        vm.prank(alice);
        counter.increment();
        assertEq(counter.number(), 1);

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner));
        counter.increment();
    }

    function test_RevertWhen_NonOwnerTransfersOwnership() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        counter.transferOwnership(bob);
        assertEq(counter.owner(), owner);
    }

    function test_RevertWhen_TransferOwnershipToZero() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        counter.transferOwnership(address(0));
    }

    function test_RenounceOwnershipBlocksIncrement() public {
        vm.prank(owner);
        counter.renounceOwnership();
        assertEq(counter.owner(), address(0));

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner));
        counter.increment();
    }

    function test_RevertWhen_NonOwnerRenounces() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        counter.renounceOwnership();
    }

    // ---- fuzz ----

    function testFuzz_NOwnerIncrementsYieldsN(uint8 n) public {
        for (uint256 i = 0; i < n; i++) {
            vm.prank(owner);
            counter.increment();
        }
        assertEq(counter.number(), n);
    }

    function testFuzz_NonOwnerCannotIncrement(address caller) public {
        vm.assume(caller != owner);
        vm.prank(caller);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, caller));
        counter.increment();
        assertEq(counter.number(), 0);
    }
}
