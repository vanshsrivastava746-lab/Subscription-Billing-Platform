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
        
        // If already subscribed to this plan, extend the subscription
        Subscriber storage s = subscribers[msg.sender];
        if(s.active && s.planId == _planId) {
            // Extend subscription from current expiry or now
            uint expiry = s.startTimestamp + p.duration;
            if(block.timestamp > expiry) {
                s.startTimestamp = block.timestamp; // renew from now
            }
            // else keep original startTimestamp, just extend
            s.startTimestamp += p.duration;
        } else {
            // New subscription
            s.planId = _planId;
            s.startTimestamp = block.timestamp;
            s.active = true;
        }

        emit Subscribed(msg.sender, _planId, s.startTimestamp);
        emit PaymentReceived(msg.sender, msg.value, block.timestamp);
    }

    // User can cancel subscription
    function cancelSubscription() public {
        Subscriber storage s = subscribers[msg.sender];
        require(s.active, "No active subscription");
        s.active = false;
        emit SubscriptionCancelled(msg.sender, s.planId);
    }

    // Check if subscription is active for a user (now <= start + duration)
    function isSubscribed(address _user) public view returns (bool) {
        Subscriber memory s = subscribers[_user];
        if(!s.active) return false;
        Plan memory p = plans[s.planId];
        if(block.timestamp > s.startTimestamp + p.duration) {
            return false;
        }
        return true;
    }

    // Owner can withdraw collected funds
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

}
