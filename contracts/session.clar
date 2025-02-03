;; Session management contract

;; Constants
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_SESSION_NOT_FOUND (err u101))
(define-constant ERR_SESSION_FULL (err u102))
(define-constant ERR_ALREADY_JOINED (err u103))

;; Data vars
(define-data-var next-session-id uint u0)

;; Session data maps
(define-map sessions
  { session-id: uint }
  {
    host: principal,
    recipe: (string-utf8 256),
    max-participants: uint,
    start-time: uint,
    duration: uint,
    status: (string-ascii 20)
  }
)

(define-map session-participants 
  { session-id: uint, participant: principal }
  { joined-at: uint }
)

;; Create new cooking session
(define-public (create-session 
  (recipe (string-utf8 256))
  (max-participants uint)
  (start-time uint)
  (duration uint)
)
  (let
    (
      (session-id (var-get next-session-id))
    )
    (map-set sessions
      { session-id: session-id }
      {
        host: tx-sender,
        recipe: recipe, 
        max-participants: max-participants,
        start-time: start-time,
        duration: duration,
        status: "scheduled"
      }
    )
    (var-set next-session-id (+ session-id u1))
    (ok session-id)
  )
)

;; Join session
(define-public (join-session (session-id uint))
  (let
    (
      (session (unwrap! (map-get? sessions {session-id: session-id}) ERR_SESSION_NOT_FOUND))
      (existing-participant (map-get? session-participants { session-id: session-id, participant: tx-sender }))
      (participant-count (get-participant-count session-id))
    )
    (asserts! (is-none existing-participant) ERR_ALREADY_JOINED)
    (asserts! (< participant-count (get max-participants session)) ERR_SESSION_FULL)
    (map-set session-participants
      { session-id: session-id, participant: tx-sender }
      { joined-at: block-height }
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-session (session-id uint))
  (map-get? sessions {session-id: session-id})
)

(define-read-only (get-participant-count (session-id uint))
  (let
    ((participants (get-participants session-id)))
    (len participants)
  )
)

(define-read-only (get-participants (session-id uint))
  (map-get? session-participants {session-id: session-id})
)

(define-read-only (is-participant (session-id uint) (user principal))
  (is-some (map-get? session-participants { session-id: session-id, participant: user }))
)
