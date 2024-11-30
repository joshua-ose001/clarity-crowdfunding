;; Contract Name: crowdfunding-manager.clar
;; Description: This Clarity smart contract facilitates a crowdfunding campaign,
;; allowing users to contribute funds towards a specified funding goal. The contract

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
