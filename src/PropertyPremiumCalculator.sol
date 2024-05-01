// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract calculates insurance premiums for property based on various risk factors like location, age, and protective measures.

contract PropertyPremiumCalculator {
    // Property categories and their respective descriptions for clarity in the user interface.
    struct Categories {
        string location; // General location category
        string loc1; // Urban
        string loc2; // Suburban
        string loc3; // Rural
        string Propertytype; // Type of property
        string t1; // Residential
        string t2; // Commercial
        string t3; // Industrial
        string age; // Age of the property
        string protection; // Protective measures
        string p1; // Fire alarm
        string p2; // Security system
        string p3; // Storm shutters
        string p4; // Reinforced construction
    }

    address public owner; // Stores the address of the contract owner.

// Events for logging updates
    event LocationRiskMultiplierUpdated(string location, uint256 newMultiplier);
    event TypeRiskMultiplierUpdated(string properyType, uint256 newMultiplier);
event ProtectionDiscountUpdated(string protection, int256 newDiscount);
event AgeAdjustmentUpdated(uint256 ageBracket, int256 newAdjustment);

// Mappings to store multipliers and adjustments
mapping(string => uint256) public locationRiskMultipliers;
mapping(string => uint256) public typeRiskMultipliers;
mapping(string => int256) public protectionDiscounts;
mapping(uint256 => int256) public ageAdjustments; // Using age brackets as keys

// Constructor to initialize the contract with default values
constructor() {
owner = msg.sender;
initializeDefaults();
}

// Modifier to restrict access to the owner only
modifier onlyOwner() {
require(msg.sender == owner, "Caller is not the owner");
_;
}

// Initializes default values for the mappings
function initializeDefaults() private onlyOwner {
locationRiskMultipliers["loc1"] = 130; // Urban areas have higher risk
locationRiskMultipliers["loc2"] = 100; // Suburban areas have moderate risk
locationRiskMultipliers["loc3"] = 80;  // Rural areas have lower risk

typeRiskMultipliers["t1"] = 100; // Residential properties
typeRiskMultipliers["t2"] = 120; // Commercial properties
typeRiskMultipliers["t3"] = 150; // Industrial properties

protectionDiscounts["p1"] = -10; // Fire alarm
protectionDiscounts["p2"] = -15; // Security system
protectionDiscounts["p3"] = -5;  // Storm shutters
protectionDiscounts["p4"] = -20; // Reinforced construction

ageAdjustments[10] = -5;  // Less than 10 years
ageAdjustments[20] = 0;   // 10-20 years
ageAdjustments[30] = 5;   // 20-30 years
ageAdjustments[40] = 10;  // Over 30 years
}

// Public function to update location risk multipliers
function updateLocationRiskMultiplier(string memory location, uint256 multiplier) public onlyOwner {
locationRiskMultipliers[location] = multiplier;
emit LocationRiskMultiplierUpdated(location, multiplier);
}

// Public function to update property type risk multipliers
function updateTypeRiskMultiplier(string memory properyType, uint256 multiplier) public onlyOwner {
typeRiskMultipliers[properyType] = multiplier;
emit TypeRiskMultiplierUpdated(properyType, multiplier);
}

// Public function to update protection discounts
function updateProtectionDiscount(string memory protection, int256 discount) public onlyOwner {
protectionDiscounts[protection] = discount;
emit ProtectionDiscountUpdated(protection, discount);
}

// Public function to update age adjustments
function updateAgeAdjustment(uint256 ageBracket, int256 adjustment) public onlyOwner {
ageAdjustments[ageBracket] = adjustment;
emit AgeAdjustmentUpdated(ageBracket, adjustment);
}

// Calculation function for protection discount based on a list of features
function calculateProtectionDiscount(string[] memory protections) public view returns (int256) {
int256 totalDiscount = 0;
for (uint i = 0; i < protections.length; i++) {
totalDiscount += protectionDiscounts[protections[i]];
}
return totalDiscount;
}

// Main calculation function to compute the insurance premium
function calculateInsurancePremium(
string memory location,
string memory properyType,
uint256 age,
string[] memory protections,
uint256 propertyValue
) public view returns (uint256) {
uint256 baseRate = 100; // Starting base rate for calculations
uint256 locationRisk = locationRiskMultipliers[location];
uint256 typeRisk = typeRiskMultipliers[properyType];
int256 protectionDiscount = calculateProtectionDiscount(protections);
int256 ageAdjustment = age > 30 ? ageAdjustments[40] : ageAdjustments[age / 10 * 10]; // Bracketed age adjustment

// Calculate premium
int256 premium = int256(baseRate) * (int256(locationRisk) + int256(typeRisk) + protectionDiscount + ageAdjustment);
premium = (premium * int256(propertyValue)) / 10000; // Adjust premium based on property value

return uint256(premium > 0 ? premium : int256(0)); // Ensure the premium is non-negative
}
}