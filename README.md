# HarbergerTaxERC721
A potential implementation of the HarbergerTax close to ERC721 from openzeppelin

This implementation allows to add claim function for people to purchase their NFTs at their disclaimed HarbergerPrice.
It still needs to be more tested.

Every transfer is taxed through the Harberger Tax.
This first implementation has the HarbergerTax transferred to an address defined in the constructor but could be set differently.

Users can choose to either set a low HarbergerPrice and transfer fees will grow slowly.
In case someone does not ever want to transfer his token, he can set up an absurdly high HarbergerPrice, and the tax will also grow very high.
This is more a feature than a bug, since it allows people to virtually declare soulbound NFTs without

The usage of struct HarbergerTax reduces gas costs, but causes the use of uint96 for prices. 
In case this is considered too dangerous, making only use of uint256 for every integer variable could be envisionned.

Reminder--
The use of the transfer function is potentially dangerous-
A malicious address could have a fallback function consuming more than the 23000 allocated gas forcing reverts.
