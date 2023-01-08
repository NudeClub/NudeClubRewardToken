const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const { keccak256 } = ethers.utils;
const {readFileSync} = require('fs');


async function main() {

  const whitelistFile = readFileSync('./whitelist.txt', 'utf-8');
  const whitelistArray = whitelistFile.split(/\r?\n/);
  console.log(whitelistArray); 

  const padBuffer = (addr) => {
    return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
  };
  
  const leaves = whitelistArray.map((address) => padBuffer(address));
  const tree = new MerkleTree(leaves, keccak256, { sort: true });
  
  const merkleRoot = tree.getHexRoot();

  const NudeClubRewardContract = await ethers.getContractFactory("NudeClubReward");

  const deployedContract = await NudeClubRewardContract.deploy("QmVjZ3ua2FVigmAVFNS9Cig9bRWjCsmm4S1ritVHq6DcVc", merkleRoot);

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
