// SPDX-License-Identifier: None
pragma solidity ^0.8.6;

interface IToucanOffsetHelper {
    function autoOffsetUsingToken(
        address _depositedToken, 
        address _poolToken, 
        uint256 _amountToOffset
        ) external;
}
