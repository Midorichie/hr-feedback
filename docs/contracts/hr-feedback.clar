;; HR Feedback System - Main Contract
;; Controls performance reviews and feedback
 
;; Data Variables
(define-data-var next-review-id uint u1)
(define-data-var next-feedback-id uint u1)
(define-data-var contract-owner principal tx-sender)
 
;; Data Maps
(define-map reviews uint
  {
   employee: principal,
   manager: principal,
   rating: int,
   comments: (buff 256),
   timestamp: uint
  })
 
(define-map feedbacks uint
  {
   from: principal,
   to: principal,
   content: (buff 256),
   timestamp: uint
  })
 
;; Map to track employee's last review ID
(define-map employee-reviews principal uint)
 
;; Access Control
(define-read-only (is-owner)
  (is-eq tx-sender (var-get contract-owner)))
 
(define-read-only (is-manager (employee principal) (manager principal))
  (is-eq manager tx-sender))
 
;; Submit a performance review
(define-public (submit-review
  (employee principal) (manager principal) (rating int) (comments (buff 256)))
  (begin
    ;; only manager or admin (contract deployer) can submit
    (asserts! (or (is-eq tx-sender manager) (is-owner)) (err u401))
    ;; validate rating is between 1 and 5
    (asserts! (and (>= rating 1) (<= rating 5)) (err u402))
    ;; validate employee and manager are different principals
    (asserts! (not (is-eq employee manager)) (err u403))
    ;; validate comments are not empty
    (asserts! (> (len comments) u0) (err u404))
   
    (let
      ((id (var-get next-review-id)))
     
      ;; Store review data
      (map-set reviews id
        {
          employee: employee,
          manager: manager,
          rating: rating,
          comments: comments,
          timestamp: block-height
        })
     
      ;; Update employee's review ID
      (map-set employee-reviews employee id)
     
      ;; Increment review ID counter
      (var-set next-review-id (+ id u1))
      (ok id))))
 
;; Read a review
(define-read-only (get-review (id uint))
  (match (map-get? reviews id)
    review (ok review)
    (err u404)))
 
;; Submit feedback
(define-public (submit-feedback
  (to principal) (content (buff 256)))
  (begin
    ;; Validate target is not the sender
    (asserts! (not (is-eq to tx-sender)) (err u401))
    ;; Validate content is not empty
    (asserts! (> (len content) u0) (err u402))
   
    (let ((id (var-get next-feedback-id)))
      (map-set feedbacks id
        {
          from: tx-sender,
          to: to,
          content: content,
          timestamp: block-height
        })
      (var-set next-feedback-id (+ id u1))
      (ok id))))
 
;; Read feedback
(define-read-only (get-feedback (id uint))
  (match (map-get? feedbacks id)
    fb (ok fb)
    (err u404)))
 
;; Get an employee's review ID
(define-read-only (get-employee-review-id (employee principal))
  (default-to u0 (map-get? employee-reviews employee)))
