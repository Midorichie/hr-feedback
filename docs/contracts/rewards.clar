;; HR Rewards System - Complementary Contract
;; Manages employee rewards based on performance reviews

;; Data Variables
(define-data-var next-reward-id uint u1)
(define-data-var contract-owner principal tx-sender)
(define-data-var min-review-for-reward int 4)  ;; Minimum average rating to qualify for reward
(define-data-var reward-timelock uint u100)  ;; blocks until reward can be redeemed

;; Data Maps
(define-map rewards uint
  {
   employee: principal,
   points: uint,
   reason: (buff 256),
   timestamp: uint,
   redeemed: bool
  })

(define-map employee-total-points principal uint)

;; Map to track employee's last reward ID
(define-map employee-rewards principal uint)

;; Define the trait for the HR feedback contract
(define-trait hr-feedback-trait
  (
    ;; Define the functions we'll use from the hr-feedback contract
    (get-review (uint) (response {
      employee: principal,
      manager: principal,
      rating: int,
      comments: (buff 256),
      timestamp: uint
    } uint))
  ))

;; Reference to main HR contract
(define-constant hr-feedback-contract .hr-feedback)

;; Access Control
(define-read-only (is-owner)
  (is-eq tx-sender (var-get contract-owner)))

(define-read-only (is-hr-manager)
  (is-eq tx-sender (var-get contract-owner)))

;; Grant reward points to employee
(define-public (grant-reward 
  (employee principal) (points uint) (reason (buff 256)))
  (begin
    ;; only contract owner or manager can grant rewards
    (asserts! (is-owner) (err u401))
    ;; validate points amount (1-100)
    (asserts! (and (> points u0) (<= points u100)) (err u402))
    ;; validate reason is not empty
    (asserts! (> (len reason) u0) (err u403))
    ;; validate employee is not the sender
    (asserts! (not (is-eq employee tx-sender)) (err u404))
    
    (let 
      ((id (var-get next-reward-id))
       (current-points (default-to u0 (map-get? employee-total-points employee))))
      
      ;; Create new reward record
      (map-set rewards id
        {
          employee: employee,
          points: points,
          reason: reason,
          timestamp: block-height,
          redeemed: false
        })
      
      ;; Update employee's total points
      (map-set employee-total-points employee (+ current-points points))
      
      ;; Update employee's reward ID
      (map-set employee-rewards employee id)
      
      ;; Increment reward ID counter
      (var-set next-reward-id (+ id u1))
      (ok id))))

;; Get employee's total reward points
(define-read-only (get-total-points (employee principal))
  (default-to u0 (map-get? employee-total-points employee)))

;; Get specific reward by ID
(define-read-only (get-reward (id uint))
  (match (map-get? rewards id)
    reward (ok reward)
    (err u404)))

;; Get reward ID for an employee
(define-read-only (get-employee-reward-id (employee principal))
  (default-to u0 (map-get? employee-rewards employee)))

;; Redeem reward points (can only be done by the employee)
(define-public (redeem-reward (id uint))
  (let ((reward (unwrap! (map-get? rewards id) (err u404))))
    (begin
      ;; Verify the employee is the one redeeming
      (asserts! (is-eq tx-sender (get employee reward)) (err u401))
      ;; Verify reward hasn't been redeemed yet
      (asserts! (not (get redeemed reward)) (err u403))
      ;; Check if enough time has passed (timelock)
      (asserts! (>= (- block-height (get timestamp reward)) (var-get reward-timelock)) (err u405))
      
      ;; Mark reward as redeemed
      (map-set rewards id (merge reward {redeemed: true}))
      
      ;; Return success with points redeemed
      (ok (get points reward)))))

;; Update minimum review score required for reward eligibility (admin only)
(define-public (set-min-review-score (score int))
  (begin
    (asserts! (is-owner) (err u401))
    (asserts! (and (>= score 1) (<= score 5)) (err u402))
    (var-set min-review-for-reward score)
    (ok true)))

;; Update reward timelock (admin only)
(define-public (set-reward-timelock (blocks uint))
  (begin
    (asserts! (is-owner) (err u401))
    (asserts! (> blocks u0) (err u402))
    (var-set reward-timelock blocks)
    (ok true)))

;; Auto-grant rewards based on review scores (can be called by anyone)
(define-public (process-review-rewards (hr-contract <hr-feedback-trait>) (review-id uint))
  (let 
    ((review (unwrap! (contract-call? hr-contract get-review review-id) (err u404))))
    (begin
      ;; Check if rating meets minimum requirement
      (asserts! (>= (get rating review) (var-get min-review-for-reward)) (err u406))
      
      ;; Calculate points based on rating (rating * 10)
      (let ((points (to-uint (* (get rating review) 10))))
        ;; Grant reward automatically with fixed message
        (grant-reward 
          (get employee review) 
          points
          0x4175746f6d617469632072657761726420666f7220686967682070657266)))))
