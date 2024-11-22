;; title: Bitcoin-Pegged Stablecoin Main Contract
;; summary: A smart contract for managing a bitcoin-pegged stablecoin with minting, redeeming, and liquidation functionalities.
;; description: This contract allows users to mint and redeem a stablecoin pegged to the price of Bitcoin. It includes mechanisms for tracking reserves, ensuring over-collateralization, and liquidating underwater positions. The contract also provides administrative functions for updating collateralization ratios and view functions for retrieving total reserves and stablecoin supply.

(define-constant CONTRACT-OWNER tx-sender)
(define-constant PRECISION u1000000) ;; 6 decimal places of precision

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-RESERVES (err u2))
(define-constant ERR-INVALID-AMOUNT (err u3))
(define-constant ERR-PRICE-DEVIATION (err u4))
(define-constant ERR-MINT-FAILED (err u5))
(define-constant ERR-BURN-FAILED (err u6))

;; Oracle price feed contract (simulated)
(define-read-only (get-btc-price)
  (ok u5000000)) ;; Example: BTC price at $50,000

;; Stablecoin token
(define-fungible-token btc-stable-coin)

;; Reserves tracking
(define-data-var total-reserves uint u0)
(define-data-var collateralization-ratio uint u100) ;; 100% over-collateralization

;; Mint new stablecoins
(define-public (mint-stablecoin (btc-amount uint))
  (let (
    (current-btc-price (unwrap! (get-btc-price) ERR-UNAUTHORIZED))
    (stablecoin-amount (/ (* btc-amount current-btc-price) PRECISION))
  )
  (begin
    ;; Validate mint parameters
    (asserts! (> btc-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (can-mint stablecoin-amount) ERR-INSUFFICIENT-RESERVES)
    
    ;; Update reserves and mint tokens
    (var-set total-reserves (+ (var-get total-reserves) btc-amount))
    (try! (ft-mint? btc-stable-coin stablecoin-amount tx-sender))
    
    (ok stablecoin-amount)
  ))
)

;; Redeem stablecoins for BTC
(define-public (redeem-stablecoin (stablecoin-amount uint))
  (let (
    (current-btc-price (unwrap! (get-btc-price) ERR-UNAUTHORIZED))
    (btc-equivalent (/ (* stablecoin-amount PRECISION) current-btc-price))
  )
  (begin
    ;; Validate redemption parameters
    (asserts! (> stablecoin-amount u0) ERR-INVALID-AMOUNT)
    (asserts! (<= stablecoin-amount (ft-get-balance btc-stable-coin tx-sender)) ERR-INSUFFICIENT-RESERVES)
    
    ;; Burn tokens and update reserves
    (try! (ft-burn? btc-stable-coin stablecoin-amount tx-sender))
    (var-set total-reserves (- (var-get total-reserves) btc-equivalent))
    
    (ok btc-equivalent)
  ))
)

;; Check if minting is possible based on reserves and collateralization
(define-private (can-mint (mint-amount uint))
  (let (
    (current-btc-price (unwrap! (get-btc-price) false))
    (total-stablecoin-value (/ (* (var-get total-reserves) current-btc-price) PRECISION))
    (max-mintable (/ (* total-stablecoin-value (var-get collateralization-ratio)) u100))
  )
  (<=
    (+ mint-amount (ft-get-supply btc-stable-coin))
    max-mintable
  ))
)

;; Liquidation mechanism
(define-public (liquidate (underwater-address principal) (liquidation-amount uint))
  (let (
    (current-btc-price (unwrap! (get-btc-price) ERR-UNAUTHORIZED))
    (user-balance (ft-get-balance btc-stable-coin underwater-address))
  )
  (begin
    ;; Validate liquidation conditions
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (> liquidation-amount u0) ERR-INVALID-AMOUNT)
    
    ;; Burn underwater position
    (try! (ft-burn? btc-stable-coin liquidation-amount underwater-address))
    
    (ok true)
  ))
)

;; Admin functions
(define-public (update-collateralization-ratio (new-ratio uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (and (>= new-ratio u100) (<= new-ratio u200)) ERR-INVALID-AMOUNT)
    (var-set collateralization-ratio new-ratio)
    (ok true)
  )
)

;; View functions
(define-read-only (get-total-reserves)
  (var-get total-reserves)
)

(define-read-only (get-stablecoin-supply)
  (ft-get-supply btc-stable-coin)
)