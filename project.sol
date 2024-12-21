// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducatorIncentive {
    address public owner;
    uint256 public totalTokens;
    uint256 public tokensPerEvaluation;

    mapping(address => uint256) public educatorBalances;
    mapping(address => bool) public evaluators;

    event TokensAwarded(address indexed educator, uint256 amount);
    event EvaluatorAdded(address indexed evaluator);
    event EvaluatorRemoved(address indexed evaluator);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier onlyEvaluator() {
        require(evaluators[msg.sender], "Only evaluators can call this function.");
        _;
    }

    constructor(uint256 _initialSupply, uint256 _tokensPerEvaluation) {
        require(_initialSupply > 0, "Initial supply must be greater than zero.");
        require(_tokensPerEvaluation > 0, "Tokens per evaluation must be greater than zero.");

        owner = msg.sender;
        totalTokens = _initialSupply;
        tokensPerEvaluation = _tokensPerEvaluation;
    }

    function addEvaluator(address evaluator) external onlyOwner {
        evaluators[evaluator] = true;
        emit EvaluatorAdded(evaluator);
    }

    function removeEvaluator(address evaluator) external onlyOwner {
        evaluators[evaluator] = false;
        emit EvaluatorRemoved(evaluator);
    }

    function evaluatePerformance(address educator) external onlyEvaluator {
        require(totalTokens >= tokensPerEvaluation, "Insufficient tokens in the pool.");

        educatorBalances[educator] += tokensPerEvaluation;
        totalTokens -= tokensPerEvaluation;

        emit TokensAwarded(educator, tokensPerEvaluation);
    }

    function withdrawTokens() external {
        uint256 amount = educatorBalances[msg.sender];
        require(amount > 0, "No tokens to withdraw.");

        educatorBalances[msg.sender] = 0;

        // Transfer logic (e.g., using an ERC-20 token transfer)
        payable(msg.sender).transfer(amount);
    }

    // Function to fund the contract
    function fundContract() external payable onlyOwner {
        totalTokens += msg.value;
    }

    // Fallback function to accept direct payments
    receive() external payable {
        totalTokens += msg.value;
    }
}

