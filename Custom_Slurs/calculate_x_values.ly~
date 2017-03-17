\version "2.19.52"

#(define (calc-dist-to-txt-border rank target direction)
    (let* (
        (pap (hash-ref (hash-ref ht-columns rank) "grob"))
        (x-extent (ly:grob-extent (second target) pap X))
        (txt-ext 
            (if (= direction -1)
                (car x-extent)
                (cdr x-extent)))
        )
        txt-ext
    )
)


#(define (calc-distance-to-neighbour rank neighbour ctx side)
    ;; calculates distance to neighbour, 
    ;; cuts distance at constant MAX-X-EXTENT
    (let* (
        (pap (hash-ref (hash-ref ht-columns rank) "grob"))
        (sys-grob (ly:grob-system pap))
        (ht-neighb (hash-ref ht-columns neighbour))
        (pap-neighb (hash-ref ht-neighb "grob"))
        
        ;; get neighbour's Lyric/Note grob
        (ht-els-nb (get-pap-col-members neighbour))
        (grob-nb 
         (if (hash-ref ht-els-nb (string-append "txt-" ctx))
             (second (hash-ref ht-els-nb (string-append "txt-" ctx)))
             (second (hash-ref ht-els-nb ctx))))
        
        (x-extent-neighb (ly:grob-extent grob-nb sys-grob X))
        
        ;; get source's Lyric/Note grob
        (ht-els-nb (get-pap-col-members rank))
        (grob-orig 
         (if (hash-ref ht-els-nb (string-append "txt-" ctx))
             (second (hash-ref ht-els-nb (string-append "txt-" ctx)))
             (second (hash-ref ht-els-nb ctx))))

        (x-extent-src (ly:grob-extent grob-orig sys-grob X))
        
        (diff 
         (if (= side -1)
             (- (car x-extent-src) (cdr x-extent-neighb))
             (- (car x-extent-neighb) (cdr x-extent-src) )))
             
        (extra-dist (min MAX-X-EXTENT (/ diff 2)))
        )
        extra-dist
    ) 
)




#(define (get-x-value grob cps rank-interval ctx target neighbour border side)
    ;; side means left or right, possible values -1 1
    ;; border might be 0, 1, 2, 3
    ;; 0: edge of word, 
    ;; 1: edge plus a CONSTANT, 
    ;; 2: middle between words, with maximum, 
    ;; 3: start or end of system line (no change) 
    (let* (
        (rank (if (= side -1)
                  (car rank-interval)
                  (cdr rank-interval)))
        
        (add (if (= side -1) 
                  -
                  +))
        
        (dist-to-nb 
         (cond 
              ((equal? neighbour 'last_note)
                   ;(disp 'CALC 'last_note)
                   MAX-X-EXTENT)
              ((equal? neighbour 'first_note)
                   ;(disp 'CALC 'first_note)
                   MAX-X-EXTENT)             
              (#t	
                   (calc-distance-to-neighbour rank neighbour ctx side))
          ))
        
        (x-pos 
            (cond 
                 ((= border 0)
                    (+ (calc-dist-to-txt-border rank target side)))
                 ((= border 1)
                     (add
                      (+ (calc-dist-to-txt-border rank target side))
                      FIX-X-EXTENT))
                 ((= border 2)
                     (add
                      (+ (calc-dist-to-txt-border rank target side))
                      dist-to-nb))   
                ))
        )
        x-pos
    )
)