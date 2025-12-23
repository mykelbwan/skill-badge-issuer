# Skill Badge Issuer

This project implements a secure, non-transferable digital badge issuance system on the Ethereum Virtual Machine (EVM). It uses the ERC-1155 standard for multi-issue badge types and OpenZeppelin's AccessControl to restrict minting privileges exclusively to designated administrators.

## Project Overview

The `SkillBadgeIssuer.sol` contract serves as the canonical registry for worker achievements and certifications within a platform. The badges are non-transferable to ensure they remain with the original recipient.

## Features

- **ERC-1155 Standard:** Allows for efficient management of multiple badge types.
- **Non-Transferable Badges:** Badges cannot be transferred between users, ensuring they remain with the original recipient.
- **Role-Based Access Control:** Uses OpenZeppelin's `AccessControl` to manage roles for issuing badges and administering the contract.
- **Customizable Metadata:** The contract supports customizable metadata for each badge type through a base URI that can be updated by the contract owner.

## Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/): Install the Foundry toolchain (forge, cast, anvil).
  ```bash
  curl -L https://foundry.sh | bash
  foundryup
  ```

### Installation

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/mykelbwan/skill-badge-issuer.git
    cd skill-badge-issuer
    ```

2.  **Install Dependencies:**
    Use `forge` to install the OpenZeppelin contracts dependency.
    ```bash
    forge install OpenZeppelin/openzeppelin-contracts
    ```

### Configuration

Ensure your `foundry.toml` file includes the correct remapping for the OpenZeppelin contracts.

```toml
# foundry.toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
remappings = ["@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"]
```

### Compile the Contract

```bash
forge build
```

## Usage

### Contract Roles

The contract uses two main roles:

-   `ADMIN_ROLE`: This role is responsible for issuing new badges to recipients.
-   `DEFAULT_ADMIN_ROLE`: This role has administrative privileges over the contract, including the ability to grant and revoke roles, and to update the metadata URI.

### Issuing Badges

The `issueBadge` function allows an address with the `ADMIN_ROLE` to mint a new badge.

```solidity
function issueBadge(
    address recipient,
    uint256 badgeId,
    uint256 amount
) public onlyRole(ADMIN_ROLE);
```

### Updating Metadata URI

The `setURI` function allows the contract owner (`DEFAULT_ADMIN_ROLE`) to update the base URI for the token metadata. The URI should contain the `{id}` placeholder, which will be replaced with the badge ID.

Format: `ipfs://CID-of-Metadata-Folder/{id}.json`

```solidity
function setURI(string memory newUri) public onlyRole(DEFAULT_ADMIN_ROLE);
```

## Testing

The project includes a comprehensive test suite covering all critical features, including role-based access and transfer restrictions.

To run the full test suite:

```bash
forge test
```

## Security Features

-   **Non-Transferable:** The `_update` function is overridden to prevent the transfer of badges between users.
-   **Access Control:** The `onlyRole` modifier is used to restrict access to sensitive functions.
-   **Input Validation:** The `issueBadge` function includes `require` statements to validate the recipient and amount.
