// SPDX-License-Identifier: None
pragma solidity >=0.8.0;

interface ITellorAutopay {
    function tip(
        bytes32 _queryId,
        uint256 _amount,
        bytes memory _queryData
    ) external;
}
