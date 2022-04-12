// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity >=0.7.0 <0.9.0;

contract Diploma is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string baseURI;
    string public baseExtension = ".json";
    // Diploma cost is 1 ETH, by default, but can be set higher or lower later if needed.
    uint256 public cost = 0 ether;

    // A student can not have a duplicate diploma.
    uint256 public maxSupply = 1;

    // Default time to deploy the NFT. The University can set this number in days later.
    uint time_to_deploy =0;

    // An event to be emitted to integrate with outside apps when the university sets a time delayed NFT release.
    event time_set(uint time_to_deploy);

    // University can manually change the name and symbol in the smart contract.
       constructor(
        string memory name,
        string memory symbol,
        string memory _initBaseURI
    ) 
    
    ERC721(name, symbol) {
        setBaseURI(_initBaseURI);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply <= maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= cost);
        }
        if (block.timestamp >= time_to_deploy + 0 days) {
        _safeMint(msg.sender, supply + 1);
        }
    }   


    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // Only owner

    // The University can set the cost of the diploma in ETH, if the student has an outstanding balance.
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    // University can set the NFT deployment time.
    function set_deploy_time(uint input) public onlyOwner returns(uint time_to_deploy) {
     time_to_deploy = input;
     emit time_set(input);
    }
}
