//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

 
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
    uint256 public maxTokens;
    address public nudeClubRewardContract;
    string _baseTokenURI;
    mapping(address => bool) rewardRedeemable;

    constructor(string memory baseURI) ERC721("Nude Club Reward Token", "NUDE") {
        _baseTokenURI = baseURI;
    }

    function mint() public payable {
        require(maxTokens < 500, 'None left');
        require(msg.sender == tx.origin, 'EOAs only');
        require(!rewardRedeemable[msg.sender], "Address already ready to redeem reward");
        require(balanceOf(msg.sender) == 0, 'One per address');
        require(msg.value == 0.01 ether, 'Wrong value');
        ++maxTokens;
        rewardRedeemable[msg.sender] = true;
        _safeMint(msg.sender, maxTokens);
    }

    // Reward function defined in the future will call this function to burn the NFT
    // and remove the address from the award list. If the function returns true to our
    // reward function we can proceed and reward the address
    function redeemReward(address holder, uint tokenID) public returns (bool) {
        require(msg.sender == nudeClubRewardContract, 'To be called to redeem reward');
        require(ownerOf(tokenID) == holder);
        require(rewardRedeemable[msg.sender]);
        _burn(tokenID);
        rewardRedeemable[msg.sender] = false;
        return true;
    }

    function setNudeClubRewardContract(address newAddress) public onlyOwner {
        nudeClubRewardContract = newAddress;
    }

    function withdrawAll() public onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}