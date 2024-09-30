// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GameManagement.sol";
import "./OracleManagement.sol";
import "./BridgeOperations.sol";
import "./TreasuryManagement.sol";
import "./PriceCalculation.sol";
import "./TokenManagement.sol";
import "./AccessControl.sol";

/**
 * @title PuckCity Main Contract
 * @dev Main orchestrator contract that connects GameManagement, OracleManagement, 
 * BridgeOperations, PriceCalculation, and TokenManagement.
 */
contract PuckCity is AccessControlManager, ReentrancyGuard {
    GameManagement public gameManagement;
    OracleManagement public oracleManagement;
    BridgeOperations public bridgeOperations;
    PriceCalculation public priceCalculation;
    TreasuryManagement public treasuryManagement;


    TokenManagement public tokenManagement;

    event GameCreated(uint256 gameId);
    event PriceSet(uint256 assetId, uint256 price);

    /**
     * @dev Initializes the main contract by linking it to all module contracts.
     * @param _gameManagement Address of the GameManagement contract.
     * @param _oracleManagement Address of the OracleManagement contract.
     * @param _bridgeOperations Address of the BridgeOperations contract.
     * @param _priceCalculation Address of the PriceCalculation contract.
     * @param _tokenManagement Address of the TokenManagement contract.
     */
    constructor(
        address _gameManagement,
        address _oracleManagement,
        address _bridgeOperations,
        address _priceCalculation,
        address _treasuryManagement,
        address _tokenManagement
    ) {
        gameManagement = GameManagement(_gameManagement);
        oracleManagement = OracleManagement(_oracleManagement);
        bridgeOperations = BridgeOperations(_bridgeOperations);
        priceCalculation = PriceCalculation(_priceCalculation);
        treasuryManagement = TreasuryManagement(_treasuryManagement);
        tokenManagement = TokenManagement(_tokenManagement);
    }

    /**
     * @dev Creates a new game and sets the price for an asset.
     * This function is protected by reentrancy guard and requires the GAME_ADMIN_ROLE.
     * @param gameId The ID of the game to be created.
     * @param price The price to set for the asset.
     */
    function createGameAndSetPrice(uint256 gameId, uint256 price) external nonReentrant onlyRole(GAME_ADMIN_ROLE) {
        gameManagement.createGame(gameId);
        priceCalculation.setPrice(gameId, price);
        emit GameCreated(gameId);
        emit PriceSet(gameId, price);
    }

    /**
     * @dev Fetches oracle data.
     * This function is protected and requires the ORACLE_ADMIN_ROLE.
     */
    function fetchOracleData() external nonReentrant onlyRole(ORACLE_ADMIN_ROLE) {
        oracleManagement.fetchOracleData();
    }
}
