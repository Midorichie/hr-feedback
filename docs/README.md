# HR Feedback & Rewards System

A comprehensive decentralized HR performance review, feedback, and rewards system built on the Stacks blockchain using Clarity smart contracts.

## Overview

This project implements a transparent, immutable HR system that allows:
- Managers to submit performance reviews for employees
- Team members to submit peer feedback to each other
- Automatic and manual reward issuance based on performance
- Secure storage of all feedback, reviews, and rewards on the blockchain

## Features

- **Performance Reviews**: Managers can submit reviews with ratings (1-5) and comments
- **Peer Feedback**: Any team member can submit feedback to colleagues
- **Rewards System**: Automatically issues rewards based on high review scores
- **Points Redemption**: Employees can redeem earned reward points after a timelock period
- **Enhanced Security**: Timelocks and role-based access controls
- **Permissions Control**: Only managers or admins can submit reviews and grant rewards
- **Transparent History**: All feedback, reviews, and rewards are permanently recorded and retrievable

## Project Structure

```
hr-feedback/
├── .gitignore
├── Clarinet.toml       # Clarinet project configuration
├── package.json        # Node.js package configuration
├── README.md           # This file
├── contracts/
│   ├── hr-feedback.clar # Main HR feedback smart contract
│   └── rewards.clar     # Rewards management contract
└── tests/
    ├── review_test.clar  # Tests for review functionality
    ├── feedback_test.clar # Tests for feedback functionality
    └── rewards_test.clar  # Tests for rewards functionality
```

## Smart Contract Methods

### HR Feedback Contract

#### Performance Reviews
- `submit-review`: Submit a performance review for an employee (manager only)
- `get-review`: Read a review by ID
- `get-reviews-by-employee`: Get all reviews for a specific employee

#### Feedback
- `submit-feedback`: Submit feedback to another team member
- `get-feedback`: Read feedback by ID

### Rewards Contract

#### Reward Management
- `grant-reward`: Grant reward points to an employee (manager/owner only)
- `get-reward`: Get details of a specific reward
- `get-total-points`: Get the total reward points for an employee
- `get-rewards-by-employee`: Get all rewards for a specific employee
- `redeem-reward`: Redeem points from a specific reward (employee only)

#### Admin Functions
- `set-min-review-score`: Update the minimum score needed for automatic rewards
- `set-reward-timelock`: Update the timelock period before rewards can be redeemed
- `process-review-rewards`: Process automatic rewards based on review scores

## Development

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for Clarity development and testing
- Node.js (optional, for additional tooling)

### Setup

1. Clone the repository
2. Install Clarinet if not already installed
3. Run `clarinet integrate` to set up the development environment

### Testing

Run the test suite:

```bash
clarinet test
```

## Deployment

To deploy to the Stacks blockchain:

1. Set up your deployment wallet using Clarinet
2. Update the deployment plan as needed
3. Deploy using:

```bash
clarinet deploy
```

## Security Enhancements

The system now includes several security improvements:

- **Role-Based Access Control**: Clear separation between employee, manager, and owner roles
- **Timelock Mechanism**: Rewards can only be redeemed after a specified timelock period
- **Input Validation**: All functions validate inputs before processing
- **Error Handling**: Comprehensive error codes and descriptive error messages
- **Contract Interconnection**: Contracts can securely call each other's functions
- **Data Encapsulation**: Each contract manages its own data with proper access controls

## Security Considerations

- All reviews, feedback, and rewards are stored on the blockchain and are permanently visible
- Take care not to include sensitive personal information in feedback
- The contracts implement comprehensive access controls to ensure only authorized users can submit reviews and manage rewards
- The timelock mechanism provides protection against impulsive redemption of rewards

## License

[MIT](LICENSE)
