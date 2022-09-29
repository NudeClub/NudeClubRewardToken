require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
require("hardhat-gas-reporter");

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const REPORT_GAS = process.env.REPORT_GAS;

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY],
    },
  },

  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false
  }
};
