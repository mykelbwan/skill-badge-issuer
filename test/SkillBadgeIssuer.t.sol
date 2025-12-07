// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {SkillBadgeIssuer} from "../src/SkillBadgeIssuer.sol";
import {TransferNotAllowed} from "../src/SkillBadgeIssuer.sol";

contract SkillBadgeIssuerTest is Test {
    SkillBadgeIssuer private issuer;

    // --- Test Addresses & Data ---
    address private constant ADMIN_WALLET = address(0xAA);
    address private constant CONTRACT_OWNER = address(0xCC);
    address private constant WORKER_ALICE = address(0xA11ce);
    address private constant WORKER_BOB = address(0xB0b);
    address private constant STRANGER = address(0x546857);
    address private constant ZERO_ADDRESS = address(0x00);

    // Badge IDs
    uint256 private constant SOLIDITY_EXPERT = 1;
    uint256 private constant COMMUNITY_MOD = 2;
    string private constant BASE_URI = "ipfs://QmbF.../{id}.json";

    function setUp() public {
        // Deploy the contract, granting the ADMIN_ROLE to ADMIN_WALLET
        issuer = new SkillBadgeIssuer(BASE_URI, ADMIN_WALLET, CONTRACT_OWNER);
    }

    // --- Test Group 1: Access Control and Deployment ---

    function testDeployment_RolesAreSet() public view {
        // Check if the ADMIN_WALLET received the ADMIN_ROLE
        assertTrue(
            issuer.hasRole(issuer.ADMIN_ROLE(), ADMIN_WALLET),
            "Admin role not granted."
        );

        // Check if the CONTRACT_OWNER received the DEFAULT_ADMIN_ROLE
        assertTrue(
            issuer.hasRole(issuer.DEFAULT_ADMIN_ROLE(), CONTRACT_OWNER),
            "Default admin role not granted."
        );
    }

    function test_AdminCanIssueBadge() public {
        vm.startPrank(ADMIN_WALLET);
        issuer.issueBadge(WORKER_ALICE, SOLIDITY_EXPERT, 3);
        vm.stopPrank();

        // Alice should have 3 instances of the SOLIDITY_EXPERT badge
        assertEq(
            issuer.balanceOf(WORKER_ALICE, SOLIDITY_EXPERT),
            3,
            "Admin should be able to mint badges."
        );
    }

    function testRevert_NonAdminCannotIssueBadge() public {
        // --- Correction: Use vm.startPrank/vm.stopPrank to correctly set msg.sender ---
        vm.startPrank(STRANGER);

        // 1. EXPECT the custom error from AccessControl
        // The unauthorized account is the one making the call (STRANGER),
        // and the required role is the ADMIN_ROLE.
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        "AccessControlUnauthorizedAccount(address,bytes32)"
                    )
                ),
                STRANGER,
                issuer.ADMIN_ROLE()
            )
        );

        // 2. Execute the function that should revert
        issuer.issueBadge(WORKER_ALICE, COMMUNITY_MOD, 1);

        vm.stopPrank(); // Ensure the prank stops after the expected revert
    }

    function testRevert_CannotIssueToZeroAddress() public {
        vm.prank(ADMIN_WALLET);
        // Expect a revert from the 'require' check inside issueBadge
        vm.expectRevert("Recipient is the zero address");
        issuer.issueBadge(ZERO_ADDRESS, SOLIDITY_EXPERT, 1);
    }

    function testRevert_CannotIssueZeroAmount() public {
        vm.prank(ADMIN_WALLET);
        // Expect a revert from the 'require' check inside issueBadge
        vm.expectRevert("Amount must be greater than zero");
        issuer.issueBadge(WORKER_ALICE, SOLIDITY_EXPERT, 0);
    }

    // --- Test Group 2: Non-Transferability Enforcement ---

    function testRevert_WorkerCannotTransferBadge() public {
        // 1. Admin issues the badge to Alice
        vm.prank(ADMIN_WALLET);
        issuer.issueBadge(WORKER_ALICE, SOLIDITY_EXPERT, 1);

        // Ensure Alice has the badge
        assertEq(
            issuer.balanceOf(WORKER_ALICE, SOLIDITY_EXPERT),
            1,
            "Setup failed: Alice should have the badge."
        );

        // 2. Alice tries to transfer the badge to Bob
        vm.startPrank(WORKER_ALICE);
        // Expect a revert with the custom error defined in the contract
        vm.expectRevert(TransferNotAllowed.selector);

        // Use the standard ERC1155 transfer function
        issuer.safeTransferFrom(
            WORKER_ALICE,
            WORKER_BOB,
            SOLIDITY_EXPERT,
            1,
            ""
        );
        vm.stopPrank();

        // Final check to ensure no transfer occurred
        assertEq(
            issuer.balanceOf(WORKER_ALICE, SOLIDITY_EXPERT),
            1,
            "Alice should still have the badge after failed transfer."
        );
        assertEq(
            issuer.balanceOf(WORKER_BOB, SOLIDITY_EXPERT),
            0,
            "Bob should not have received the badge."
        );
    }

    function testRevert_OperatorCannotTransferBadge() public {
        // 1. Admin issues the badge to Alice
        vm.prank(ADMIN_WALLET);
        issuer.issueBadge(WORKER_ALICE, COMMUNITY_MOD, 5);

        // 2. Alice approves Bob as an operator
        vm.prank(WORKER_ALICE);
        issuer.setApprovalForAll(WORKER_BOB, true);

        // 3. Bob (the approved operator) tries to transfer Alice's badge to himself
        vm.startPrank(WORKER_BOB);
        vm.expectRevert(TransferNotAllowed.selector);

        // Bob tries to transfer 1 token from Alice to himself
        issuer.safeTransferFrom(WORKER_ALICE, WORKER_BOB, COMMUNITY_MOD, 1, "");
        vm.stopPrank();

        // Final check
        assertEq(
            issuer.balanceOf(WORKER_ALICE, COMMUNITY_MOD),
            5,
            "Alice's balance must be unchanged."
        );
    }
}
