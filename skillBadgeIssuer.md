Skill Badge Issuer Smart ContractThis project implements a secure, non-transferable digital badge issuance system on the Ethereum Virtual Machine ($\text{EVM}$). It uses the $\text{ERC-1155}$ standard for multi-issue badge types and $\text{OpenZeppelin}$'s $\text{AccessControl}$ to restrict minting privileges exclusively to designated administrators.

Project Overview
The SkillBadgeIssuer.sol contract serves as the canonical registry for worker achievements and certifications within a platform.

Setup and Installation
This project is built and tested using Foundry.

Prerequisites:

Foundry: Install the Foundry toolchain ($\text{forge}$, $\text{cast}$, $\text{anvil}$).

```Bash
curl -L https://foundry.sh | bash
foundryup
```

Installation Steps

Clone the Repository:

```Bash
git clone [your-repo-link]
cd skill-badge-issuer
```

Install OpenZeppelin Contracts:
Use $\text{forge}$ to install the dependency as a git submodule:

```Bash
forge install OpenZeppelin/openzeppelin-contracts
```

Configure Remapping: Ensure your foundry.toml file (or remappings.txt) includes the correct path for imports:

```Ini,TOML
# foundry.toml
[compiler]
remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
]
```

Compile the Contract:

```Bash
forge build
```

$\text{ERC-1155}$ Metadata $\text{URI}$

The contract's constructor requires a Base $\text{URI}$ that contains the {id} placeholder.

Format: ipfs://CID-of-Metadata-Folder/{id}.json

Example Resolution: If the contract's $\text{URI}$ is set to ipfs://QmbF.../{id}.json, a request

for $\text{badgeId}=1$ will attempt to fetch the metadata from
ipfs://QmbF.../0000000000000000000000000000000000000000000000000000000000000001.json.

Testing
All critical features, including role-based access and transfer restrictions, are covered by unit tests.

To run the full test suite:

```Bash
forge test
```
