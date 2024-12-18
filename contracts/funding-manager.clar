;; Contract Name: crowdfunding-manager.clar
;; Description: This Clarity smart contract facilitates a crowdfunding campaign,
;; allowing users to contribute funds towards a specified funding goal. The contract
;; is controlled by an owner who can set the funding goal, start or end the campaign,
;; and manage the state of contributions. It ensures that contributions meet a minimum
;; threshold and that the total contributions do not exceed the funding goal. Users
;; can also request refunds if the funding goal is not met. The contract tracks each
;; user's contribution and provides functions to check the funding status, goal, and
;; individual contributions.

;; ---------------------- CONSTANTS ----------------------
;; Define constants for ownership and error handling
(define-constant contract-owner tx-sender) ;; The owner of the contract (deployer)
(define-constant err-not-owner (err u200)) ;; Error for non-owner actions
(define-constant err-insufficient-funds (err u201)) ;; Error for insufficient balance
(define-constant err-funding-closed (err u202)) ;; Error when funding is closed
(define-constant err-invalid-contribution (err u203)) ;; Error for invalid contributions
(define-constant err-refund-failure (err u204)) ;; Error for refund failure
(define-constant err-amount-exceeded (err u205)) ;; Error when amount exceeds limit

;; ------------------ DATA VARIABLES ---------------------
;; Define contract-level variables
(define-data-var funding-goal uint u1000000) ;; Target amount in microstacks
(define-data-var total-contributed uint u0) ;; Total contributions in microstacks
(define-data-var funding-status uint u0) ;; Funding status: 0 = Closed, 1 = Open
(define-data-var minimum-contribution uint u1000) ;; Minimum allowed contribution in microstacks

;; --------------------- DATA MAPS -----------------------
;; Define mappings for user-specific data
(define-map user-contributions principal uint) ;; Maps each user's address to their contribution amount

;; ------------------- PRIVATE FUNCTIONS -----------------
;; Calculate the refund amount for a user
(define-private (calculate-refund (contributed-amount uint))
  (* contributed-amount (var-get funding-status)))

;; Validate if a contribution is valid
(define-private (is-valid-contribution (contribution uint))
  (and 
    (> contribution (var-get minimum-contribution)) ;; Ensure contribution exceeds the minimum
    (is-eq (var-get funding-status) u0) ;; Check funding is closed
    (<= (+ (var-get total-contributed) contribution) (var-get funding-goal)))) ;; Check if goal is not exceeded

;; ------------------- PUBLIC FUNCTIONS ------------------
;; Set the funding goal (restricted to contract owner)
(define-public (set-funding-goal (goal uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Ensure caller is contract owner
    (asserts! (> goal u0) err-invalid-contribution) ;; Goal must be positive
    (var-set funding-goal goal) ;; Update funding goal
    (ok true)))

;; Start the funding campaign (restricted to contract owner)
(define-public (start-funding)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Ensure caller is contract owner
    (var-set funding-status u1) ;; Set funding status to open
    (ok true)))

;; End the funding campaign (restricted to contract owner)
(define-public (end-funding)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Ensure caller is contract owner
    (var-set funding-status u0) ;; Set funding status to closed
    (ok true)))

;; Allow users to contribute to the funding campaign
(define-public (contribute (amount uint))
  (let (
    (current-contribution (default-to u0 (map-get? user-contributions tx-sender))) ;; Fetch current user's contribution
  )
    (asserts! (is-valid-contribution amount) err-invalid-contribution) ;; Validate contribution
    (map-set user-contributions tx-sender (+ current-contribution amount)) ;; Update user's contribution
    (var-set total-contributed (+ (var-get total-contributed) amount)) ;; Update total contributions
    (ok true)))

;; Refund users if funding goal is not met
(define-public (refund)
  (let (
    (user-contribution (default-to u0 (map-get? user-contributions tx-sender))) ;; Fetch user's contribution
    (contract-balance (var-get total-contributed)) ;; Fetch contract's total balance
  )
    (asserts! (<= contract-balance (var-get funding-goal)) err-funding-closed) ;; Ensure goal is not met
    (asserts! (> user-contribution u0) err-refund-failure) ;; Ensure user has a contribution

    ;; Reset user's contribution and adjust total contributed
    (map-set user-contributions tx-sender u0)
    (var-set total-contributed (- contract-balance user-contribution))

    ;; Issue refund
    (ok user-contribution)))

;; Allows the contract owner to update the minimum contribution amount for the campaign
(define-public (set-minimum-contribution (new-minimum uint))
(begin
  (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Ensure caller is contract owner
  (asserts! (> new-minimum u0) err-invalid-contribution) ;; Minimum must be positive
  (var-set minimum-contribution new-minimum) ;; Update minimum contribution
  (ok true)))

;;  Withdraw Excess Funds 
(define-public (withdraw-excess-funds)
(begin
  (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Only the owner can withdraw
  (let ((excess (if (> (var-get total-contributed) (var-get funding-goal))
                    (- (var-get total-contributed) (var-get funding-goal))
                    u0)))
    (asserts! (> excess u0) (err u206)) ;; Ensure there are excess funds
    (var-set total-contributed (var-get funding-goal)) ;; Update total to funding goal
    (ok excess))))

;; Allows users to reset their contribution during an ongoing campaign
(define-public (reset-contribution)
  (let (
    (user-contribution (default-to u0 (map-get? user-contributions tx-sender))))
    (asserts! (is-eq (var-get funding-status) u1) err-funding-closed) ;; Ensure funding is open
    (asserts! (> user-contribution u0) err-refund-failure) ;; Ensure user has a contribution

    ;; Reset user's contribution and adjust total contributions
    (map-set user-contributions tx-sender u0)
    (var-set total-contributed (- (var-get total-contributed) user-contribution))
    (ok true)))

;; Allows a user to withdraw their contribution during an active campaign
(define-public (withdraw-contribution)
  (let ((user-contribution (default-to u0 (map-get? user-contributions tx-sender))))
    (begin
      (asserts! (is-eq (var-get funding-status) u1) err-funding-closed) ;; Funding must be open
      (asserts! (> user-contribution u0) err-refund-failure) ;; User must have contributed
      (map-set user-contributions tx-sender u0) ;; Reset user's contribution
      (var-set total-contributed (- (var-get total-contributed) user-contribution)) ;; Adjust total contributions
      (ok user-contribution))))

;; Allows the owner to close the campaign early and refund all users if necessary.
(define-public (close-campaign-early)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-owner) ;; Ensure caller is owner
    (asserts! (is-eq (var-get funding-status) u1) err-funding-closed) ;; Campaign must be active
    (var-set funding-status u0) ;; Mark campaign as closed
    (ok true)))


;; ------------------- READ-ONLY FUNCTIONS ----------------
;; Check if the funding goal has been met
(define-read-only (is-goal-met)
  (ok (>= (var-get total-contributed) (var-get funding-goal))))

;; Get the contribution amount for a specific user
(define-read-only (get-user-contribution (user principal))
  (ok (default-to u0 (map-get? user-contributions user))))

;; Get the total contributions made
(define-read-only (get-total-contributions)
  (ok (var-get total-contributed)))

;; Get the funding goal
(define-read-only (get-funding-goal)
  (ok (var-get funding-goal)))

;; Get the funding status (0 = Closed, 1 = Open)
(define-read-only (get-funding-status)
  (ok (var-get funding-status)))

;; Get the minimum contribution amount
(define-read-only (get-minimum-contribution)
  (ok (var-get minimum-contribution)))

;; Get the amount still needed to meet the funding goal.
(define-read-only (get-remaining-goal)
(ok (if (>= (var-get total-contributed) (var-get funding-goal))
      u0
      (- (var-get funding-goal) (var-get total-contributed)))))

;; Verifies that the funding goal is not met and the user has made contributions.
(define-read-only (is-refund-eligible (user principal))
(ok (and (< (var-get total-contributed) (var-get funding-goal)) ;; Goal not met
         (> (default-to u0 (map-get? user-contributions user)) u0)))) ;; User contributed

;; Get Campaign Summary
(define-read-only (get-campaign-summary)
(ok {
  funding-goal: (var-get funding-goal),
  total-contributed: (var-get total-contributed),
  minimum-contribution: (var-get minimum-contribution),
  funding-status: (var-get funding-status)
}))

;; Calculate Potential Contribution Impact 
(define-read-only (calculate-contribution-impact (amount uint))
(ok (if (<= (+ (var-get total-contributed) amount) (var-get funding-goal))
      (- (var-get funding-goal) (+ (var-get total-contributed) amount))
      u0)))

;; Get the percentage of the funding goal achieved
(define-read-only (get-contribution-percentage)
  (ok (if (> (var-get funding-goal) u0)
          (/ (* (var-get total-contributed) u100) (var-get funding-goal))
          u0)))

;; Check if a user is eligible to contribute
(define-read-only (is-contribution-eligible (user principal) (amount uint))
  (ok (and 
        (is-eq (var-get funding-status) u1) ;; Funding is open
        (> amount (var-get minimum-contribution)) ;; Meets minimum contribution
        (<= (+ (default-to u0 (map-get? user-contributions user)) amount) (var-get funding-goal))))) ;; Within goal limit

;; Verifies if a given user is the contract owner
(define-read-only (is-owner (user principal))
  (ok (is-eq user contract-owner)))

;; Gets the rank of a user's contribution in comparison to other contributors
(define-read-only (get-contribution-ranking (user principal))
  (let ((user-contribution (default-to u0 (map-get? user-contributions user))))
    (ok (if (> user-contribution u0)
            (/ (* user-contribution u100) (var-get total-contributed))
            u0))))

;; Gets the remaining contribution capacity for a user
(define-read-only (get-contribution-capacity (user principal))
  (let (
    (current-contribution (default-to u0 (map-get? user-contributions user)))
    (remaining-capacity (if (> (var-get total-contributed) (var-get funding-goal))
                             u0
                             (- (var-get funding-goal) (var-get total-contributed)))))
  (ok (if (>= remaining-capacity current-contribution)
          (- remaining-capacity current-contribution)
          u0))))

;; Checks how much more a user needs to contribute to help meet the funding goal
(define-read-only (get-user-contribution-balance (user principal))
  (let ((user-contribution (default-to u0 (map-get? user-contributions user))))
    (ok (if (>= (+ user-contribution (var-get total-contributed)) (var-get funding-goal))
            u0
            (- (var-get funding-goal) (+ user-contribution (var-get total-contributed)))))))

;; Gets the percentage of total contributions made by a specific user
(define-read-only (get-user-contribution-percentage (user principal))
  (let ((user-contribution (default-to u0 (map-get? user-contributions user)))
        (total (var-get total-contributed)))
    (ok (if (> total u0)
            (/ (* user-contribution u100) total)
            u0)))) ;; Returns percentage as an integer

;; Checks if a user is eligible to withdraw a refund
(define-read-only (can-withdraw-refund (user principal))
  (ok (and 
        (< (var-get total-contributed) (var-get funding-goal)) ;; Funding goal not met
        (> (default-to u0 (map-get? user-contributions user)) u0) ;; User contributed
        (is-eq (var-get funding-status) u0)))) ;; Funding campaign is closed
