pragma solidity ^0.4.11;

contract DoubleSpendProtected {
	address public owner_;
	address public stackAccount_;

	// Amount that is "Locked" in to be spent
	uint public lockedToSpend_;

	/**
	 * @dev Contructor to set owner and stack account address.
	 * @param _stackAccount The EOA owned by stack.
	 */
	function DoubleSpendProtected(address _stackAccount) {
		owner_ = msg.sender;
		stackAccount_ = _stackAccount;
	}

	/**
	 * @dev deposit ether.
	 */
	function deposit() external payable { }

	/**
	 * @dev The owner may lock funds in order to be utilized with a merchant for example.
	 * The funds are effectively owned by the stack account and may not be manipulated
	 * by the user.
	 * @param _amount The amount of funds to lock in.
	 */
	function lockFunds(uint _amount) external {
		require(msg.sender == owner_);
		require(this.balance >= _amount);

		lockedToSpend_ += _amount;
	}

	/**
	 * @dev Unlock funds from being able to be spent at merchant. This may only be
	 * done by the stack account.
	 * @param _amount The amount of funds to unlock.
	 */
	function unLockFunds(uint _amount) external {
		require(msg.sender == stackAccount_);
		require(lockedToSpend_ >= _amount);

		lockedToSpend_ -= _amount;
	}

	/**
	 * @dev Withdraw ether out of this contract.
	 * @param _amount The amount of ether to withdraw.
	 */
	function withdraw(uint _amount) external {
		require(msg.sender == owner_);

		uint availableToWithdraw = this.balance - lockedToSpend_;
		require(availableToWithdraw >= _amount);

		msg.sender.transfer(_amount);
	}

	/**
	 * @dev Spend ether at POS.
	 * @param _amount The amount of funds to lock in.
	 */
	function spend(uint _amount) external {
		require(msg.sender == stackAccount_);
		require(lockedToSpend_ >= _amount);

		lockedToSpend_ -= _amount;
		stackAccount_.transfer(_amount);
	}
}
