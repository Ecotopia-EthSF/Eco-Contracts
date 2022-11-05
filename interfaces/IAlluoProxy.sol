// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

interface IAlluoProxy {
  function deposit(
    address _token,
    uint256 _amount
  ) external;

  function withdraw(
    address _targetToken,
    uint256 _amount
  ) external;
}
