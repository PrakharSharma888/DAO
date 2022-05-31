require("@nomiclabs/hardhat-waffle");
require("dotenv").config({path: ".env"});

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;
const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;

module.exports = {
  solidity: "0.8.4",
  networks : {
    rinkeby : {
      url : ALCHEMY_API_KEY_URL,
      accounts : [RINKEBY_PRIVATE_KEY]
    },
  },
};
// marketplace - 0xfC4Bf7851225fDe2777BA8a491bF41d0fbbF067b
// dao - 0x3F4D531c580167C1863A4BbdC083D641A5CB3C4C