const DoubleSpendProtected = artifacts.require('./DoubleSpendProtected.sol');

contract('DoubleSpendProtected', accounts => {
  const owner = accounts[0]
  const stackAccount = accounts[1]

  it('should not allow double spending', async () => {

    const doubleSpendProtected = await DoubleSpendProtected.new(stackAccount)

    // Fund wallet
    await doubleSpendProtected.deposit({ from: owner, value: 100 })
    assert.equal(
      web3.eth.getBalance(doubleSpendProtected.address).toNumber(),
      100
    )

    // Lock funds for POS
    await doubleSpendProtected.lockFunds(50, { from: owner })
    assert.equal(
      await doubleSpendProtected.lockedToSpend_(),
      50
    )

    // Spend at POS
    await doubleSpendProtected.spend(10, { from: stackAccount })
    assert.equal(
      await doubleSpendProtected.lockedToSpend_(),
      40
    )
    assert.equal(
      web3.eth.getBalance(doubleSpendProtected.address).toNumber(),
      90
    )

    // Try to withdraw greater than balance but less than available
    // Balance - locked
    try {
      await doubleSpendProtected.withdraw(60, { from: owner })
      assert(false, 'withdraw did not throw!')
    } catch(err) {
      assert(true)
    }

    // Stack unlocks funds
    await doubleSpendProtected.unLockFunds(40, { from: stackAccount })
    assert.equal(
      await doubleSpendProtected.lockedToSpend_(),
      0
    )

    // Withdraw entire balance
    await doubleSpendProtected.withdraw(90, { from: owner })
    assert.equal(
      web3.eth.getBalance(doubleSpendProtected.address).toNumber(),
      0
    )
  });
});
