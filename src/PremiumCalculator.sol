// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomobilePremiumCalculator {
    struct Categories {
        string sf;
        string sf1;
        string sf2;
        string sf3;
        string sf4;
        string ct;
        string ct1;
        string ct2;
        string ct3;
        string ct4;
        string v;
        string v1;
        string v2;
        string v3;
        string v4;
        string v5;
        string v6;
    }

    address public owner;

    // Events for logging updates
    event SafetyFeatureAdjustmentUpdated(string feature, int256 newAdjustment);
    event CoverageTypeMultiplierUpdated(string category, uint256 newMultiplier);
    event VehicleCategoryUpdated(string category, uint256 newFactor);

    // Storage mappings
    mapping(string => int256) public safetyFeatureAdjustments;
    mapping(string => uint256) public coverageTypeMultipliers;
    mapping(string => uint256) public vehicleCategories;
    mapping(string => string) public code;

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
        setCategories(); // Set Categories
        viewCodes(); // Set Codes
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function setCategories() private onlyOwner {
        // Safety features
        //advanced safety package
        safetyFeatureAdjustments["sf1"] = -10;
        // anti-theft system
        safetyFeatureAdjustments["sf2"] = -5;
        // parking sensors
        safetyFeatureAdjustments["sf3"] = -2;
        //  blind spot monitoring
        safetyFeatureAdjustments["sf4"] = -3;

        // Coverage types
        //Comprehensive
        coverageTypeMultipliers["ct1"] = 120;
        //Collision
        coverageTypeMultipliers["ct2"] = 110;
        //Liability
        coverageTypeMultipliers["ct3"] = 100;
        //Personal Injury Protection
        coverageTypeMultipliers["ct4"] = 110;

        //  Vehicle categories
        //Economy
        vehicleCategories["v1"] = 100;
        //Mid-Range
        vehicleCategories["v2"] = 120;
        // Luxury
        vehicleCategories["v3"] = 150;
        //Sports
        vehicleCategories["v4"] = 200;
        //SUV
        vehicleCategories["v5"] = 130;
        //Commercial
        vehicleCategories["v6"] = 140;
    }

    function viewCategories()
        public
        pure
        returns (Categories memory categories)
    {
        Categories memory newCategory = Categories({
            sf: "sf: Safety features",
            sf1: "sf1: Advance Safety features",
            sf2: "sf2: Anti theft",
            sf3: "sf3: Parking Sensor",
            sf4: "sf4: Blind spot Monitor",
            ct: "ct: Coverage Types",
            ct1: "ct1: Comprehensive",
            ct2: "ct2: Collision",
            ct3: "ct3: Liability",
            ct4: "ct4: Personal Injury",
            v: "v: Vehicle Category",
            v1: "v1:Economy",
            v2: "v2:Mid-Range",
            v3: "v3: Luxury",
            v4: "v4:Sports",
            v5: "v5:SUV",
            v6: "v6:Commercial"
        });
        return (newCategory);
    }

    function viewCodes() private {
        code["ct1"] = "Comprehensive, price = 120";
        //Collision
        code["ct2"] = "Collision, price = 110";
        //Liability
        code["ct3"] = "Liability, price = 100";
        //Personal Injury Protection
        code["ct4"] = "Personal Injury Protection, price = 110";
        //  Vehicle categories
        //Economy
        code["v1"] = "Economy, price = 100";
        //Mid-Range
        code["v2"] = "Mid-Range, price = 120";
        // Luxury
        code["v3"] = "Luxury, price = 150";
        //Sports
        code["v4"] = "Sports, price = 200";
        //SUV
        code["v5"] = "SUV, price = 130";
        //Commercial
        code["v6"] = "Commercial, price = 140";
        //advanced safety package
        code["sf1"] = "advanced safety package, points = -10";
        // anti-theft system
        code["sf2"] = "anti-theft system, points = -5";
        // parking sensors
        code["sf3"] = "parking sensors, points = -2";
        //  blind spot monitoring
        code["sf4"] = "blind spot monitoring, points = -3";
    }

    // Update functions with event logging
    function setSafetyFeatureAdjustments(
        string memory feature,
        int256 adjustment
    ) public onlyOwner {
        safetyFeatureAdjustments[feature] = adjustment;
        emit SafetyFeatureAdjustmentUpdated(feature, adjustment);
    }

    function setCoverageTypeMultipliers(
        string memory category,
        uint256 multiplier
    ) public onlyOwner {
        coverageTypeMultipliers[category] = multiplier;
        emit CoverageTypeMultiplierUpdated(category, multiplier);
    }

    function setVehicleCategories(
        string memory category,
        uint256 factor
    ) public onlyOwner {
        vehicleCategories[category] = factor;
        emit VehicleCategoryUpdated(category, factor);
    }

    // Calculation functions
    function calculateSafetyFeatureDiscount(
        string[] memory safetyFeatures
    ) public view returns (int256) {
        int256 totalDiscount = 0;
        for (uint i = 0; i < safetyFeatures.length; i++) {
            totalDiscount += safetyFeatureAdjustments[safetyFeatures[i]];
        }
        return totalDiscount;
    }

    function vehicleRiskAdjustment(
        string memory category,
        uint256 age,
        uint256 mileage,
        string[] memory safetyFeatures
    ) public view returns (int256) {
        int256 risk = int256(vehicleCategories[category]); // Start with the category risk
        risk += age > 10 ? int256(10) : int256(-5);
        risk += calculateSafetyFeatureDiscount(safetyFeatures);
        risk += mileage > 20000 ? int256(5) : int256(0);
        return risk;
    }

    function driverRiskAdjustment(
        uint256 driverAge,
        uint256 accidents,
        uint256 violations,
        uint256 creditScore
    ) public pure returns (int256) {
        int256 risk = 0;
        risk += driverAge < 25 || driverAge > 65 ? int256(20) : int256(-10);
        risk += int256(accidents) * 15;
        risk += int256(violations) * 10;
        risk -= creditScore > 700 ? int256(10) : int256(0);
        return risk;
    }

    function calculateInsurancePremium(
        uint256 driverAge,
        uint256 accidents,
        uint256 violations,
        uint256 creditScore,
        string memory vehicleCategory,
        uint256 vehicleAge,
        uint256 mileage,
        string[] memory safetyFeatures,
        string memory coverageType,
        uint256 vehicleValue
    ) public view returns (uint256) {
        uint256 baseRate = 100; // Starting base rate for insurance
        int256 driverRisk = driverRiskAdjustment(
            driverAge,
            accidents,
            violations,
            creditScore
        );
        int256 vehicleRisk = vehicleRiskAdjustment(
            vehicleCategory,
            vehicleAge,
            mileage,
            safetyFeatures
        );
        uint256 coverageMultiplier = coverageTypeMultipliers[coverageType];

        int256 premium = (int256(baseRate) * (100 + driverRisk + vehicleRisk)) /
            100;
        premium = (premium * int256(vehicleValue)) / 1000;
        premium = (premium * int256(coverageMultiplier)) / 100;

        return uint256(premium > 0 ? premium : int256(0));
    }
}
