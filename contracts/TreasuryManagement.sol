// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./OracleManagement.sol";
import "./TokenManagement.sol";

/**
 * @title TreasuryManagement
 * @dev Manages treasury transfers between cities based on game results.
 */
contract TreasuryManagement is AccessControl, ReentrancyGuard {
    OracleManagement public oracleManagement;
    TokenManagement public tokenManagement;

    bytes32 public constant TREASURY_MANAGER_ROLE = keccak256("TREASURY_MANAGER_ROLE");

    struct GameResult {
        address homeTeam;
        address awayTeam;
        uint256 homeScore;
        uint256 awayScore;
        address winner;
        address loser;
    }

    // Mapping of game results by date (timestamp)
    mapping(uint256 => GameResult[]) public dailyGameResults;

    // Mapping of cached oracle data by date (timestamp)
    mapping(uint256 => bytes) public dailyOracleData;

    event BatchTransferProcessed(uint256 date, uint256 totalAmount);
    event OracleDataCached(uint256 date, bytes data);
    event TreasuryTransferred(address fromCity, address toCity, uint256 amount);

    constructor(address _oracleManagement, address _tokenManagement) {
        oracleManagement = OracleManagement(_oracleManagement);
        tokenManagement = TokenManagement(_tokenManagement);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(TREASURY_MANAGER_ROLE, msg.sender);
    }

    /**
     * @notice Store game results for a given day.
     * This will determine the winner and loser based on the score.
     * @param date The date of the game (in UNIX timestamp).
     * @param homeTeam Address of the home team.
     * @param awayTeam Address of the away team.
     * @param homeScore Final score of the home team.
     * @param awayScore Final score of the away team.
     */
    function storeGameResult(
        uint256 date,
        address homeTeam,
        address awayTeam,
        uint256 homeScore,
        uint256 awayScore
    ) external onlyRole(TREASURY_MANAGER_ROLE) {
        address winner;
        address loser;

        if (homeScore > awayScore) {
            winner = homeTeam;
            loser = awayTeam;
        } else {
            winner = awayTeam;
            loser = homeTeam;
        }

        dailyGameResults[date].push(GameResult(homeTeam, awayTeam, homeScore, awayScore, winner, loser));
    }

    /**
     * @notice Cache oracle data for the given day to avoid redundant calls.
     * @param date The date for which the oracle data is being fetched (in UNIX timestamp).
     */
    function cacheOracleData(uint256 date) external onlyRole(TREASURY_MANAGER_ROLE) {
        bytes memory oracleData = oracleManagement.fetchOracleData();
        dailyOracleData[date] = oracleData;
        emit OracleDataCached(date, oracleData);
    }

    /**
     * @notice Batch process treasury transfers for all games of the given date.
     * The transfers are processed at 2AM of the next day.
     * @param date The date of the games (in UNIX timestamp).
     */
    function processBatchTreasuryTransfer(uint256 date) external nonReentrant onlyRole(TREASURY_MANAGER_ROLE) {
        require(dailyGameResults[date].length > 0, "No game results for this date");

        for (uint256 i = 0; i < dailyGameResults[date].length; i++) {
            GameResult memory result = dailyGameResults[date][i];
            uint256 loserTreasury = tokenManagement.balanceOf(result.loser);
            uint256 transferAmount = (loserTreasury * 1) / 100;  // 1% of losing city's treasury

            tokenManagement.transfer(result.loser, result.winner, transferAmount);
            emit TreasuryTransferred(result.loser, result.winner, transferAmount);
        }

        emit BatchTransferProcessed(date, dailyGameResults[date].length);
    }

    /**
     * @notice Fetch oracle data and cache it before processing transfers.
     * This function simulates a 2AM batch processing mechanism.
     * It should be called at the end of every day (around 2AM the next day).
     */
    function processDailyTransfers(uint256 date) external nonReentrant onlyRole(TREASURY_MANAGER_ROLE) {
        cacheOracleData(date);
        processBatchTreasuryTransfer(date);
    }
}
