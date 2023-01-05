const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const { keccak256 } = ethers.utils;

// We're deploying a new contract and addresses in each test here
// This is only to test the basic functionally so far

/*
const whitelistArray = [
  "0x79Ea2d536b5b7144A3EabdC6A7E43130199291c0",
  "0x18c37f21D3C29f9a53A96CA678026DC660180065",
  "0x4B7E3FD09d45B97EF1c29085FCAe143444E422e8",
];

const padBuffer = (addr) => {
  return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
};
const leaves = whitelistArray.map((address) => padBuffer(address));
const tree = new MerkleTree(leaves, keccak256, { sort: true });

const merkleRoot = tree.getHexRoot();
*/

describe("Nude Club Reward contract", function () {
  it("User can mint NFT after mint started and number minted increments correctly", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);
    const notWhitelisted = accounts.slice(5, 10);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();
    const merkleProof = tree.getHexProof(padBuffer(whitelisted[0].address));


    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Whitelisted mints for 0.04
    await NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof,{ value: ethers.utils.parseEther("0.04") });

    // Non whitelisted mints for 0.08
    await NudeClubRewardContract.connect(notWhitelisted[0]).mint(1, merkleProof,{ value: ethers.utils.parseEther("0.08") });


    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(2);

  });

  it("User can only mint 5 tokens", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();
    const merkleProof = tree.getHexProof(padBuffer(whitelisted[0].address));

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await NudeClubRewardContract.connect(whitelisted[0]).mint(5, merkleProof, { value: ethers.utils.parseEther("0.2") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(5);

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.04") })
    ).to.be.revertedWith("Only 5 per address");

    // Confirm still only 5 minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(5);

  });


  it("User can only mint reward token after contract has been unpaused", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();
    const merkleProof = tree.getHexProof(padBuffer(whitelisted[0].address));

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await expect ( 
        NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.01") })
    ).to.be.revertedWith("contract paused");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.04") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(1);

  });

  it("Only owner can pause/unpause contract", async function () {
  
    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    await expect (
        NudeClubRewardContract.connect(whitelisted[1]).setMintActive(true)
    ).to.be.revertedWith("Ownable: caller is not the owner")

    expect(await NudeClubRewardContract.mintActive()).to.equal(false);

    await NudeClubRewardContract.connect(whitelisted[0]).setMintActive(true);

    expect(await NudeClubRewardContract.mintActive()).to.equal(true);  
  
  });

  it("User cannot mint NFT for more or less than 0.04 eth per nft if whitelisted", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();
    const merkleProof = tree.getHexProof(padBuffer(whitelisted[0].address));

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Contract should revert transaction
    await expect( 
      NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.03") })
    ).to.be.revertedWith("Incorrect amount of eth sent");

      // Contract should revert transaction
      await expect( 
        NudeClubRewardContract.connect(whitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.08") })
    ).to.be.revertedWith("Incorrect amount of eth sent");
  });

  it("User cannot mint NFT for more or less than 0.08 eth per nft if not whitelisted", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);
    const notWhitelisted = accounts.slice(5, 100000);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();
    const merkleProof = tree.getHexProof(padBuffer(notWhitelisted[0].address));

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Contract should revert transaction
    await expect( 
      NudeClubRewardContract.connect(notWhitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.04") })
    ).to.be.revertedWith("Incorrect amount of eth sent");

      // Contract should revert transaction
      await expect( 
        NudeClubRewardContract.connect(notWhitelisted[0]).mint(1, merkleProof, { value: ethers.utils.parseEther("0.1") })
    ).to.be.revertedWith("Incorrect amount of eth sent");
  });


  it("Only owner can withdraw", async function () {

    const accounts = await hre.ethers.getSigners();
    const whitelisted = accounts.slice(0, 5);

    const padBuffer = (addr) => {
      return Buffer.from(addr.substr(2).padStart(32 * 2, 0), "hex");
    };

    const leaves = whitelisted.map((account) => padBuffer(account.address));
    const tree = new MerkleTree(leaves, keccak256, { sort: true });
    const merkleRoot = tree.getHexRoot();


    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E", merkleRoot);

    // Only owner can unpause the contract
    await NudeClubRewardContract.setMintActive(true);

    // Contract should let owner withdraw 
    await NudeClubRewardContract.connect(whitelisted[0]).withdraw();

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(whitelisted[1]).withdraw()
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

});