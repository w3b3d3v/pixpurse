require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545", // This is the default URL and port for Hardhat's built-in node
      accounts: [process.env.PRIVATE_KEY], // Your Ethereum private key
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.PRIVATE_KEY], // Your Ethereum private key
      gasPrice: 20000000000, // 20 Gwei
      gasLimit: 5000000,
    },
  },
}
