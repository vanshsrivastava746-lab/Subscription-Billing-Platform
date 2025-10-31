// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Subscription Billing Platform
 * @dev A basic subscription system with plan management, user subscriptions, recurring billing in Ether.
 */

contract SubscriptionBilling {
    
    // Subscription plan struct
    struct Plan {
        string name;
        uint price;            // subscription price in wei (Ether)
        uint duration;         // duration of subscription in seconds
        bool active;
    }
 // Subscriber details
    struct Subscriber {
        uint planId;
        uint startTimestamp;
        bool active;
    }

address public owner;
    uint public nextPlanId;
    mapping(uint => Plan) public plans;
    mapping(address => Subscriber) public subscribers;
    
event PlanCreated(uint planId, string name, uint price, uint duration);
    event Subscribed(address subscriber, uint planId, uint startTimestamp);
    event SubscriptionCancelled(address subscriber, uint planId);
    event PaymentReceived(address subscriber, uint amount, uint timestamp);

modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this");
        _;
    }

constructor() {
        owner = msg.sender;
        nextPlanId = 1;
    }

 // Owner creates new subscription plans
    function createPlan(string memory _name, uint _price, uint _duration) public onlyOwner {
        require(_price > 0, "Price must be positive");
        require(_duration > 0, "Duration must be positive");
        plans[nextPlanId] = Plan(_name, _price, _duration, true);
        emit PlanCreated(nextPlanId, _name, _price, _duration);
        nextPlanId++;
    }

 // User subscribes or renews to a plan by paying the plan price
    function subscribe(uint _planId) public payable {
        Plan memory p = plans[_planId];
        require(p.active, "Plan not active");
        require(msg.value == p.price, "Incorrect payment amount");
