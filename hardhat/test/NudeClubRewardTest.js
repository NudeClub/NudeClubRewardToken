const { expect } = require("chai");
const { ethers } = require("hardhat");

// We're deploying a new contract and addresses in each test here
// This is only to test the basic functionally so far
// I've used dummy IPFS metadata here, we want to replace that with a real test set of 500 reward tokens

describe("Nude Club Reward contract", function () {
  it("User can mint NFT after mint started and number minted increments correctly", async function () {

    const [addr1] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Happy path - owner successfully mints 1 nude club pass for this collection
    await NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.amountMinted()).to.equal(1);

  });

  it("User can only mint one NFT", async function () {

    const [addr1] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Happy path - owner successfully mints 1 nude club pass for this collection
    await NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.amountMinted()).to.equal(1);

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") })
    ).to.be.revertedWith("One per address");

  });

  it("User can only mint for 0.002 eth", async function () {

    const [addr1, addr2] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Happy path - owner successfully mints 1 nude club pass for this collection
    await NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.amountMinted()).to.equal(1);

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(addr2).mint({ value: ethers.utils.parseEther("1") })
    ).to.be.revertedWith("Wrong value");

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(addr2).mint({ value: ethers.utils.parseEther("0.001") })
    ).to.be.revertedWith("Wrong value");

  });


  it("500 passes minted to 500 addresses works correctly", async function () {

    // TODO **

    // Get signers for 500 addresses
    //for(let i=0; i < 500; i++) {
    //    string 
    //    const [addr+i] = await ethers.getSigners();
   // }
   //const [addr+i, addr2] = await ethers.getSigners();
/*
   const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Mint a reward token to each address 
    for(let i=0; i < 500; i++) {
        await NudeClubRewardContract.connect(i).mint({ value: ethers.utils.parseEther("0.002") });
    }

    // Confirm one pass minted
    expect(await NudeClubRewardContract.amountMinted()).to.equal(500);
  */
  });

  it("User can only mint reward token after contract has been unpaused", async function () {

    const [addr1] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Happy path - owner successfully mints 1 nude club pass for this collection
    await expect ( 
        NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") })
    ).to.be.revertedWith("contract paused");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.amountMinted()).to.equal(0);

    // Happy path - owner successfully mints 1 nude club pass for this collection
    await NudeClubRewardContract.connect(addr1).mint({ value: ethers.utils.parseEther("0.002") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.amountMinted()).to.equal(1);

  });

  it("Only owner can pause/unpause contract", async function () {
  
    const [addr1, addr2, addr3] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    const NudeClubRewardContract = await NudeClubReward.deploy("ipfs://QmSyrVNtDaXoEDEEBa6uuYVTFfPmWoLNGmgDhoU9KkPpha/");

    await expect (
        NudeClubRewardContract.connect(addr2).setPaused(false)
    ).to.be.revertedWith("Ownable: caller is not the owner")

    expect(await NudeClubRewardContract.paused()).to.equal(true);

    await NudeClubRewardContract.connect(addr1).setPaused(false);

    expect(await NudeClubRewardContract.paused()).to.equal(false);  
  
  });

});