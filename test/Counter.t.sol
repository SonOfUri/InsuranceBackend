// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AutomobileInsurancePolicy} from "../src/AutomobieInsurancePolicy.sol";
import {AutomobilePremiumCalculator} from "../src/AutomobilePremiumCalculator.sol";


contract CounterTest is Test {
    AutomobileInsurancePolicy public automobileInsurancePolicy;
    AutomobilePremiumCalculator public automobilePremiumCalculator;

      address A = address(0xa);
     address B = address(0xb);
     address C = address(0xc);
    

    function setUp() public {
        automobilePremiumCalculator = new AutomobilePremiumCalculator();
        automobileInsurancePolicy = new AutomobileInsurancePolicy(address(automobilePremiumCalculator));

          A = mkaddr("address a");
        B = mkaddr("address b");
        C = mkaddr("address c");

    }

     function testgeneratePremium() public {

         switchSigner(A);
        string[]    memory  safetyFeatures =   new string[](1);
        safetyFeatures[0]=("");
        
        automobileInsurancePolicy.generatePremium(A,20,1,0,"v2",3,1,safetyFeatures,"",2000);
uint premmium=automobilePremiumCalculator.calculateInsurancePremium( 20,1,0,"v2",3,1,safetyFeatures,"",2000);

        automobileInsurancePolicy.Policy memory newPolicy = policiess[A][1];

        
      
    }

    // function testFileClaim() public {

    //      switchSigner(A);
    //     string[]    memory  _images =   new string[](1);
    //     _images[0]=("hello");
        
    //     automobileInsurancePolicy.fileClaim(1, 100, "accident on way", _images);

    //     // Structs.Claim memory  newClaim    =  claimContract.getClaim(0);
        
    //     // assertEq(newClaim.policyId,1);
    //     // assertEq(newClaim.policyholder,A);
    //     // assertEq(newClaim.claimDetails,"hello");
    //     // assertEq(newClaim.image,_images);

    //     // assertEq(claimContract.ClaimId(),1);
      
    // }



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