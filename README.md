# Crowdfunding Manager Smart Contract

## Overview

The **Crowdfunding Manager** is a Clarity smart contract designed to facilitate a crowdfunding campaign. It allows users to contribute towards a funding goal, while the contract owner can set the goal, start and end the campaign, and manage the state of the contributions. This contract ensures that contributions meet a minimum threshold, and that the total contributions do not exceed the funding goal. It also allows users to request refunds if the funding goal is not met.

### Key Features:
- Set the funding goal.
- Start and end the campaign.
- Track contributions from individual users.
- Refund users if the funding goal is not met.
- Set and modify the minimum contribution amount.
- Allow users to contribute or reset their contributions during the campaign.

---

## Contract Functions

### 1. **set-funding-goal**
   - **Description:** Allows the contract owner to set the crowdfunding goal.
   - **Inputs:** `goal` (uint) - The funding goal in microstacks.
   - **Restrictions:** Only the contract owner can set the goal.

### 2. **start-funding**
   - **Description:** Starts the crowdfunding campaign by opening the funding status.
   - **Restrictions:** Only the contract owner can start the campaign.

### 3. **end-funding**
   - **Description:** Ends the crowdfunding campaign by closing the funding status.
   - **Restrictions:** Only the contract owner can end the campaign.

### 4. **contribute**
   - **Description:** Allows users to contribute to the crowdfunding campaign.
   - **Inputs:** `amount` (uint) - The amount of contribution in microstacks.
   - **Restrictions:** Contribution must meet the minimum threshold and the total contributions should not exceed the funding goal.

### 5. **refund**
   - **Description:** Allows users to request a refund if the funding goal is not met.
   - **Restrictions:** Only available when the funding goal is not met and the user has contributed.

### 6. **set-minimum-contribution**
   - **Description:** Allows the contract owner to set a minimum contribution amount.
   - **Inputs:** `new-minimum` (uint) - The new minimum contribution in microstacks.
   - **Restrictions:** Only the contract owner can update the minimum contribution.

### 7. **withdraw-excess-funds**
   - **Description:** Allows the contract owner to withdraw excess funds if the total contributions exceed the funding goal.
   - **Restrictions:** Only the contract owner can withdraw excess funds.

### 8. **reset-contribution**
   - **Description:** Allows users to reset their contribution during an ongoing campaign.
   - **Restrictions:** Only available when the funding status is open and the user has contributed.

---

## Read-Only Functions

### 1. **is-goal-met**
   - **Description:** Checks if the funding goal has been met.
   - **Outputs:** `true` if the goal is met, `false` otherwise.

### 2. **get-user-contribution**
   - **Description:** Retrieves the contribution amount of a specific user.
   - **Inputs:** `user` (principal) - The user's principal address.
   - **Outputs:** The contribution amount in microstacks.

### 3. **get-total-contributions**
   - **Description:** Retrieves the total contributions made by all users.
   - **Outputs:** The total contributions in microstacks.

### 4. **get-funding-goal**
   - **Description:** Retrieves the funding goal of the campaign.
   - **Outputs:** The funding goal in microstacks.

### 5. **get-funding-status**
   - **Description:** Retrieves the current funding status.
   - **Outputs:** `0` if the campaign is closed, `1` if open.

### 6. **get-minimum-contribution**
   - **Description:** Retrieves the minimum allowed contribution.
   - **Outputs:** The minimum contribution in microstacks.

### 7. **get-remaining-goal**
   - **Description:** Retrieves the amount still needed to meet the funding goal.
   - **Outputs:** The remaining amount in microstacks.

### 8. **is-refund-eligible**
   - **Description:** Verifies if a user is eligible for a refund.
   - **Inputs:** `user` (principal) - The user's principal address.
   - **Outputs:** `true` if the user is eligible for a refund, `false` otherwise.

### 9. **get-campaign-summary**
   - **Description:** Retrieves a summary of the current campaign, including the funding goal, total contributions, minimum contribution, and funding status.
   - **Outputs:** A map containing the campaign details.

### 10. **calculate-contribution-impact**
   - **Description:** Calculates the remaining capacity for a user’s contribution based on the goal.
   - **Inputs:** `amount` (uint) - The amount the user plans to contribute.
   - **Outputs:** The remaining capacity for contribution in microstacks.

### 11. **get-contribution-percentage**
   - **Description:** Retrieves the percentage of the funding goal that has been achieved.
   - **Outputs:** The percentage of the goal achieved.

### 12. **is-contribution-eligible**
   - **Description:** Verifies if a user is eligible to contribute to the campaign.
   - **Inputs:** `user` (principal) - The user's principal address, `amount` (uint) - The contribution amount.
   - **Outputs:** `true` if the user can contribute, `false` otherwise.

### 13. **is-owner**
   - **Description:** Verifies if a user is the contract owner.
   - **Inputs:** `user` (principal) - The user's principal address.
   - **Outputs:** `true` if the user is the owner, `false` otherwise.

### 14. **get-contribution-ranking**
   - **Description:** Retrieves the rank of a user’s contribution compared to others.
   - **Inputs:** `user` (principal) - The user's principal address.
   - **Outputs:** The contribution percentage relative to the total contributions.

### 15. **get-contribution-capacity**
   - **Description:** Retrieves the remaining capacity for a user to contribute towards the goal.
   - **Inputs:** `user` (principal) - The user's principal address.
   - **Outputs:** The remaining contribution capacity in microstacks.

---

## Contract Setup

### Constants:
- **contract-owner:** The principal address of the contract owner (deployer).
- **err-not-owner:** Error code for actions restricted to the owner.
- **err-insufficient-funds:** Error code for insufficient funds.
- **err-funding-closed:** Error code when funding is closed.
- **err-invalid-contribution:** Error code for invalid contribution amounts.
- **err-refund-failure:** Error code when refund fails.
- **err-amount-exceeded:** Error code when the contribution exceeds the goal.

### Data Variables:
- **funding-goal:** The target funding amount.
- **total-contributed:** The total amount contributed.
- **funding-status:** The current status of the campaign (open or closed).
- **minimum-contribution:** The minimum allowed contribution.

### Data Maps:
- **user-contributions:** A map of user contributions, indexed by user address.

---

## Error Handling

The contract includes robust error handling to ensure:
- Only the contract owner can perform certain actions.
- Contributions are valid and within the required parameters.
- Users can request refunds if the campaign fails to meet the funding goal.

---

## Conclusion

This contract offers a comprehensive solution for managing crowdfunding campaigns on the Clarity blockchain. It provides both flexibility for the owner and transparency for contributors, ensuring a smooth and reliable crowdfunding process. 

For further information, feel free to explore the functions and customize the contract as needed for your specific use case.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Special thanks to the Clarity documentation and the Stacks community for providing the tools and resources to build this contract.
