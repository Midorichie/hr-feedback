(define-data-var next-review-id uint 1)
(define-data-var next-feedback-id uint 1)

(define-map reviews uint
  ((employee principal)
   (manager principal)
   (rating int)
   (comments (buff 256))
   (timestamp uint)))

(define-map feedbacks uint
  ((from principal)
   (to principal)
   (content (buff 256))
   (timestamp uint)))

;; Submit a performance review
(define-read-write-method submit-review
  (employee principal) (manager principal) (rating int) (comments (buff 256))
  (begin
    ;; only manager or admin (contract deployer) can submit
    (asserts! (or (is-eq tx-sender manager) (is-eq tx-sender (contract-owner))) (err u401))
    (asserts! (and (>= rating 1) (<= rating 5)) (err u402))
    (let ((id (get data-var next-review-id)))
      (map-set reviews id
        (tuple
          (employee employee)
          (manager manager)
          (rating rating)
          (comments comments)
          (timestamp (as-max-len (block-height))))
      (var-set next-review-id (+ id u1))
      (ok id))))

;; Read a review
(define-read-only (get-review (id uint))
  (match (map-get reviews id)
    review (ok review)
    none (err u404)))

;; Submit feedback
(define-read-write-method submit-feedback
  (to principal) (content (buff 256))
  (begin
    (let ((id (get data-var next-feedback-id)))
      (map-set feedbacks id
        (tuple
          (from tx-sender)
          (to to)
          (content content)
          (timestamp (as-max-len (block-height)))))
      (var-set next-feedback-id (+ id u1))
      (ok id))))

;; Read feedback
(define-read-only (get-feedback (id uint))
  (match (map-get feedbacks id)
    fb (ok fb)
    none (err u404)))
