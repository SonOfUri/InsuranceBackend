// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AutomobileInsurancePolicy} from "../src/AutomobieInsurancePolicy.sol";
import {AutomobilePremiumCalculator} from "../src/AutomobilePremiumCalculator.sol";

contract AutomobileTest is Test {
    AutomobileInsurancePolicy public automobileInsurancePolicy;
    AutomobilePremiumCalculator public automobilePremiumCalculator;

    uint256 private lastPaymentDate;

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);

    function setUp() public {
        automobilePremiumCalculator = new AutomobilePremiumCalculator();
        automobileInsurancePolicy = new AutomobileInsurancePolicy(
            address(automobilePremiumCalculator)
        );

        A = mkaddr("address a");
        B = mkaddr("address b");
        C = mkaddr("address c");

        vm.deal(A, 5 ether);
        vm.deal(B, 5 ether);
    }

    function testgeneratePremium() public {
        switchSigner(A);
        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("sf2");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();
        assertEq(newPolicy.premium, premium);
        assertEq(newPolicy.coverageDetails, "ct2");
        assertEq(newPolicy.vehicleCategory, "v2");
        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);
    }

    function testinitatePolicy() public {
        switchSigner(A);
        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("sf2");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();
        assertEq(newPolicy.premium, premium);
        assertEq(newPolicy.coverageDetails, "ct2");
        assertEq(newPolicy.vehicleCategory, "v2");
        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        automobileInsurancePolicy.initiatePolicy{value: premium}(A, 1);
    }

    function testFileClaim() public {
        switchSigner(A);

        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("");

        string[] memory _images = new string[](1);
        _images[0] = ("hello");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();

        assertEq(newPolicy.premium, premium);

        automobileInsurancePolicy.initiatePolicy(A, 1);

        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        automobileInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

        AutomobileInsurancePolicy.Claim
            memory newClaim = automobileInsurancePolicy.getClaim(0);

        assertEq(newClaim.policyId, 1);
        assertEq(newClaim.claimAmount, 0);
        assertEq(newClaim.policyholder, A);
        assertEq(newClaim.claimDetails, "accident on way");
        assertEq(newClaim.image, _images);

        assertEq(automobileInsurancePolicy.ClaimId(), 1);
    }

    function testTerminatePolicy() public {
        switchSigner(A);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        vm.expectRevert("Policy is already inactive");

        automobileInsurancePolicy.terminatePolicy(A, "not interested");

        assertEq(newPolicy.isActive, false);
    }

    function testCheckPolicy() public {
        switchSigner(A);

        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );

        automobileInsurancePolicy.checkPolicy(A, 1);
    }

    function testAddVoter() public {
        A = address(0xa);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );

        automobileInsurancePolicy.addVoter(B);
    }

    function testVoteClaim() public {
        switchSigner(A);

        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("");

        string[] memory _images = new string[](1);
        _images[0] = ("hello");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();

        assertEq(newPolicy.premium, premium);

        automobileInsurancePolicy.initiatePolicy(A, 1);

        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        automobileInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

        AutomobileInsurancePolicy.Claim
            memory newClaim = automobileInsurancePolicy.getClaim(0);

        assertEq(automobileInsurancePolicy.ClaimId(), 1);

        //   vm.expectRevert("Only policyholders can vote on a claim");
        automobileInsurancePolicy.voteOnClaim(
            0,
            AutomobileInsurancePolicy.VoteOption.Reject
        );
        AutomobileInsurancePolicy.Vote
            memory newVote = automobileInsurancePolicy.getVoteOnClaim(0, A);

        assertTrue(newVote.voted);
    }

    function testRenewPolicy() public {
        switchSigner(A);
        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("sf2");

        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();
        assertEq(newPolicy.premium, premium);
        assertEq(newPolicy.coverageDetails, "ct2");
        assertEq(newPolicy.vehicleCategory, "v2");
        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        vm.warp(lastPaymentDate);

        automobileInsurancePolicy.initiatePolicy{value: premium}(A, 1);

        // vm.expectRevert("Policy is not yet due for renewal");
        vm.warp(lastPaymentDate + 2 days);

        vm.expectRevert("Policy already Active");

        automobileInsurancePolicy.initiatePolicy(A, 1);

        // vm.expectRevert("Incorrect premium paid for renewal");
        automobileInsurancePolicy.renewPolicy{value: premium}(A, 1);
    }

    function testGetVoteCount() public {
        switchSigner(A);

        string[] memory safetyFeatures = new string[](1);
        safetyFeatures[0] = ("p1");

        string[] memory _images = new string[](1);
        _images[0] = ("hello");
        automobileInsurancePolicy.generatePremium(
            A,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );

        uint premium = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        console.log(premium);

        AutomobileInsurancePolicy.Policy
            memory newPolicy = automobileInsurancePolicy.getGeneratePremium(
                A,
                1
            );
        console.log();
        assertEq(newPolicy.premium, premium);
        assertEq(newPolicy.coverageDetails, "ct2");
        assertEq(newPolicy.vehicleCategory, "v2");
        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        automobileInsurancePolicy.initiatePolicy{value: premium}(A, 1);
        assertEq(newPolicy.premium, premium);

        assertEq(newPolicy.policyId, 1);
        assertEq(newPolicy.holder, A);

        automobileInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

        AutomobileInsurancePolicy.Claim
            memory newClaim = automobileInsurancePolicy.getClaim(0);

        assertEq(newClaim.policyId, 1);
        assertEq(newClaim.claimAmount, 0);
        assertEq(newClaim.policyholder, A);
        assertEq(newClaim.claimDetails, "accident on way");
        assertEq(newClaim.image, _images);

        assertEq(automobileInsurancePolicy.ClaimId(), 1);

        //   vm.expectRevert("Only policyholders can vote on a claim");
        automobileInsurancePolicy.voteOnClaim(
            0,
            AutomobileInsurancePolicy.VoteOption.Approve
        );

        switchSigner(B);

        string[] memory safetyFeaturess = new string[](1);
        safetyFeaturess[0] = ("p1");
        automobileInsurancePolicy.generatePremium(
            B,
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );

        uint premiums = automobilePremiumCalculator.calculateInsurancePremium(
            20,
            1,
            0,
            "v2",
            3,
            1,
            safetyFeatures,
            "ct2",
            2000
        );
        console.log(premiums);

        automobileInsurancePolicy.initiatePolicy{value: premiums}(B, 1);

        automobileInsurancePolicy.voteOnClaim(
            0,
            AutomobileInsurancePolicy.VoteOption.Reject
        );
        (
            uint approveCount,
            uint rejectCount,
            uint totalVotes
        ) = automobileInsurancePolicy.getVoteCounts(0);

        assertEq(approveCount, 1);
        assertEq(rejectCount, 1);
        assertEq(totalVotes, 2);
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }
}
