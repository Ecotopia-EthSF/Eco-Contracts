// SPDX-License-Identifier: None
pragma solidity ^0.8.6;

// Import this file to use console.log
import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAaveLendingPool.sol";

contract Carbon is Ownable {
  using SafeMath for uint256;

  address aaveLendingPool = 0xCdc2854e97798AfDC74BC420BD5060e022D14607;

  uint256 MAX_INT = 2**256 - 1;

  struct Staker {
    uint256 amount;
  }

  event StakedTokens(address staker, uint256 amount);
  event WithdrawnTokens(address staker, uint256 amount);

  //mapping between promotion and user staked
  mapping(address => Staker) private _stakes;

   function stake(
    address token,
    uint256 amount  
    ) public {
    require(amount > 0, "Invalid amount");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.add(amount);

    IERC20(token).transferFrom(msg.sender, address(this), amount);
    emit StakedTokens(msg.sender, amount);
  }

  function withdrawStaked(uint256 amount, address token) public {
    require(amount > 0, "Invalid amount!");
    require(_stakes[msg.sender].amount >= amount, "Not enough staked!");
    require(_stakes[msg.sender].amount > 0, "Nothing staked!");

    require(IERC20(token).balanceOf(address(this)) >= amount, "Not enough balance!");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.sub(amount);

    IERC20(token).approve(address(this), amount);
    IERC20(token).transferFrom(address(this), msg.sender, amount);
    emit WithdrawnTokens(msg.sender, amount);
  }

  function getAmountStaked(address staker)
    public
    view
    returns (uint256 amount) {
    amount = _stakes[staker].amount;
  }

  function depositAave(
    address asset,
    uint256 amount,
    uint16 referralCode
  ) external onlyOwner {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");
    require(
      IERC20(asset).balanceOf(address(this)) >= amount,
      "Not enough balance!"
    );

    IERC20(asset).approve(aaveLendingPool, amount);
    IAaveLendingPool(aaveLendingPool).deposit(
      asset,
      amount,
      address(this),
      referralCode
    );
  }

  function withdrawAave(address asset, uint256 amount) external onlyOwner {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");

    IAaveLendingPool(aaveLendingPool).withdraw(asset, amount, address(this));
  }
}
