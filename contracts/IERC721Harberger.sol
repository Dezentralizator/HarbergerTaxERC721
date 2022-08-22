// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
/**
@author Dezentralizator
@notice An example of interface to use as Harberger Tax */

interface IERC721Harberger {

  struct HarbergerTax{
    uint64 lastChange;
    uint96 currentPrice;
    uint96 accumulatedTax;
  }

  event Claimed(uint256 tokenId, address _claimer);

  event NewHarbergerPrice(uint256 tokenId, uint96 price);

  /**
  @dev the famous Haberger transfer, allows anyone to claim the NFT at its listed price.
  */
  function claim(uint256 tokenId) external payable;

  /**
  @dev Haberger transfer allowing to choose reset price
  */
  function claimAndSetPrice(uint256 tokenId, uint96 price) external payable;

  /** 
  @dev sets the price of token at which anyone can buy the NFT
  */
  function setTokenPrice(uint256 tokenId, uint96 price) external;

  function getHarbergerInfo(uint256 tokenId) external view returns(uint64,uint96,uint96);
  /**
  @dev allows to easily fetch information about the previous tax accumulated
  */
  function getHarbergerTax(uint256 tokenId) external view returns (uint96);

  /**
  @dev returns the total price needed to activate a transfer
   */
  function getHarbergerPrice(uint256 tokenId) external view returns (uint96);

   /**
  @dev returns the tax caused by ongoing pricing period.
  */
  function remainingTax(uint256 tokenId) external view returns (uint96 openTax);



}
