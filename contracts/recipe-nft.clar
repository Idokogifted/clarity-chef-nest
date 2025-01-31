;; Recipe NFT contract

;; Define NFT
(define-non-fungible-token recipe uint)

;; Constants
(define-constant ERR_NOT_OWNER (err u100))

;; Data vars
(define-data-var last-token-id uint u0)

;; Token metadata
(define-map token-metadata
  uint
  {
    creator: principal,
    title: (string-utf8 256),
    ingredients: (list 20 (string-utf8 64)),
    instructions: (string-utf8 1024),
    created-at: uint
  }
)

;; Mint new recipe NFT
(define-public (mint-recipe 
  (title (string-utf8 256))
  (ingredients (list 20 (string-utf8 64)))
  (instructions (string-utf8 1024))
)
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? recipe token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        creator: tx-sender,
        title: title,
        ingredients: ingredients,
        instructions: instructions,
        created-at: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Transfer recipe NFT
(define-public (transfer (token-id uint) (recipient principal))
  (let
    (
      (owner (unwrap! (nft-get-owner? recipe token-id) ERR_NOT_OWNER))
    )
    (asserts! (is-eq tx-sender owner) ERR_NOT_OWNER)
    (try! (nft-transfer? recipe token-id tx-sender recipient))
    (ok true)
  )
)

;; Get recipe metadata
(define-read-only (get-recipe (token-id uint))
  (map-get? token-metadata token-id)
)
