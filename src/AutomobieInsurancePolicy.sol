// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAutomobilePremiumCalculator {
    // Function definition for calculating insurance premium based on various parameters like age, accidents, etc.
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

contract AutomobileInsurancePolicy {
    // Instance of the premium calculator interface
    IAutomobilePremiumCalculator public Calculator;

    // Enum representing the different statuses of a claim
    enum ClaimStatus {
        Processing,
        Accepted,
        Rejected
    }

    // Contract constructor initializing the calculator with the address provided
    constructor(address _calculator) {
        Calculator = IAutomobilePremiumCalculator(_calculator);
        owner = msg.sender;
    }

    // Owner of the contract
    address public owner;

    // Modifier to restrict function access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Struct defining the attributes of an insurance policy
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
        string imageurl;
    }

    // Mapping to track if an address holds a policy
    mapping(address => bool) policyholders;

    // Struct for an insurance claim
    struct Claim {
        uint256 policyId;
        address policyholder;
        uint256 claimAmount; // Amount being claimed
        string claimDetails;
        string[] image;
        ClaimStatus status;
    }

    // Nested mapping to manage claims made by policyholders
    mapping(address => mapping(uint => Claim)) claims;

    // Incremental ID to track claims
    uint256 public ClaimId;

    // Dynamic array to store all claims
    Claim[] public Allclaims;

    // Mapping to track premiums received per policyholder
    mapping(address => uint) premiumsReceived;

    // Mapping to store policies per policyholder
    mapping(address => Policy) policies;

    // Mapping to track user premiums for calculations
    mapping(address => uint) userpremium;

    // Nested mapping to manage different policies by policyholder and ID
    mapping(address => mapping(uint => Policy)) policiess;

    // Mapping to count the number of policies per policyholder
    mapping(address => uint) policiesCount;

    // Event declarations for policy lifecycle management
    event PolicyInitiated(address indexed policyHolder, uint time);
    event PolicyRenewed(address indexed policyHolder, uint time);
    event PolicyTerminated(
        address indexed policyHolder,
        string reason,
        uint time
    );

    // Event to emit premium information
    event PremiumGenerated(address indexed policyHolder, uint policyId, uint premium);

    // Function to generate and record a premium for a new policy application
    function generatePremium(
        uint256 driverAge,
        uint256 accidents,
        uint256 violations,
        string memory vehicleCategory,
        uint256 vehicleAge,
        uint256 mileage,
        string[] memory safetyFeatures,
        string memory coverageType,
        uint256 vehicleValue,
        string memory imageUrl
    ) public returns (uint premium_) {
        // Calculate premium using the calculator contract
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
        // Generate a new policy ID using msg.sender
        uint id = policiesCount[msg.sender] + 1;
        // Create a new policy and store it in the nested mapping using msg.sender
        Policy storage newPolicy = policiess[msg.sender][id];
        newPolicy.holder = msg.sender; // Use msg.sender as the policy holder
        newPolicy.policyId = id;
        newPolicy.premium = premium;
        newPolicy.vehicleCategory = vehicleCategory;
        newPolicy.vehicleValue = vehicleValue;
        newPolicy.coverageDetails = coverageType;
        newPolicy.imageurl = imageUrl;

        // Increment the policy count for the holder (msg.sender)
        policiesCount[msg.sender]++;

        // Emit the premium generated event
        emit PremiumGenerated(msg.sender, id, premium);

        return newPolicy.premium;


    }


    //For Testing Function purposes//
    function getGeneratePremium(
        address _policyHolder,
        uint256 _id
    ) external view returns (Policy memory) {
        Policy memory newPolicy = policiess[_policyHolder][_id];

        return newPolicy;
    }

    // Function to activate a policy after generating a premium
    // Function to activate a policy after generating a premium
    function initiatePolicy(address policyHolder, uint256 id) public payable {
        Policy storage newPolicy = policiess[policyHolder][id];
        // Check that the policy was previously generated and is not already active
        require(newPolicy.policyId > 0, "Go and generate Premium");
        require(!newPolicy.isActive, "Policy already Active");

        // Check that the correct premium amount is paid
        require(
            newPolicy.premium == msg.value,
            "Premium not paid or incorrect amount"
        );

        // Add policy holder to the voters array if not already a voter
        if (!isVoter(policyHolder)) {
            voters.push(policyHolder);
            totalVoters++;
            minimumVotes = totalVoters / 2; // Update minimum votes required for decisions
        }

        // Mark the address as a policyholder
        policyholders[policyHolder] = true;

        // Set policy as active and record timestamps
        newPolicy.isActive = true;
        newPolicy.creationDate = block.timestamp;
        newPolicy.lastPaymentDate = block.timestamp;
        newPolicy.terminationDate = block.timestamp + 2 days; // Assuming '60' should be a meaningful time period like one year in seconds
        emit PolicyInitiated(policyHolder, block.timestamp);
    }

    // Helper function to check if an address is already a voter
    function isVoter(address _voter) private view returns (bool) {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    // Function to check if a policy is currently active
    function checkPolicyStatus(
        address policyHolder,
        uint256 policyId
    ) public view returns (bool) {
        Policy storage policy = policiess[policyHolder][policyId];
        return policy.isActive;
    }

    // Function to renew an active policy by paying the premium
    function renewPolicy(address policyHolder, uint id) public payable {
        Policy storage policy = policiess[policyHolder][id];
        // Check that the policy is due for renewal
        require(
            block.timestamp >= policy.creationDate + 2 days,
            "Policy is not yet due for renewal"
        );
        // Check that the correct premium amount is paid for renewal
        require(
            msg.value == policy.premium,
            "Incorrect premium paid for renewal"
        );

        // Update the last payment date and keep the policy active
        policy.lastPaymentDate = block.timestamp;
        policy.isActive = true;
        emit PolicyRenewed(policyHolder, block.timestamp);
    }

    // Function to terminate an active policy with a reason
    // Function to terminate an active policy with a reason
    function terminatePolicy(
        address policyHolder,
        string memory reason
    ) public {
        Policy storage policy = policiess[policyHolder][
                        policiesCount[policyHolder]
            ];
        // Ensure the policy is currently active
        require(policy.isActive, "Policy is already inactive");

        // Set policy as inactive and update termination details
        policy.isActive = false;
        policyholders[policyHolder] = false; // Unmark as a policyholder
        policy.terminationDate = block.timestamp;
        policy.terminationReason = reason;
        emit PolicyTerminated(policyHolder, reason, block.timestamp);

        // Check if the policy holder should remain a voter
        updateVoterStatus(policyHolder);
    }

    // Helper function to update voter status based on active policies
    function updateVoterStatus(address policyHolder) private {
        bool hasActivePolicy = false;
        for (uint i = 1; i <= policiesCount[policyHolder]; i++) {
            if (policiess[policyHolder][i].isActive) {
                hasActivePolicy = true;
                break;
            }
        }

        if (!hasActivePolicy && isVoter(policyHolder)) {
            removeVoter(policyHolder);
        }
    }

    // Function to remove a voter from the voters array
    function removeVoter(address _voter) private {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                voters[i] = voters[voters.length - 1]; // Move the last element to the deleted spot to optimize gas usage
                voters.pop(); // Remove the last element
                totalVoters--;
                minimumVotes = totalVoters / 2; // Update minimum votes required for decisions
                break;
            }
        }
    }

    // Function to file a new claim for a policy
    function fileClaim(
        uint256 _policyId,
        uint256 _claimAmount,
        string memory _claimDetails,
        string[] memory _image
    ) public {
        require(
            policiesCount[msg.sender] >= _policyId,
            "Policy ID does not exist"
        );
        Policy storage policy = policiess[msg.sender][_policyId];
        require(policy.isActive, "Policy is not active.");

        // Retrieve the last claim and check its status
        Claim storage lastClaim = lastClaims[msg.sender][_policyId];
        require(
            lastClaim.status == ClaimStatus.Rejected || lastClaim.policyId == 0,
            "Existing claim still being processed"
        );

        // Continue with filing the claim
        Claim storage newClaim = claims[msg.sender][_policyId];
        newClaim.policyId = _policyId;
        newClaim.policyholder = msg.sender;
        newClaim.claimAmount = _claimAmount;
        newClaim.claimDetails = _claimDetails;
        newClaim.image = _image;
        newClaim.status = ClaimStatus.Processing;
        policy.status = ClaimStatus.Processing;

        lastClaims[msg.sender][_policyId] = newClaim; // Update the last claim record

        ClaimId++;
        Allclaims.push(newClaim);

        // Initialize voting for this claim
        for (uint i = 0; i < totalVoters; i++) {
            votes[ClaimId][voters[i]] = Vote(false, VoteOption.None);
        }
    }

    // Function to check the details of a specific policy
    function checkPolicy(
        address policyHolder,
        uint id
    ) public view returns (Policy memory policy_) {
        Policy storage policy = policiess[policyHolder][id];
        return policy;
    }

    // Function to retrieve all claims stored in the contract
    function getAllClaim() public view returns (Claim[] memory) {
        return Allclaims;
    }

    //gettingClaim
    function getClaim(uint256 index) external view returns (Claim memory) {
        return Allclaims[index];
    }

    // ***************************** //
    // ***************************** //
    // An array to store the Ethereum addresses of all voters. The array holds all authorised voters.
    address[] public voters;

    // A counter variable to store the total count of voters.
    uint256 public totalVoters = 0;

    // A counter variable to manage the minimum number of votes required for decisions.
    uint256 public minimumVotes = 0;

    // 'addVoter()' is a function to add a new voter to the system.
    // 'onlyOwner' is a modifier, indicating that only the contract owner can call it.
    function addVoter(address _voter) public onlyOwner {
        // Add the incoming address ('_voter') to the 'voters' array.
        voters.push(_voter);
        // Increase the total count of voters by 1.
        totalVoters++;
        // Recalculate the count of minimum votes required for decisions.
        // Currently, it's set to a minimum of half the total voters.
        minimumVotes = totalVoters / 2;
    }

    // Nested mapping to manage claims made by policyholders with policy ID
    // Updated to check the status of the latest claim
    mapping(address => mapping(uint => Claim)) public lastClaims;

    // Declare a struct to represent a vote with two fields:
    // whether the voter has voted and what their vote option was (Approve, Reject, or None).
    enum VoteOption {
        None,
        Approve,
        Reject
    }

    struct Vote {
        bool voted;
        VoteOption option;
    }

    // Mapping for votes. Each claim ID maps to another mapping,
    // which maps each voter's address to a Vote struct.
    mapping(uint256 => mapping(address => Vote)) public votes;

    // Event declarations to log significant actions and changes within the contract
    event VoteLogged(address voter, uint claimId, bool vote);
    event ClaimStatusChanged(uint claimId, ClaimStatus status, uint256 amount);
    event ClaimProcessed(
        address indexed claimant,
        uint256 policyId,
        bool approved,
        uint256 payout
    );

    // Function to allow voters to vote on a claim
    event Debug(string message, uint value);

    function voteOnClaim(uint _claimId, VoteOption _vote) public {
        require(
            policyholders[msg.sender],
            "Only policyholders can vote on a claim"
        );
        require(_claimId < ClaimId, "Claim does not exist.");
        require(
            !votes[_claimId][msg.sender].voted,
            "Already voted on this claim"
        );

        votes[_claimId][msg.sender].voted = true;
        votes[_claimId][msg.sender].option = _vote;

        emit Debug("Vote Cast", uint(_vote));

        tallyVotes(_claimId); // Tally votes after each vote is cast
    }

    function getVoteOnClaim(
        uint256 _claimId,
        address _holder
    ) public view returns (Vote memory) {
        return votes[_claimId][_holder];
    }

    function tallyVotes(uint _claimId) private {
        uint256 approvals = 0;
        uint256 rejections = 0;
        uint256 totalVotes = 0;

        for (uint256 i = 0; i < totalVoters; i++) {
            if (votes[_claimId][voters[i]].voted) {
                totalVotes++;
                if (votes[_claimId][voters[i]].option == VoteOption.Approve) {
                    approvals++;
                } else if (
                    votes[_claimId][voters[i]].option == VoteOption.Reject
                ) {
                    rejections++;
                }
            }
        }

        emit Debug("Approvals", approvals);
        emit Debug("Rejections", rejections);
        emit Debug("Total Votes", totalVotes);

        if (approvals > totalVoters / 2) {
            finalizeClaim(_claimId, true);
        } else if (rejections > totalVoters / 2) {
            finalizeClaim(_claimId, false);
        }
    }

    function finalizeClaim(uint _claimId, bool approved) private {
        Claim storage claim = Allclaims[_claimId];
        claim.status = approved ? ClaimStatus.Accepted : ClaimStatus.Rejected;

        emit ClaimStatusChanged(_claimId, claim.status, claim.claimAmount);

        if (approved) {
            processPayment(claim.policyholder, claim.claimAmount);
        } else {
            // If claim is rejected and it affects the policy status
            Policy storage policy = policiess[claim.policyholder][
                            claim.policyId
                ];
            policy.isActive = false; // Optionally deactivate the policy on certain conditions
            updateVoterStatus(claim.policyholder); // Update voter status based on active policies
        }
    }

    function processPayment(address claimant, uint256 amount) private {
        (bool sent, ) = claimant.call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Debug("Payment Sent", amount);
    }

    // Function to get vote counts for each voting option for a specific claim ID
    function getVoteCounts(
        uint256 claimId
    )
    public
    view
    returns (uint256 approveCount, uint256 rejectCount, uint256 totalVotes)
    {
        require(claimId < ClaimId, "Claim ID does not exist."); // Ensure the claim ID is valid

        uint256 approvals = 0;
        uint256 rejections = 0;
        uint256 votesCounted = 0;

        for (uint256 i = 0; i < totalVoters; i++) {
            if (votes[claimId][voters[i]].voted) {
                votesCounted++;
                if (votes[claimId][voters[i]].option == VoteOption.Approve) {
                    approvals++;
                } else if (
                    votes[claimId][voters[i]].option == VoteOption.Reject
                ) {
                    rejections++;
                }
            }
        }

        return (approvals, rejections, votesCounted);
    }

    function drainContract(uint amount) public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance >= amount, "INSUFFICIENT_BALANCE");

        // Transfer the entire balance to the owner's address
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "OOPS!!!_SOMETHING_WENT_WRONG");
    }
}