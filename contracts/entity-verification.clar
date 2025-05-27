;; Entity Verification Contract
;; Validates and manages supply chain participants

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))

;; Entity verification status
(define-map verified-entities principal bool)
(define-map entity-details principal {
  name: (string-ascii 100),
  entity-type: (string-ascii 50),
  verification-date: uint,
  compliance-score: uint
})

;; Verify a new entity
(define-public (verify-entity (entity principal) (name (string-ascii 100)) (entity-type (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? verified-entities entity)) ERR_ALREADY_VERIFIED)
    (map-set verified-entities entity true)
    (map-set entity-details entity {
      name: name,
      entity-type: entity-type,
      verification-date: block-height,
      compliance-score: u100
    })
    (ok true)
  )
)

;; Check if entity is verified
(define-read-only (is-verified (entity principal))
  (default-to false (map-get? verified-entities entity))
)

;; Get entity details
(define-read-only (get-entity-details (entity principal))
  (map-get? entity-details entity)
)

;; Update compliance score
(define-public (update-compliance-score (entity principal) (score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-verified entity) ERR_NOT_FOUND)
    (let ((current-details (unwrap! (map-get? entity-details entity) ERR_NOT_FOUND)))
      (map-set entity-details entity (merge current-details { compliance-score: score }))
      (ok true)
    )
  )
)
