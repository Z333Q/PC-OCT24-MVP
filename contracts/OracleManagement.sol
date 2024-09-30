// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./AccessControl.sol";

/**
 * @title OracleManagement
 * @dev Manages the Chainlink oracle operations.
 */
contract OracleManagement is ChainlinkClient, AccessControlManager {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    event OracleDataRequested(bytes32 requestId);
    event OracleDataReceived(bytes32 requestId, bytes data);

    /**
     * @dev Requests data from the Chainlink oracle.
     * Emits OracleDataRequested when the request is made.
     */
    function fetchOracleData() external onlyRole(ORACLE_ADMIN_ROLE) {
        // Example: Chainlink request logic (pseudo-code)
        bytes32 requestId = requestOracleData();  // Assuming requestOracleData() is a Chainlink method
        emit OracleDataRequested(requestId);
    }

    /**
     * @dev Callback function for receiving oracle data.
     * This is a mocked function representing Chainlink’s fulfillment callback.
     */
    function fulfillOracleData(bytes32 _requestId, bytes memory _data) public {
        // Validate the request and data (ensure only Chainlink can call this)
        emit OracleDataReceived(_requestId, _data);
    }
}
