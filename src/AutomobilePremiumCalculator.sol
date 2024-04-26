// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract calculates insurance premiums for automobiles based on various risk factors.

contract AutomobilePremiumCalculator {
    // Defines a struct to organize different categories for display purposes.
    struct Categories {
        string sf; // Label for safety features
        string sf1; // Advanced safety features
        string sf2; // Anti-theft system
        string sf3; // Parking sensors
        string sf4; // Blind spot monitoring
        string ct; // Label for coverage types
        string ct1; // Comprehensive coverage
        string ct2; // Collision coverage
        string ct3; // Liability coverage
        string ct4; // Personal Injury Protection
        string v; // Label for vehicle categories
        string v1; // Economy vehicles
        string v2; // Mid-range vehicles
        string v3; // Luxury vehicles
        string v4; // Sports vehicles
        string v5; // SUVs
        string v6; // Commercial vehicles
    }

    address public owner; // Stores the address of the contract owner.

    // Events for logging updates
    event SafetyFeatureAdjustmentUpdated(string feature, int256 newAdjustment);
    event CoverageTypeMultiplierUpdated(string category, uint256 newMultiplier);
    event VehicleCategoryUpdated(string category, uint256 newFactor);

    // Mappings to store adjustments and multipliers for various categories.
    mapping(string => int256) public safetyFeatureAdjustments;
    mapping(string => uint256) public coverageTypeMultipliers;
    mapping(string => uint256) public vehicleCategories;
    mapping(string => string) public code; // Stores descriptions and values for each category and feature.

    // Constructor sets the contract's owner and initializes the categories and codes.
    constructor() {
        owner = msg.sender;
        setCategories();
        viewCodes();
    }

    // Modifier to restrict function access to only the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Private function to initialize the values of the mappings.
    function setCategories() private onlyOwner {
        // Initializes safety feature adjustments.
        safetyFeatureAdjustments["sf1"] = -10;
        safetyFeatureAdjustments["sf2"] = -5;
        safetyFeatureAdjustments["sf3"] = -2;
        safetyFeatureAdjustments["sf4"] = -3;

        // Initializes coverage type multipliers.
        coverageTypeMultipliers["ct1"] = 120;
        coverageTypeMultipliers["ct2"] = 110;
        coverageTypeMultipliers["ct3"] = 100;
        coverageTypeMultipliers["ct4"] = 110;

        // Initializes vehicle category factors.
        vehicleCategories["v1"] = 100;
        vehicleCategories["v2"] = 120;
        vehicleCategories["v3"] = 150;
        vehicleCategories["v4"] = 200;
        vehicleCategories["v5"] = 130;
        vehicleCategories["v6"] = 140;
    }

    // Public view function to return all categories in a struct.
    function viewCategories() public pure returns (Categories memory categories) {
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

    // Private function to initialize the code descriptions for each category and feature.
    function viewCodes() private {
        // Initializes code descriptions for each category and feature.
        code["ct1"] = "Comprehensive, price = 120";
        code["ct2"] = "Collision, price = 110";
        code["ct3"] = "Liability, price = 100";
        code["ct4"] = "Personal Injury Protection, price = 110";
        code["v1"] = "Economy, price = 100";
        code["v2"] = "Mid-Range, price = 120";
        code["v3"] = "Luxury, price = 150";
        code["v4"] = "Sports, price = 200";
        code["v5"] = "SUV, price = 130";
        code["v6"] = "Commercial, price = 140";
        code["sf1"] = "advanced safety package, points = -10";
        code["sf2"] = "anti-theft system, points = -5";
        code["sf3"] = "parking sensors, points = -2";
        code["sf4"] = "blind spot monitoring, points = -3";
    }

    // Public function to update safety feature adjustments with event logging.
    function setSafetyFeatureAdjustments(
        string memory feature,
        int256 adjustment
    ) public onlyOwner {
        safetyFeatureAdjustments[feature] = adjustment;
        emit SafetyFeatureAdjustmentUpdated(feature, adjustment);
    }

    // Public function to update coverage type multipliers with event logging.
    function setCoverageTypeMultipliers(
        string memory category,
        uint256 multiplier
    ) public onlyOwner {
        coverageTypeMultipliers[category] = multiplier;
        emit CoverageTypeMultiplierUpdated(category, multiplier);
    }

    // Public function to update vehicle category factors with event logging.
    function setVehicleCategories(
        string memory category,
        uint256 factor
    ) public onlyOwner {
        vehicleCategories[category] = factor;
        emit VehicleCategoryUpdated(category, factor);
    }

    // Calculation function for safety feature discount based on a list of features.
    function calculateSafetyFeatureDiscount(
        string[] memory safetyFeatures
    ) public view returns (int256) {
        int256 totalDiscount = 0;
        for (uint i = 0; i < safetyFeatures.length; i++) {
            totalDiscount += safetyFeatureAdjustments[safetyFeatures[i]];
        }
        return totalDiscount;
    }

    // Calculation function to determine vehicle risk adjustment based on category, age, mileage, and safety features.
    function vehicleRiskAdjustment(
        string memory category,
        uint256 age,
        uint256 mileage,
        string[] memory safetyFeatures
    ) public view returns (int256) {
        int256 risk = int256(vehicleCategories[category]); // Start with base risk for the category
        risk += age > 10 ? int256(10) : int256(-5); // Increase or decrease risk based on age
        risk += calculateSafetyFeatureDiscount(safetyFeatures); // Apply safety feature discounts
        risk += mileage > 20000 ? int256(5) : int256(0); // Increase risk if mileage is high
        return risk;
    }

    // Calculation function to determine driver risk based on age, accidents, violations, and credit score.
    function driverRiskAdjustment(
        uint256 driverAge,
        uint256 accidents,
        uint256 violations
    ) public pure returns (int256) {
        int256 risk = 0;
        risk += driverAge < 25 || driverAge > 65 ? int256(20) : int256(-10); // Adjust risk based on age
        risk += int256(accidents) * 15; // Increase risk for each accident
        risk += int256(violations) * 10; // Increase risk for each violation
        return risk;
    }

    // Main calculation function to compute the insurance premium based on various factors.
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
    ) public view returns (uint256) {
        uint256 baseRate = 100; // Start with a base rate for calculations
        int256 driverRisk = driverRiskAdjustment(
            driverAge,
            accidents,
            violations
        );
        int256 vehicleRisk = vehicleRiskAdjustment(
            vehicleCategory,
            vehicleAge,
            mileage,
            safetyFeatures
        );
        uint256 coverageMultiplier = coverageTypeMultipliers[coverageType];

        // Calculate premium based on risks and multipliers
        int256 premium = (int256(baseRate) * (100 + driverRisk + vehicleRisk)) / 100;
        premium = (premium * int256(vehicleValue)) / 1000;
        premium = (premium * int256(coverageMultiplier)) / 100;

        return uint256(premium > 0 ? premium : int256(0)); // Ensure the premium is non-negative
    }
}
