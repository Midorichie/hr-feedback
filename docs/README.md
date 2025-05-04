# HR Feedback System

A decentralized HR performance review and feedback system built on the Stacks blockchain using Clarity smart contracts.

## Overview

This project implements a transparent, immutable HR feedback system that allows:
- Managers to submit performance reviews for employees
- Team members to submit peer feedback to each other
- Secure storage of all feedback and reviews on the blockchain

## Features

- **Performance Reviews**: Managers can submit reviews with ratings (1-5) and comments
- **Peer Feedback**: Any team member can submit feedback to colleagues
- **Permissions Control**: Only managers or admins can submit reviews
- **Transparent History**: All feedback is permanently recorded and retrievable

## Project Structure

```
hr-feedback/
├── .gitignore
├── Clarinet.toml       # Clarinet project configuration
├── package.json        # Node.js package configuration
├── README.md           # This file
├── contracts/
│   └── hr-feedback.clar # Main smart contract
└── tests/
    ├── review_test.clar  # Tests for review functionality
    └── feedback_test.clar # Tests for feedback functionality
```

## Smart Contract Methods

### Performance Reviews

- `submit-review`: Submit a performance review for an employee (manager only)
- `get-review`: Read a review by ID

### Feedback

- `submit-feedback`: Submit feedback to another team member
- `get-feedback`: Read feedback by ID

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

## Security Considerations

- All reviews and feedback are stored on the blockchain and are permanently visible
- Take care not to include sensitive personal information in feedback
- The contract implements basic access controls to ensure only authorized users can submit reviews

## License

[MIT](LICENSE)
