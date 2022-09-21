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

contract NudeClubPOAP is ERC721Enumerable, Ownable {
    uint256 public maxTokens;
    address public nudeClubRewardContract;
    string _baseTokenURI;

    constructor(string memory baseURI) ERC721("Nude Club Reward Token", "NUDE") {
        _baseTokenURI = baseURI;
    }

    function mint() public payable {
        require(maxTokens < 500, 'None left');
        require(msg.sender == tx.origin, 'EOAs only');
        require(balanceOf(msg.sender) == 0, 'One per address');
        require(msg.value == 0.01 ether, 'Wrong value');

        unchecked {
            ++maxTokens;
        }
        _safeMint(msg.sender, maxTokens);
    }

    function redeem(address holder, uint tokenID) public {
        require(msg.sender == nudeClubRewardContract, 'To be called to redeem reward');
        require(ownerOf(tokenID) == holder);
        _burn(tokenID);
    }

    function setNudeClubRewardContract(address newAddress) public onlyOwner {
        nudeClubRewardContract = newAddress;
    }

    function withdrawAll() public onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}