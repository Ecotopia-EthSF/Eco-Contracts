// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

// Import this file to use console.log
import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAlluoProxy.sol";

contract EcoAlluo is Ownable {
  using SafeMath for uint256;

  address _IbAlluoUSD = 0x71402a46d78a10c8eE7E7CdEf2AffeC8d1E312A1;

  uint256 MAX_INT = 2**256 - 1;

  struct Staker {
    uint256 amount;
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

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.add(amount);

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

    IAlluoProxy(_IbAlluoUSD).withdraw(asset, amount);

    require(IERC20(asset).balanceOf(address(this)) >= amount, "Not enough balance!");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.sub(amount);

    IERC20(asset).approve(address(this), amount);
    IERC20(asset).transferFrom(address(this), msg.sender, amount);

    emit WithdrawnTokens(msg.sender, amount);
  }
}
