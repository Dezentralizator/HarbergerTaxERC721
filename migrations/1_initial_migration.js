const Migrations = artifacts.require("Migrations");
const Harberger = artifacts.require("ERC721Harberger");

module.exports = function (deployer, network, accounts) {
  let [alice, bob, charlie] = accounts;
  deployer.deploy(Migrations);
  deployer.deploy(Harberger, "Harberger", "HBG", 10, {from :alice});
};
