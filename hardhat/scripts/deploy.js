const {ethers} = require("hardhat");
const { CRYPTODEVS_NFT_CONTRACT_ADDRESS } = require('../constrants/index')

async function main() {
  // first the fake marketplace nft contract
  const MarketPlace = await ethers.getContractFactory("FakeNFTMarketplace");
  const marketplace = await MarketPlace.deploy();

  await marketplace.deployed();

  console.log("CryptoDevs Marketplace deployed to : ", marketplace.address);


  // then the cryptodevs DAO contract

  const DAO = await ethers.getContractFactory("CryptoDevs");
  const dao = await DAO.deploy(
    marketplace.address,
    CRYPTODEVS_NFT_CONTRACT_ADDRESS,
    {
      value : ethers.utils.parseEther("0.5")
    }
  );

  await dao.deployed();

  console.log("\n CryptoDevs DAO deployed to : ", dao.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
