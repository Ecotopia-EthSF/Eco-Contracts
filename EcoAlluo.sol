// SPDX-License-Identifier: None
pragma solidity ^0.8.6;

// Import this file to use console.log
import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAlluoProxy.sol";
import "./interfaces/IToucanOffsetHelper.sol";

contract EcoAlluo is Ownable {
  using SafeMath for uint256;

  address _IbAlluoUSD = 0x71402a46d78a10c8eE7E7CdEf2AffeC8d1E312A1;
  address _touconOffsetHelper = 0x30dC279166DCFB69F52C91d6A3380dCa75D0fCa7;
  address _touconNCT = 0x7beCBA11618Ca63Ead5605DE235f6dD3b25c530E;
//   address _depositUSD = 0xB579C5ba3Bc8EA2F5DD5622f1a5EaC6282516fB1;

  uint256 MAX_INT = 2**256 - 1;

  struct Staker {
    uint256 amount;
    uint256 initialGrowingRatio;
  }

  event StakedTokens(address staker, uint256 amount);
  event WithdrawnTokens(address staker, uint256 amount);

  //mapping between promotion and user staked
  mapping(address => Staker) private _stakes;

  function depositAlluo(
    address asset,
    uint256 amount
  ) external {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");
    require(_stakes[msg.sender].amount == 0, "Withdraw initial deposit first");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.add(amount);
    uint256 growingRatio = IAlluoProxy(_IbAlluoUSD).growingRatio();
    _stakes[msg.sender].initialGrowingRatio = growingRatio;

    IERC20(asset).transferFrom(msg.sender, address(this), amount);
    require(IERC20(asset).balanceOf(address(this)) >= amount, "Not enough balance!");

    IERC20(asset).approve(_IbAlluoUSD, MAX_INT);
    IAlluoProxy(_IbAlluoUSD).deposit(asset, amount);

    emit StakedTokens(msg.sender, amount);
  }

  function withdrawAlluo(address asset, uint256 amount) external {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");

    require(asset != address(0), "Asset has to be non zero address");
    require(_stakes[msg.sender].amount >= amount, "Not enough staked!");
    require(_stakes[msg.sender].amount > 0, "Nothing staked!");

    console.log(amount);

    uint256 currentGrowingRatio = IAlluoProxy(_IbAlluoUSD).growingRatio();

    console.log(currentGrowingRatio);
    console.log(_stakes[msg.sender].initialGrowingRatio);

    uint256 yeildAmt = (currentGrowingRatio - _stakes[msg.sender].initialGrowingRatio) * amount;

    console.log(yeildAmt);
    
    // Get amount + yeildAmt USD from Alluo
    IAlluoProxy(_IbAlluoUSD).withdraw(asset, amount + yeildAmt);

    console.log("Withdrawn");

    // Send yeild amount to buy carbon offset and the rest to the owner
    // IToucanOffsetHelper(_touconOffsetHelper).autoOffsetUsingToken(asset, _touconNCT, yeildAmt);
    IERC20(asset).transferFrom(address(this), 0x72230E8FeEA1D2c6435C67AeB9aFfffB127e8624, amount);
    IERC20(asset).transferFrom(address(this), msg.sender, amount);
    _stakes[msg.sender].amount = _stakes[msg.sender].amount.sub(amount);

    console.log("Transferred");

    emit WithdrawnTokens(msg.sender, amount);
  }

  function getAmountStaked(address staker)
    public
    view
    returns (uint256 amount) {
    amount = _stakes[staker].amount;
  }
}
