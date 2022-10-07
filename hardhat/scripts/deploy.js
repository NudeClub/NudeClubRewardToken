const { ethers } = require("hardhat");


async function main() {

  const NudeClubRewardContract = await ethers.getContractFactory("NudeClubReward");

  const deployedContract = await NudeClubRewardContract.deploy("ipfs://QmTgGEQHyw5fJVDjYjszH6SGGcZjR4p4jkTjvrwquBfE96/", "0x26fA48f0407DBa513d7AD474e95760794e5D698E");

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
