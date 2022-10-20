//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
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

contract NudeClubReward is ERC721Enumerable, Ownable {

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
    address multsigWallet;

    modifier IsPaused() {
        require(!paused, "contract paused");
        _;
    }

    /// @dev We define the NFT URI and multisig wallet address when creating the contract 
    /// @param _baseURI IPFS metadata folder link
    /// @param _multisigWallet Wallet address we want to withdraw any eth in this contract to
    constructor(string memory _baseURI, address _multisigWallet) ERC721("Nude Club Reward Token", "NUDE") {
        baseTokenURI = _baseURI;
        multsigWallet = _multisigWallet;
    }

    /// @dev Mint same NFT to every user, add their address to the array 
    /// and mapping to verify, ensure we can't add any address twice or mint twice
    /// Currently we can only mint to 500 users and it costs 0.002eth + txn fee to mint 
    function mint() public payable IsPaused {
        uint _numberOfUsersMinted = numberOfUsersMinted;
        require(_numberOfUsersMinted <= 500, "None left");
        require(balanceOf(msg.sender) == 0, "One per address");
        require(msg.value == 0.002 ether, "Wrong value");
        require(!addressCheck[msg.sender]);
        ++numberOfUsersMinted;
        ++_numberOfUsersMinted;
        addressCheck[msg.sender] = true;
        rewardArray[_numberOfUsersMinted] = msg.sender;
        _safeMint(msg.sender, _numberOfUsersMinted);
    }

    /// @dev For turning the mint on/off
    /// @param _paused if paused == true, the mint cannot be called
    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    /// @dev overwriting erc721 tokenURI to use our own, this returns the correct IPFS data when minting 
    /// @param _tokenId ID which we increcement with each mint 
	function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
		require(_exists(_tokenId), "ERC721: invalid token ID");

		string memory baseURI = baseTokenURI;
		// Attach tokenID so it can find the token stored on IPFS
		return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
	}

    /// @dev Withdraw to wallet address defined in the constructor
	function withdraw() public onlyOwner {
		uint256 amount = address(this).balance;
		(bool sent, ) =  multsigWallet.call{value: amount}("");
		require(sent, "Failed to send Ether");
	}
}
