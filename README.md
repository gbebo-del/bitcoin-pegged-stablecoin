# Bitcoin-Pegged Stablecoin Smart Contract

A Clarity smart contract implementation for managing a Bitcoin-pegged stablecoin with built-in over-collateralization, minting, redemption, and liquidation mechanisms.

## Overview

This smart contract enables the creation and management of a stablecoin pegged to Bitcoin's value. It maintains price stability through an over-collateralization mechanism and includes features for minting, redemption, and liquidation of underwater positions.

## Features

- **Minting**: Create new stablecoins by providing Bitcoin collateral
- **Redemption**: Convert stablecoins back to Bitcoin at current market rates
- **Liquidation**: Handle underwater positions to maintain system stability
- **Price Oracle Integration**: External BTC price feed integration
- **Dynamic Collateralization**: Adjustable collateralization ratio
- **Reserve Management**: Automated tracking of total system reserves

## Technical Specifications

### Constants

- `CONTRACT-OWNER`: The contract administrator address
- `PRECISION`: Set to 1,000,000 (6 decimal places)
- Default collateralization ratio: 100%

### Error Codes

- `ERR-UNAUTHORIZED (u1)`: Unauthorized access attempt
- `ERR-INSUFFICIENT-RESERVES (u2)`: Insufficient reserves for operation
- `ERR-INVALID-AMOUNT (u3)`: Invalid input amount
- `ERR-PRICE-DEVIATION (u4)`: Price oracle deviation error
- `ERR-MINT-FAILED (u5)`: Stablecoin minting failure
- `ERR-BURN-FAILED (u6)`: Stablecoin burning failure

## Core Functions

### Minting

```clarity
(define-public (mint-stablecoin (btc-amount uint)))
```

Creates new stablecoins based on provided BTC collateral.

- Parameters:
  - `btc-amount`: Amount of BTC to use as collateral
- Returns: Amount of stablecoins minted
- Requirements:
  - Valid BTC amount > 0
  - Sufficient collateralization ratio maintained

### Redemption

```clarity
(define-public (redeem-stablecoin (stablecoin-amount uint)))
```

Converts stablecoins back to BTC at current market rate.

- Parameters:
  - `stablecoin-amount`: Amount of stablecoins to redeem
- Returns: Equivalent BTC amount
- Requirements:
  - Valid stablecoin amount > 0
  - Sufficient stablecoin balance

### Liquidation

```clarity
(define-public (liquidate (underwater-address principal) (liquidation-amount uint)))
```

Manages underwater positions through forced liquidation.

- Parameters:
  - `underwater-address`: Address to liquidate
  - `liquidation-amount`: Amount to liquidate
- Requirements:
  - Called by contract owner
  - Valid liquidation amount
  - Address must be trusted

## Administrative Functions

### Update Collateralization Ratio

```clarity
(define-public (update-collateralization-ratio (new-ratio uint)))
```

Modifies the system's collateralization ratio.

- Parameters:
  - `new-ratio`: New ratio value (100-200%)
- Requirements:
  - Called by contract owner
  - Ratio within valid range

## View Functions

### Get Total Reserves

```clarity
(define-read-only (get-total-reserves))
```

Returns the total BTC reserves in the system.

### Get Stablecoin Supply

```clarity
(define-read-only (get-stablecoin-supply))
```

Returns the total supply of stablecoins in circulation.

## Security Considerations

1. **Over-collateralization**: The system maintains a minimum 100% collateralization ratio to ensure stability.
2. **Access Control**: Critical functions restricted to contract owner.
3. **Liquidation Mechanism**: Automated handling of risky positions.
4. **Price Oracle**: External price feed integration for accurate BTC pricing.

## Usage Examples

### Minting Stablecoins

```clarity
;; Mint 1 BTC worth of stablecoins
(contract-call? .btc-stable-coin mint-stablecoin u100000000)
```

### Redeeming Stablecoins

```clarity
;; Redeem 5000 stablecoins
(contract-call? .btc-stable-coin redeem-stablecoin u5000000000)
```

## Development and Testing

To deploy and test this contract:

1. Ensure you have a Clarity development environment set up
2. Deploy the contract to your chosen network
3. Initialize the price oracle connection
4. Test all functions with various scenarios
5. Monitor collateralization ratios and system health

## Limitations and Future Improvements

1. **Oracle Redundancy**: Implement multiple price feeds for increased reliability
2. **Dynamic Liquidation**: Add automated liquidation triggers
3. **Governance**: Implement DAO-based governance for parameter updates
4. **Interest Rates**: Add lending/borrowing capabilities
5. **Flash Loan Prevention**: Implement additional security measures

## Contributing

Contributions are welcome! Please submit pull requests with:

- Detailed description of changes
- Test coverage for new features
- Documentation updates
- Adherence to existing code style
