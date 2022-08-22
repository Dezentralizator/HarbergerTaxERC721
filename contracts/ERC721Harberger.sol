// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ERC721.sol";
import "./IERC721Harberger.sol";

contract ERC721Harberger is ERC721, IERC721Harberger{

  uint96 public constant month = 30 days;
  uint96 public constant mintingPrice = 0;
  uint96 public immutable harbergerRate; // In perTenThousand per month.
  address payable public immutable royaltyReceiver; // Can be set differently with DAO mechanisms if a setter function is implemented

  mapping (uint256 => HarbergerTax) private tokenHarbergerInfo;

  constructor(string memory name, string memory symbol, uint96 _harbergerRate) ERC721(name, symbol) {
    harbergerRate = _harbergerRate;
    royaltyReceiver = payable(msg.sender);
  }

  modifier isHarbergerTax(uint256 tokenId){
    require(msg.value>=getHarbergerTax(tokenId), "Transfer violates Haberger Token standard");
    royaltyReceiver.transfer(getHarbergerTax(tokenId));
    payable(msg.sender).transfer(msg.value-getHarbergerTax(tokenId)); // could be deleted and replaced as tip to royaltyReceiver
    _;
  }

  modifier harbergerReset(uint256 tokenId){
    _;
    HarbergerTax storage harb = tokenHarbergerInfo[tokenId];
    harb.currentPrice = getHarbergerPrice(tokenId); // guarantees that claim function will not be easier to invoke after transfer
    harb.lastChange = uint64(block.timestamp); // updates last purchase
    harb.accumulatedTax = 0; // resets tax
    emit NewHarbergerPrice(tokenId,harb.currentPrice);

  }

  function claim(uint256 tokenId) public payable harbergerReset(tokenId){
    require(msg.sender != ownerOf(tokenId));
    require(msg.value >= getHarbergerPrice(tokenId));
    bool sent = payable(ownerOf(tokenId)).send(tokenHarbergerInfo[tokenId].currentPrice);
    if (!sent) {
      royaltyReceiver.transfer(getHarbergerPrice(tokenId));
    } else {
    royaltyReceiver.transfer(getHarbergerTax(tokenId));
    }

    payable(msg.sender).transfer(msg.value-getHarbergerPrice(tokenId));
    _transfer(ownerOf(tokenId), msg.sender, tokenId);

    emit Claimed(tokenId, msg.sender);

  }

  function claimAndSetPrice(uint256 tokenId, uint96 price) external payable {

    claim(tokenId);
    tokenHarbergerInfo[tokenId].currentPrice = price;
    emit NewHarbergerPrice(tokenId,price);
    
  }

  function transferFrom(address from, address to, uint256 tokenId) public payable override 
  isHarbergerTax(tokenId) harbergerReset(tokenId) {
    super.transferFrom(from,to,tokenId);
  }
  function safeTransferFrom(address from, address to, uint256 tokenId) public payable override 
  isHarbergerTax(tokenId) harbergerReset(tokenId) {
    super.safeTransferFrom(from,to,tokenId);
  }
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override isHarbergerTax(tokenId) harbergerReset(tokenId) {
    super.safeTransferFrom(from,to,tokenId, data);
  }

  function setTokenPrice(uint256 tokenId, uint96 price) public {
    require (ownerOf(tokenId) == msg.sender, "Only token owner can set price");
    HarbergerTax storage stor = tokenHarbergerInfo[tokenId];
    stor.accumulatedTax += remainingTax(tokenId);
    stor.currentPrice = price;
    stor.lastChange = uint64(block.timestamp); 
    emit NewHarbergerPrice(tokenId,price);
 
  }

  function getHarbergerInfo(uint256 tokenId) public view returns(uint64,uint96,uint96) {
    HarbergerTax memory info = tokenHarbergerInfo[tokenId];
    return (info.lastChange,info.currentPrice,info.accumulatedTax);
  }
  function getHarbergerTax(uint256 tokenId) public view returns (uint96){

    return tokenHarbergerInfo[tokenId].accumulatedTax+remainingTax(tokenId);
  } 

  function getHarbergerPrice(uint256 tokenId) public view returns (uint96){
    return tokenHarbergerInfo[tokenId].currentPrice + getHarbergerTax(tokenId);
  }

  function remainingTax(uint256 tokenId) public view returns (uint96 openTax) {
    openTax = tokenHarbergerInfo[tokenId].currentPrice*harbergerRate
    *uint96((block.timestamp-tokenHarbergerInfo[tokenId].lastChange))/(10000*month);
  }
  /**
  Very basic mint function
  @dev Mock mint to be replaced with real mint function */
  function mint(uint256 tokenId) external payable{
    require(msg.value >= mintingPrice);
    payable(msg.sender).transfer(msg.value-mintingPrice);
    _safeMint(msg.sender, tokenId);
    HarbergerTax storage harb = tokenHarbergerInfo[tokenId];
    harb.currentPrice = mintingPrice; // guarantees that claim function will not be easier to invoke after transfer
    harb.lastChange = uint64(block.timestamp); // updates last purchase
    harb.accumulatedTax = 0; // resets tax
    
  }

}


