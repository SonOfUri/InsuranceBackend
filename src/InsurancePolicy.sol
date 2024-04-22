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
    }
    mapping(address => uint) premiumsReceived;
    mapping(address => Policy) policies;
    mapping(address => uint) userpremium;
    mapping(address => mapping(uint => Policy)) policies;
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
        Policy storage newPolicy = policies[_policyHolder][id];
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
        Policy storage newPolicy = policies[policyHolder][id];
        require(newPolicy.policyId > 0, "Go and generate Preium");
        require(
            newPolicy.premium == msg.value,
            "Premium not paid or incorrect amount"
        );
        newPolicy.isActive = true;
        newPolicy.creationDate = block.timestamp;
        newPolicy.lastPaymentDate = block.timestamp;
        newPolicy.terminationDate = block.timestamp + 365 days;
        emit PolicyInitiated(policyHolder, block.timestamp);
    }

    function renewPolicy(address policyHolder, uint id) public payable {
        Policy storage policy = policies[policyHolder][id];
        require(
            block.timestamp >= policy.creationDate + 365 days,
            "Policy is not yet due for renewal"
        );

        uint newPremium = generatePremium(
            policy.holder,
            policy.driverAge,
            policy.accidents,
            policy.vehicleCategory,
            policy.vehicleAge,
            policy.mileage,
            policy.safetyFeatures,
            policy.coverageType,
            policy.vehicleValue
        );

        require(
            msg.value == newPremium,
            "Incorrect premium paid for renewal"
        );

        policy.premium = newPremium;
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

        uint refundAmount = (policy.premium * 80) / 100;
        payable(policyHolder).transfer(refundAmount);

        policy.isActive = false;
        policy.terminationReason = reason;
        emit PolicyTerminated(policyHolder, reason, block.timestamp);
    }

    function checkPolicy(
        address policyHolder,
        uint id
    ) public returns (Policy memory policy_) {
        Policy storage policy = policies[policyHolder][id];
        if (policy.terminationDate > block.timestamp) {
            policy.isActive = false;
            policy.terminationReason = "Expired";
        }

        return policy;
    }
}
