// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

error TransferNotAllowed();

contract SkillBadgeIssuer is ERC1155, AccessControl {
    // Define the role for administrators who can issue (mint) badges
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(
        string memory uri_,
        address initialAdmin,
        address contractOwner
    ) ERC1155(uri_) {
        // Grant the DEFAULT_ADMIN_ROLE (needed to manage other roles)
        _grantRole(DEFAULT_ADMIN_ROLE, contractOwner);

        // Grant the specific ADMIN_ROLE to the initial administrator (e.g., the backend wallet)
        _grantRole(ADMIN_ROLE, initialAdmin);
    }

    /// @notice Allows an authorized admin to issue a new badge.
    function issueBadge(
        address recipient,
        uint256 badgeId,
        uint256 amount
    ) public onlyRole(ADMIN_ROLE) {
        require(recipient != address(0), "Recipient is the zero address");
        require(amount > 0, "Amount must be greater than zero");
        _mint(recipient, badgeId, amount, "");
    }

    /// @notice Overrides the internal ERC1155 v5 hook to prevent transfers between users.
    /// @dev This function is called before all mint/burn/transfer operations.
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155) {
        if (from != address(0) && to != address(0)) {
            revert TransferNotAllowed();
        }
        super._update(from, to, ids, values);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
