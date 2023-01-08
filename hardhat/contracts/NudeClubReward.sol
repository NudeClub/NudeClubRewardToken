//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

 
/*  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣤⣄⡀⠀⠤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣷⣦⡈⠻⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡈⢻⣿⣿⣦⡀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⢻⣿⣿⣿⣄⠀⠀⠀⠀
    ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⣿⣿⣿⣿⡀⠀⠀⠀
    ⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⢸⣿⣿⣿⡇⠀⠀⠀
    ⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⣸⣿⣿⣿⡇⠀⠀⠀
    ⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣿⣿⣿⣿⠀⠀⠀⠀
    ⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢀⣾⣿⣿⣿⡟⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢀⣾⣿⣿⡿⠋⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⡿⠟⢁⣴⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  */

contract NudeClubReward is ERC1155, Ownable {

    // Count of how many users have minted rewards
    uint256 public numberOfTokensMinted;
    // Flag to stop/start minting
    bool public mintActive = false;
    // Multisig wallet to withdraw to
    address immutable multsigWallet;

    bytes32 immutable public merkleRoot;

    uint256 whitelistPrice = 0.04 ether;
    uint256 publicPrice = 0.08 ether;

    modifier IsMintActive() {
        require(mintActive, "contract paused");
        _;
    }

    /// @dev We define the multisig wallet address when creating the contract   
    /// @param _multisigWallet Wallet address we want to withdraw any eth in this contract to
    constructor(address _multisigWallet, bytes32 _merkleRoot) ERC1155("https://ipfs.io/ipfs/QmVCPmxzCR4rB636Ghh5PqXfy56XNJ6NGY5oHr6Hjeso8X/{id}.json") {
        multsigWallet = _multisigWallet;
        merkleRoot = _merkleRoot;
    }

    /// @dev Mint same NFT to every user, users can mint 5 each
    /// Only 10,000 tokens in total can be minted, prices decided above
    function mint(uint256 _amount, bytes32[] calldata merkleProof) public payable IsMintActive {

        uint256 price;

        if(MerkleProof.verify(merkleProof, merkleRoot, toBytes32(msg.sender)) == true) {
            price = whitelistPrice;
        } else {
            price = publicPrice;
        }

        require(msg.value == price * _amount, "Incorrect amount of eth sent");
        require(numberOfTokensMinted + _amount < 10000, "Cannot mint more than 10k tokens");
        require(balanceOf(msg.sender, 1) + _amount <= 5 , "Only 5 per address");
        numberOfTokensMinted += _amount;
        _mint(msg.sender, 1, _amount, "");
    }

    /// @dev For turning the mint on/off
    /// @param _mintActive if mintActive == true, users can mint
    function setMintActive(bool _mintActive) public onlyOwner {
        mintActive = _mintActive;
    }

    /// @notice Used to update the mint price after launch
    function updatePrices(uint256 _whitelistPrice, uint256 _publicPrice) public onlyOwner {
        whitelistPrice = _whitelistPrice;
        publicPrice = _publicPrice;
    }

    function toBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    /// @dev Withdraw to wallet address defined in the constructor
	function withdraw() public onlyOwner {
		uint256 amount = address(this).balance;
		(bool sent, ) =  multsigWallet.call{value: amount}("");
		require(sent, "Failed to send Ether");
	}
}
