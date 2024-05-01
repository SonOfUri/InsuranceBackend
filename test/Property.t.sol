// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PropertyInsurancePolicy} from "../src/PropertyInsurancePolicy.sol";
import {PropertyPremiumCalculator} from "../src/PropertyPremiumCalculator.sol";

contract PropertyTest is Test {
    PropertyInsurancePolicy public propertyInsurancePolicy;
    PropertyPremiumCalculator public propertyPremiumCalculator;

    uint256 private lastPaymentDate;

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);

    function setUp() public {
        propertyPremiumCalculator = new PropertyPremiumCalculator();
        propertyInsurancePolicy = new PropertyInsurancePolicy(
            address(propertyPremiumCalculator)
        );

        A = mkaddr("address a");
        B = mkaddr("address b");
        C = mkaddr("address c");

        vm.deal(A, 5 ether);
        vm.deal(B, 5 ether);

        lastPaymentDate = block.timestamp;
    }

        function testgeneratePremium() public {
            switchSigner(A);
            string[] memory protections = new string[](1);
            protections[0] = ("p1");

            propertyInsurancePolicy.generatePremium(A,"loc1","t1",2,protections,400);
            uint premium = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protections,400);
            console.log(premium);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            console.log();
            assertEq(newPolicy.premium, premium);
            assertEq(newPolicy.location, "loc1");
            assertEq(newPolicy.propertyValue, 400);
            assertEq(newPolicy.age, 2);
            assertEq(newPolicy.protections, protections);
        }

        function testinitatePolicy() public {
      switchSigner(A);
            string[] memory protections = new string[](1);
            protections[0] = ("p1");

            propertyInsurancePolicy.generatePremium(A,"loc1","t1",2,protections,400);
            uint premium = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protections,400);
            console.log(premium);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            console.log();
            assertEq(newPolicy.premium, premium);
            assertEq(newPolicy.location, "loc1");
            assertEq(newPolicy.propertyValue, 400);
            assertEq(newPolicy.age, 2);
            assertEq(newPolicy.protections, protections);

            propertyInsurancePolicy.initiatePolicy{value: premium}(A, 1);
        }

        function testFileClaim() public {
            switchSigner(A);

           string[] memory protections = new string[](1);
            protections[0] = ("p1");

            string[] memory _images = new string[](1);
            _images[0] = ("hello");
      propertyInsurancePolicy.generatePremium(A,"loc1","t1",2,protections,400);
            uint premium = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protections,400);
            console.log(premium);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            console.log();
            assertEq(newPolicy.premium, premium);
            assertEq(newPolicy.location, "loc1");
            assertEq(newPolicy.propertyValue, 400);
            assertEq(newPolicy.age, 2);
            assertEq(newPolicy.protections, protections);

            propertyInsurancePolicy.initiatePolicy{value: premium}(A, 1);
            assertEq(newPolicy.premium, premium);

            assertEq(newPolicy.policyId, 1);
            assertEq(newPolicy.holder, A);

            propertyInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

            PropertyInsurancePolicy.Claim
                memory newClaim = propertyInsurancePolicy.getClaim(0);

            assertEq(newClaim.policyId, 1);
            assertEq(newClaim.claimAmount, 0);
            assertEq(newClaim.policyholder, A);
            assertEq(newClaim.claimDetails, "accident on way");
            assertEq(newClaim.image, _images);

            assertEq(propertyInsurancePolicy.ClaimId(), 1);
        }

        function testTerminatePolicy() public {
            switchSigner(A);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            vm.expectRevert("Policy is already inactive");

            propertyInsurancePolicy.terminatePolicy(A, "not interested");

            assertEq(newPolicy.isActive, false);
        }

        function testAddVoter() public {
            A = address(0xa);

            propertyInsurancePolicy.addVoter(B);
        }

        function testVoteClaim() public {
        switchSigner(A);

           string[] memory protections = new string[](1);
            protections[0] = ("p1");

            string[] memory _images = new string[](1);
            _images[0] = ("hello");
      propertyInsurancePolicy.generatePremium(A,"loc1","t1",2,protections,400);
            uint premium = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protections,400);
            console.log(premium);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            console.log();
            assertEq(newPolicy.premium, premium);
            assertEq(newPolicy.location, "loc1");
            assertEq(newPolicy.propertyValue, 400);
            assertEq(newPolicy.age, 2);
            assertEq(newPolicy.protections, protections);

            propertyInsurancePolicy.initiatePolicy{value: premium}(A, 1);
            assertEq(newPolicy.premium, premium);

            assertEq(newPolicy.policyId, 1);
            assertEq(newPolicy.holder, A);

            propertyInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

            PropertyInsurancePolicy.Claim
                memory newClaim = propertyInsurancePolicy.getClaim(0);

            assertEq(newClaim.policyId, 1);
            assertEq(newClaim.claimAmount, 0);
            assertEq(newClaim.policyholder, A);
            assertEq(newClaim.claimDetails, "accident on way");
            assertEq(newClaim.image, _images);

            assertEq(propertyInsurancePolicy.ClaimId(), 1);

            //   vm.expectRevert("Only policyholders can vote on a claim");
            propertyInsurancePolicy.voteOnClaim(
                0,
                PropertyInsurancePolicy.VoteOption.Approve
            );

            PropertyInsurancePolicy.Vote
                memory newVote = propertyInsurancePolicy.getVoteOnClaim(0, A);

            assertTrue(newVote.voted);
        }

    function testRenewPolicy() public {
        switchSigner(A);
        string[] memory protections = new string[](1);
        protections[0] = ("p1");

        propertyInsurancePolicy.generatePremium(
            A,
            "loc1",
            "t1",
            2,
            protections,
            400
        );
        uint premium = propertyPremiumCalculator.calculateInsurancePremium(
            "loc1",
            "t1",
            2,
            protections,
            400
        );
        console.log(premium);

        PropertyInsurancePolicy.Policy
            memory newPolicy = propertyInsurancePolicy.getGeneratePremium(A, 1);
        console.log();
        assertEq(newPolicy.premium, premium);
        assertEq(newPolicy.location, "loc1");
        assertEq(newPolicy.propertyValue, 400);
        assertEq(newPolicy.age, 2);
        assertEq(newPolicy.protections, protections);

        vm.warp(lastPaymentDate);

        propertyInsurancePolicy.initiatePolicy{value: premium}(A, 1);

        // vm.expectRevert("Policy is not yet due for renewal");
        vm.warp(lastPaymentDate + 2 days);

        vm.expectRevert("Policy already Active");

        propertyInsurancePolicy.initiatePolicy(A, 1);

        // vm.expectRevert("Incorrect premium paid for renewal");
        propertyInsurancePolicy.renewPolicy{value: premium}(A, 1);
    }


        function testGetVoteCount() public {
        switchSigner(A);

           string[] memory protections = new string[](1);
            protections[0] = ("p1");

            string[] memory _images = new string[](1);
            _images[0] = ("hello");
      propertyInsurancePolicy.generatePremium(A,"loc1","t1",2,protections,400);
            uint premium = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protections,400);
            console.log(premium);

            PropertyInsurancePolicy.Policy
                memory newPolicy = propertyInsurancePolicy.getGeneratePremium(
                    A,
                    1
                );
            console.log();
            assertEq(newPolicy.premium, premium);
            assertEq(newPolicy.location, "loc1");
            assertEq(newPolicy.propertyValue, 400);
            assertEq(newPolicy.age, 2);
            assertEq(newPolicy.protections, protections);

            propertyInsurancePolicy.initiatePolicy{value: premium}(A, 1);
            assertEq(newPolicy.premium, premium);

            assertEq(newPolicy.policyId, 1);
            assertEq(newPolicy.holder, A);

            propertyInsurancePolicy.fileClaim(1, 0, "accident on way", _images);

            PropertyInsurancePolicy.Claim
                memory newClaim = propertyInsurancePolicy.getClaim(0);

            assertEq(newClaim.policyId, 1);
            assertEq(newClaim.claimAmount, 0);
            assertEq(newClaim.policyholder, A);
            assertEq(newClaim.claimDetails, "accident on way");
            assertEq(newClaim.image, _images);

            assertEq(propertyInsurancePolicy.ClaimId(), 1);

            //   vm.expectRevert("Only policyholders can vote on a claim");
            propertyInsurancePolicy.voteOnClaim(
                0,
                PropertyInsurancePolicy.VoteOption.Approve
            );

            switchSigner(B);

             string[] memory protectionss = new string[](1);
            protections[0] = ("p1");

      propertyInsurancePolicy.generatePremium(B,"loc1","t1",2,protectionss,400);
            uint premiums = propertyPremiumCalculator.calculateInsurancePremium("loc1","t1",2,protectionss,400);
            console.log(premiums);

            propertyInsurancePolicy.initiatePolicy{value: premiums}(B, 1);

              propertyInsurancePolicy.voteOnClaim(
                0,
                PropertyInsurancePolicy.VoteOption.Reject
            );
         (uint approveCount, uint rejectCount, uint totalVotes) = propertyInsurancePolicy.getVoteCounts(0);


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
