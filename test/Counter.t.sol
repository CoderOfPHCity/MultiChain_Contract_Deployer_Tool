// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/*solhint-disable func-name-mixedcase*/
contract CounterTest is Test {
    address private constant OWNER = 0xf67AC4799F4C3D3269c48A962A562eA81bB69cdC;

    address private nonAdminAccount = makeAddr("nonAdminAccount");

    Counter private counter;

    function setUp() public {
        vm.startPrank(OWNER);
        counter = new Counter();
        counter.initialize(OWNER);

        counter.setNumber(20);
    }

    function test_setUp_succeeds() public {
        assertEq(counter.owner(), OWNER, "Owner should be set");
        assertEq(counter.number(), 20, "Counter number should be 20");
    }

    function test_setNumber_succeeds() public {
        counter.setNumber(3);
        assertEq(counter.number(), 3, "Counter number should be 3");
    }
}
