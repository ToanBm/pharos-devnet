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

# Step 6: Create script to deploy

# Step 7: Deploying the smart contract
# Compile the Smart Contract:
npx hardhat compile

# Test the Smart Contract
npx hardhat test

# Step 8: Deploying the smart contract
echo "Do you want to deploy multiple contracts?"
read -p "Enter the number of contracts to deploy: " COUNT

# Validate input (must be a number)
if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
  echo "Please enter a valid number!"
  exit 1
fi

for ((i=1; i<=COUNT; i++))
do
  echo "🚀 Deploying contract $i..."

  # Deploy the contract and extract the contract address
  rm -rf ignition/deployments
  CONTRACT_ADDRESS=$(yes | npx hardhat ignition deploy ./ignition/modules/Token.js --network pharos --reset | grep -oE '0x[a-fA-F0-9]{40}')

  # Check if an address was retrieved
  if [[ -z "$CONTRACT_ADDRESS" ]]; then
    echo "❌ Unable to retrieve contract address!"
    exit 1
  fi

  echo "✅ Contract $i deployed at: $CONTRACT_ADDRESS"
  echo "-----------------------------------"

  # Generate a random wait time between 9-15 seconds
  RANDOM_WAIT=$((RANDOM % 7 + 9))
  echo "⏳ Waiting for $RANDOM_WAIT seconds before deploying the next contract..."
  sleep $RANDOM_WAIT
done

echo "🎉 Successfully deployed $COUNT contracts!"





