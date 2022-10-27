//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

 
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

	using Strings for uint256;

    // Array of addresses we will use later on to distribute rewards
    address[500] public rewardArray;
    // Mapping to check if address is in array yet
    mapping (address => bool) addressCheck;
    // Count of how many users have minted rewards
    uint256 public numberOfUsersMinted;
    // Token metadata link
    string baseTokenURI;
    // Flag to stop/start reward minting
    bool public paused = true;
    // Multisig wallet to withdraw to 
    address immutable multsigWallet;

    modifier IsPaused() {
        require(!paused, "contract paused");
        _;
    }

    /// @dev We define the NFT URI and multisig wallet address when creating the contract   
    /// @param _multisigWallet Wallet address we want to withdraw any eth in this contract to
    constructor(address _multisigWallet) ERC1155("https://ipfs.io/ipfs/QmVM4XtXn9urEmZz7ToHp1gLZZAnM1sxFFL6KtdaAQDwfT/{id}.json") {
        multsigWallet = _multisigWallet;
    }

    /// @dev Mint same NFT to every user, add their address to the array 
    /// and mapping to verify, ensure we can't add any address twice or mint twice
    /// Currently we can only mint to 500 users and it costs 0.002eth + txn fee to mint 
    function mint() public payable IsPaused {
        uint _numberOfUsersMinted = numberOfUsersMinted;
        require(_numberOfUsersMinted <= 500, "None left");
        require(balanceOf(msg.sender, 1) == 0, "One per address");
        require(!addressCheck[msg.sender]);
        ++numberOfUsersMinted;
        ++_numberOfUsersMinted;
        addressCheck[msg.sender] = true;
        rewardArray[_numberOfUsersMinted] = msg.sender;
        //_safeMint(msg.sender, _numberOfUsersMinted);
        _mint(msg.sender, 1, 1, "");
    }

    /// @dev For turning the mint on/off
    /// @param _paused if paused == true, the mint cannot be called
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }


    /// @dev Withdraw to wallet address defined in the constructor
	function withdraw() public onlyOwner {
		uint256 amount = address(this).balance;
		(bool sent, ) =  multsigWallet.call{value: amount}("");
		require(sent, "Failed to send Ether");
	}
}
