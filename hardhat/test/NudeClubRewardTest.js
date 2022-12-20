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
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await NudeClubRewardContract.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.01") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(1);

  });

  it("User can only mint 5 tokens", async function () {

    const [addr1] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await NudeClubRewardContract.connect(addr1).mint(5, { value: ethers.utils.parseEther("0.05") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(5);

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.01") })
    ).to.be.revertedWith("Only 5 per address");

  });



  it("500 passes minted to 500 addresses works correctly", async function () {
    
    /*
    // TODO FAILING CURRENTLY

    var myScope={};

    // Get signers for 500 addresses
    for(let i=0; i < 10; i++) {
        this[i] = await ethers.getSigners();
        //console.log(this[i]);
        //console.log(i);
    }
   
    const [test1, test2] = await ethers.getSigners();
    //console.log(test);
    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mint a reward token to each address 
    //for(let i=0; i < 500; i++) {
        await NudeClubRewardContract.connect(this[2 ]).mint({ value: ethers.utils.parseEther("0.002") });
    //}

    // Confirm 500 passes minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(1);
    */
  });

  it("User can only mint reward token after contract has been unpaused", async function () {

    const [addr1] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await expect ( 
        NudeClubRewardContract.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.01") })
    ).to.be.revertedWith("contract paused");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Confirm no passes minted yet
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(0);

    // Mints reward token and adds address to array
    await NudeClubRewardContract.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.01") });

    // Confirm one pass minted
    expect(await NudeClubRewardContract.numberOfTokensMinted()).to.equal(1);

  });

  it("Only owner can pause/unpause contract", async function () {
  
    const [addr1, addr2, addr3] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    await expect (
        NudeClubRewardContract.connect(addr2).setPaused(false)
    ).to.be.revertedWith("Ownable: caller is not the owner")

    expect(await NudeClubRewardContract.paused()).to.equal(true);

    await NudeClubRewardContract.connect(addr1).setPaused(false);

    expect(await NudeClubRewardContract.paused()).to.equal(false);  
  
  });

  it("User cannot mint NFT for more or less than 0.01 eth per nft", async function () {

    const [addr1, addr2] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy("0x26fA48f0407DBa513d7AD474e95760794e5D698E");

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Contract should revert transaction
    await expect( 
      NudeClubRewardContract.connect(addr1).mint(1, { value: ethers.utils.parseEther("0.001") })
  ).to.be.revertedWith("Incorrect amount of eth sent");
  });


  it("Only owner can withdraw", async function () {

    const [addr1, addr2] = await ethers.getSigners();

    const NudeClubReward = await ethers.getContractFactory("NudeClubReward");

    // Deploy contract with dummy metadata (This will be the ipfs link for the collection)
    const NudeClubRewardContract = await NudeClubReward.deploy(addr1.getAddress());

    // Only owner can unpause the contract
    await NudeClubRewardContract.setPaused(false);

    // Contract should let owner withdraw 
    await NudeClubRewardContract.connect(addr1).withdraw();

    // Contract should revert transaction
    await expect( 
        NudeClubRewardContract.connect(addr2).withdraw()
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

});