const DoubleSpendProtected = artifacts.require("./DoubleSpendProtected.sol");

module.exports = deployer => {
  deployer.deploy(DoubleSpendProtected);
};
