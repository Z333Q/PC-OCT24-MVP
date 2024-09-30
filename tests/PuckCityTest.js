
const { expect } = require("chai");

describe("PuckCity Game Management", function () {
    let gameManagement;
    let admin, nonAdmin;

    before(async () => {
        const GameManagement = await ethers.getContractFactory("GameManagement");
        gameManagement = await GameManagement.deploy();
        await gameManagement.deployed();

        [admin, nonAdmin] = await ethers.getSigners();
        await gameManagement.grantRole(await gameManagement.GAME_ADMIN_ROLE(), admin.address);
    });

    it("Should allow admin to add a new team", async function () {
        await gameManagement.addTeam(1, "Team A", { from: admin.address });
        const teamDetails = await gameManagement.getTeamDetails(1);
        expect(teamDetails.name).to.equal("Team A");
    });

    it("Should prevent non-admin from adding a team", async function () {
        await expect(
            gameManagement.addTeam(2, "Team B", { from: nonAdmin.address })
        ).to.be.revertedWith("Access denied: Only admins can add a team.");
    });

    it("Should log error when admin check fails", async function () {
        // Simulate admin check failure (e.g., network issue)
        const invalidAccount = "0x0000000000000000000000000000000000000000";
        await expect(gameManagement.addTeam(3, "Team C", { from: invalidAccount }))
            .to.be.revertedWith("Unable to verify admin role.");
    });
});
