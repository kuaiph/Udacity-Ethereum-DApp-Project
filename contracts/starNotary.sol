pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

//  Add a name and a symbol for your starNotary tokens
    string public constant name = "Star Registry Token";
    string public constant symbol = "SRT";

//

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    // to track ownership of stars
    struct Ownership {
        address owner;
        uint256 tokenId;
    }

    Ownership[] public ownership;


    function createStar(string _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);

        tokenIdToStarInfo[_tokenId] = newStar;

        _mint(msg.sender, _tokenId);

        //update ownership
        ownership.push(Ownership(msg.sender, _tokenId));
    }

// Add a function lookUptokenIdToStarInfo, that looks up the stars using the Token ID, and then returns the name of the star.
    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns(string) {
        return tokenIdToStarInfo[_tokenId].name;
    }

//

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0);

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);

        starOwner.transfer(starCost);

        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
        starsForSale[_tokenId] = 0;

        //switch ownership
        for(uint i = 0; i < ownership.length; i++) {
            if (ownership[i].tokenId == _tokenId) {
                ownership[i].owner = msg.sender;
            }
        }
    }

// Add a function called exchangeStars, so 2 users can exchange their star tokens...
//Do not worry about the price, just write code to exchange stars between users.
//
    function exchangeStars(address from, address to) public {

        require(from != address(0));
        require(to != address(0));

        for(uint i = 0; i < ownership.length; i++) {
            if (ownership[i].owner == from) {
                transferFrom(from, to, ownership[i].tokenId);
                ownership[i].owner = to;
            } else if (ownership[i].owner == to) {
                transferFrom(to, from, ownership[i].tokenId);
                ownership[i].owner = from;
            }
        }
    }

// Write a function to Transfer a Star. The function should transfer a star from the address of the caller.
// The function should accept 2 arguments, the address to transfer the star to, and the token ID of the star.
//
    function transferStar(address to, uint256 tokenId) public {
        transferFrom(msg.sender, to, tokenId);
        for(uint i = 0; i < ownership.length; i++) {
            if (ownership[i].tokenId == tokenId) {
                ownership[i].owner = to;
            } 
        }
    }
}
