
import Web3 from 'web3';
import * as Sentry from '@sentry/react';
import ipfsClient from 'ipfs-http-client';  // IPFS integration
import PuckCityContract from '../../contracts/PuckCity.json';
import GameManagementContract from '../../contracts/GameManagement.json';

const web3Provider = Web3.givenProvider || 'http://localhost:8545';
export const ipfs = ipfsClient({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

export function initializeWeb3() {
    return new Web3(web3Provider);
}

const web3 = initializeWeb3();
const gameInstance = new web3.eth.Contract(GameManagementContract.abi, GameManagementContract.networks[5777].address);

export async function addTeamDataToIPFS(teamData) {
    try {
        const added = await ipfs.add(JSON.stringify(teamData));
        return added.path;  // Return IPFS hash
    } catch (error) {
        Sentry.captureException(error);
        console.error("Error storing data on IPFS:", error);
        throw new Error("Unable to store team data.");
    }
}

export async function addTeamWithIPFS(teamId, teamName, account, teamData) {
    try {
        const isAdmin = await isAdmin(account);
        if (!isAdmin) {
            throw new Error("Access denied: Only admins can add a team.");
        }

        const ipfsHash = await addTeamDataToIPFS(teamData);
        await gameInstance.methods.addTeamWithIPFS(teamId, teamName, ipfsHash).send({ from: account });
    } catch (error) {
        Sentry.captureException(error);
        console.error("Error adding team with IPFS:", error);
        throw new Error("Unable to add team with IPFS data.");
    }
}
