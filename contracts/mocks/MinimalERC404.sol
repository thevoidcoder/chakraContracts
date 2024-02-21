//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC404} from "../ERC404.sol";

contract TierERC404 is Ownable, ERC404 {
    mapping(uint => string) public tierNames;
    mapping(uint => string) public tierImages;
    string[] private colors = ["Red", "Green", "Blue", "Yellow"];
    string[] private sizes = ["Small", "Medium", "Large", "X-Large"];
    struct NFTData {
        string color;
        string size;
        string image;
        string tier;
    }

    string NFTPACKName = "Number #";
    string NFTPackDescription = "An NFTPACKName NFT";

    constructor(
      string memory name_,
      string memory symbol_,
      uint8 decimals_,
      uint128 _supply,
      address initialOwner_,
      bool _isERC721ClassificationEnabled_
    ) ERC404(name_, symbol_, decimals_, _isERC721ClassificationEnabled_) Ownable(
      initialOwner_
    ) {
      _mintERC20(initialOwner_, _supply*10**decimals_, false);
      uint _collectionSize = (_supply*10**decimals_)/100;

      uint[] memory collectionSizes = new uint[](4);
      collectionSizes[0] = _collectionSize*1;
      collectionSizes[1] = _collectionSize*2;
      collectionSizes[2] = _collectionSize*3;
      collectionSizes[3] = _collectionSize*4;

      
      tierNames[_collectionSize*1] = "Common";
      tierNames[_collectionSize*2] = "Uncommon";
      tierNames[_collectionSize*3] = "Rare";
      tierNames[_collectionSize*4] = "Legendary";

      tierImages[_collectionSize*1] = "ipfs://";
      tierImages[_collectionSize*2] = "ipfs://";
      tierImages[_collectionSize*3] = "ipfs://";
      tierImages[_collectionSize*4] = "ipfs://";

      _setClassificationSize(collectionSizes);
      _setWhitelist(initialOwner_, true);
    }


  function setTierImage(uint tier_, string memory image_) external onlyOwner {
    tierImages[tier_] = image_;
  }

    function mintERC20(
      address account_,
      uint256 value_,
      bool mintCorrespondingERC721s_
    ) external onlyOwner {
      _mintERC20(account_, value_, mintCorrespondingERC721s_);
    }

    // function _setClassificationSize(uint256[] memory _classificationSize) public {
    // classificationSize = _classificationSize;
  // }

    function _setClassificationSize(uint[] memory _classificationSize) override public onlyOwner {
        classificationSize = _classificationSize;
    }

    function _setERC721ClassificationEnabled(bool _isERC721ClassificationEnabled) override public onlyOwner{
        isERC721ClassificationEnabled = _isERC721ClassificationEnabled;
    }
    


    function _generateTraitsForTokenId(uint256 tokenId) internal view returns (NFTData memory) {
        // Use the token ID to generate traits deterministically
        uint256 rand = uint256(keccak256(abi.encodePacked(tokenId)));
        (uint256 nft_tier,) = getTokenTierAndIndex(tokenId);

        string memory color = colors[rand % colors.length];
        string memory size = sizes[(rand / colors.length) % sizes.length];
        string memory tier = tierNames[nft_tier];
        string memory image = tierImages[nft_tier];

        return NFTData(color, size, image, tier);
    }

    function tokenURI(uint256 id_) public view override returns (string memory) {
        NFTData memory traits = _generateTraitsForTokenId(id_);
        string memory json = string(
            abi.encodePacked(
                '{"name": "',
                NFTPACKName,
                Strings.toString(id_),
                '", "description": "',
                NFTPackDescription,
                '", "image": "',
                traits.image,
                '", "attributes": [',
                '{"trait_type": "Color", "value": "',
                traits.color,
                '"},',
                '{"trait_type": "Size", "value": "',
                traits.size,
                '"},',
                '{"trait_type": "Tier", "value": "',
                traits.tier,
                '"}',
                "]}"
            )
        );

      return string(abi.encodePacked("data:application/json;utf8,", json));
    }

    function setWhitelist(address account_, bool value_) external onlyOwner {
      _setWhitelist(account_, value_);
    }
}
