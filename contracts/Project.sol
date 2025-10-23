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
