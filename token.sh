#!/bin/bash
# Logo
curl -s https://raw.githubusercontent.com/ToanBm/user-info/main/logo.sh | bash
sleep 3

show() {
    echo -e "\033[1;35m$1\033[0m"
}

# Step 1: Install hardhat
echo "Install Hardhat..."
npm init -y
npm install --save-dev hardhat
npm install @openzeppelin/contracts

echo "Install dotenv..."
npm install dotenv

# Setup 2: Set Up the Project
git clone https://github.com/PharosNetwork/examples && cd examples/token/hardhat/contract

npm install

# Step 3: Create Token.sol contract
echo "Create ERC20 contract..."
rm Token.sol

cat <<'EOF' > Token.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("Token", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
EOF

# Step 4: Update hardhat.config.js with the proper configuration
echo "Creating new hardhat.config file..."
rm hardhat.config.js

cat <<'EOF' > hardhat.config.js
require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.28",
  networks: {
    pharos: {
      url: "https://devnet.dplabs-internal.com/",
      chainId: 50002,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
};
EOF

# Step 5: Create .env file for storing private key
echo "Create .env file..."

read -p "Enter your EVM wallet private key (without 0x): " PRIVATE_KEY
cat <<EOF > .env
PRIVATE_KEY=$PRIVATE_KEY
EOF

# Step 6: Deploying the smart contract
# Compile the Smart Contract:
npx hardhat compile

# Test the Smart Contract
npx hardhat test

# Deploy the Token Contract
yes | npx hardhat ignition deploy ./ignition/modules/Token.js --network pharos










