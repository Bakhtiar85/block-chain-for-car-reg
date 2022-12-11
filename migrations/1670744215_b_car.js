var MyBcar = artifacts.require('./BCar.sol');

module.exports = function(deployer) {
  deployer.deploy(MyBcar);
};
