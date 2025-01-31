;; Reputation contract

;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u100))

;; Maps
(define-map chef-points
  { chef: principal }
  { points: uint }
)

(define-map achievements 
  { chef: principal, achievement: (string-ascii 64) }
  { earned-at: uint }
)

;; Award points to chef
(define-public (award-points (chef principal) (points uint))
  (let
    (
      (current-points (default-to u0 (get points (map-get? chef-points {chef: chef}))))
    )
    (map-set chef-points
      {chef: chef}
      {points: (+ current-points points)}
    )
    (ok true)
  )
)

;; Grant achievement
(define-public (grant-achievement (chef principal) (achievement (string-ascii 64)))
  (map-set achievements
    {chef: chef, achievement: achievement}
    {earned-at: block-height}
  )
  (ok true)
)

;; Read only functions
(define-read-only (get-points (chef principal))
  (default-to u0 (get points (map-get? chef-points {chef: chef})))
)

(define-read-only (has-achievement (chef principal) (achievement (string-ascii 64)))
  (is-some (map-get? achievements {chef: chef, achievement: achievement}))
)
