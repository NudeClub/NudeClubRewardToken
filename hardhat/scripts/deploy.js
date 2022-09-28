const { ethers } = require("hardhat");


async function main() {

  const NudeClubRewardContract = await ethers.getContractFactory("NudeClubReward");

  const deployedContract = await NudeClubRewardContract.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

  await deployedContract.deployed();

  console.log(
    "NudeClubReward contract address: ",
    deployedContract.address
  );


}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
