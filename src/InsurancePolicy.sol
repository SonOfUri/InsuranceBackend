// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IpremiumCalculator {
    function calculateInsurancePremium(
        uint256 driverAge,
        uint256 accidents,
        uint256 violations,
        string memory vehicleCategory,
        uint256 vehicleAge,
        uint256 mileage,
        string[] memory safetyFeatures,
        string memory coverageType,
        uint256 vehicleValue
    ) external view returns (uint256);
}

contract InsurancePolicy {
    IpremiumCalculator public Calculator;
    enum ClaimStatus {
        Processing,
        Accepted,
        Rejected
    }

    constructor(address _calculator) {
        Calculator = IpremiumCalculator(_calculator);
    }

    struct Policy {
        address holder;
        uint policyId;
        uint premium;
        string vehicleCategory;
        uint vehicleValue;
        string coverageDetails;
        bool isActive;
        uint creationDate;
        uint lastPaymentDate;
        uint terminationDate;
        string terminationReason;
        ClaimStatus status;
    }
    struct Claim {
        uint256 policyId;
        address policyholder;
        string claimDetails;
        string[] image;
        ClaimStatus status;
    }
    mapping(address => mapping(uint => Claim)) claims;

    uint256 ClaimId;

    Claim[] public Allclaims;
    mapping(address => uint) premiumsReceived;
    mapping(address => Policy) policies;
    mapping(address => uint) userpremium;
    mapping(address => mapping(uint => Policy)) policiess;
    mapping(address => uint) policiesCount;

    event PolicyInitiated(address indexed policyHolder, uint time);
    event PolicyRenewed(address indexed policyHolder, uint time);
    event PolicyTerminated(
        address indexed policyHolder,
        string reason,
        uint time
    );

    function generatePremium(
        address _policyHolder,
        uint256 driverAge,
        uint256 accidents,
        uint256 violations,
        string memory vehicleCategory,
        uint256 vehicleAge,
        uint256 mileage,
        string[] memory safetyFeatures,
        string memory coverageType,
        uint256 vehicleValue
    ) public returns (uint premium_) {
        uint premium = Calculator.calculateInsurancePremium(
            driverAge,
            accidents,
            violations,
            vehicleCategory,
            vehicleAge,
            mileage,
            safetyFeatures,
            coverageType,
            vehicleValue
        );
        uint id = policiesCount[_policyHolder] + 1;
        Policy storage newPolicy = policiess[_policyHolder][id];
        newPolicy.holder = _policyHolder;
        newPolicy.policyId = id;
        newPolicy.premium = premium;
        newPolicy.vehicleCategory = vehicleCategory;
        newPolicy.vehicleValue = vehicleValue;
        newPolicy.coverageDetails = coverageType;

        policiesCount[_policyHolder]++;
        return newPolicy.premium;
    }

    function initiatePolicy(address policyHolder, uint256 id) public payable {
        Policy storage newPolicy = policiess[policyHolder][id];
        require(newPolicy.policyId > 0, "Go and generate Preium");
        require(!newPolicy.isActive, "Policy already Active");

        require(
            newPolicy.premium == msg.value,
            "Premium not paid or incorrect amount"
        );
        newPolicy.isActive = true;
        newPolicy.creationDate = block.timestamp;
        newPolicy.lastPaymentDate = block.timestamp;
        newPolicy.terminationDate = block.timestamp + 60;
        emit PolicyInitiated(policyHolder, block.timestamp);
    }

    function renewPolicy(address policyHolder, uint id) public payable {
        Policy storage policy = policiess[policyHolder][id];
        require(
            block.timestamp >= policy.creationDate + 60,
            "Policy is not yet due for renewal"
        );
        require(
            msg.value == policy.premium,
            "Incorrect premium paid for renewal"
        );

        policy.lastPaymentDate = block.timestamp;
        policy.isActive = true;
        emit PolicyRenewed(policyHolder, block.timestamp);
    }

    function terminatePolicy(
        address policyHolder,
        string memory reason
    ) public {
        Policy storage policy = policies[policyHolder];
        require(policy.isActive, "Policy is already inactive");

        policy.isActive = false;
        policy.terminationDate = block.timestamp;
        policy.terminationReason = reason;
        emit PolicyTerminated(policyHolder, reason, block.timestamp);
    }

    function checkPolicy(
        address policyHolder,
        uint id
    ) public returns (Policy memory policy_) {
        Policy storage policy = policiess[policyHolder][id];
        require(policy.isActive, "Policy not yet Initiated");
        if (block.timestamp > policy.terminationDate) {
            policy.isActive = false;
            policy.terminationReason = "Expired";
        }

        return policy;
    }

    function claimInsurance(
        uint256 _policyId,
        address _policyholder,
        string memory _claimDetails,
        string[] memory _image
    ) public {
        Claim storage newClaim = claims[_policyholder][_policyId];
        Policy storage policy = policiess[_policyholder][_policyId];

        ClaimId++;

        newClaim.policyId = _policyId;
        newClaim.policyholder = _policyholder;
        newClaim.claimDetails = _claimDetails;
        newClaim.image = _image;
        newClaim.status = ClaimStatus.Processing;
        policy.status = ClaimStatus.Processing;

        Allclaims.push(newClaim);
    }

    function getAllClaim() public view returns (Claim[] memory) {
        return Allclaims;
    }

    //Testing
    function AAgeneratePremium(string[] memory safetyFeatures) public {
        generatePremium(
            msg.sender,
            55,
            1,
            1,
            "v4",
            2,
            1200,
            safetyFeatures,
            "ct1",
            7000
        );
    }
}
