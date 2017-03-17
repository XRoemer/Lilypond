\version "2.19.52"

#(define (get-VAgroup-extend grob VA-index pair-index)
;; The extents of the corresponding VAGroup are used to get
    ;; upper and lower edges of a VAGroup
    (let* (
        (vertAlign (get-parent-in-hierarchie grob 'VerticalAlignment))
        (els (get-elements vertAlign))
        
        (fkt ly:axis-group-interface::height)
        (val (fkt (nth VA-index els)))       
        )
        (if (= pair-index 0)
            (car val)
            (cdr val))
    )
)



#(define (get-y-value grob ctx target stay)
    (let* (
        (is-upper-slur (equal? ctx "oben"))
        
        ;; y-pos is calculated to the lyrics baseline.
        ;; therefore the upper slur has to be set to 
        ;; the upper border of the text
        (txt-height
            (if (or is-upper-slur (and (not is-upper-slur) (not stay)))
                (get-VAgroup-extend grob (car target) 1)
                0))

        (va-target (ly:grob-get-vertical-axis-group-index (second target)))
        (va-index (ly:grob-get-vertical-axis-group-index grob)) 
        
        ;; get distances to system baseline from hash table
        (distances (hash-ref ht-va-distances (number->string system-line-counter)))
        (orig-pos (nth va-index distances))
        (target-pos (nth va-target distances))
        
        ;; extra offset is not included in the distances
        (extra-offset (ly:grob-property (second target) 'extra-offset))
        (offset (if (pair? extra-offset)
                    (cdr extra-offset)
                    0))
        )
        (+ (* -1 orig-pos) target-pos offset txt-height)    
    )
)

#(define (get-y-value-splitted grob cps ctx stay)
     
    (let* (
        (is-upper-slur (equal? ctx "oben"))
        (va-index (ly:grob-get-vertical-axis-group-index grob)) 
        
        ;; get distances to system baseline from hash table
        (distances (hash-ref ht-va-distances (number->string system-line-counter)))
        (orig-pos (nth va-index distances))        
        )
        (if (not stay)
            (* -1 orig-pos)
            (get-cp cps 3 1))
       
    )
)

#(define (calc-indent neighbours ctx stay)
    ;; stay: 
    ;;		#t: slur stays on system, 
    ;;		#f: slur changes system
    ;;
    ;; Usual indent towards middle system line is SLUR-Y-INDENT
    ;; 
    ;; exceptions: Slur-border is edge: indent 0
    ;; slur changes, 
    ;;		left: from top to bottom: indent word-border-plus
    ;;		left: from bottom to top: indent word-border-plus
    (let* (
        ;; Splits
        (splitted-left (equal? 'splitted (car neighbours)))
        (splitted-right (equal? 'splitted (cdr neighbours)))
        
        (ind (if (or (equal? ctx "oben")
                      (and (equal? ctx "unten")
                            (not stay)))
                (* SLUR-Y-INDENT -1)
                SLUR-Y-INDENT))
        
        (indent-left ind)
        (indent-right ind)
        (word-border-plus (/ SLUR-Y-INDENT -2))
        )
        (if (not splitted-left)
            (if (equal? ctx "oben")
                (if (not stay)
                    (set! indent-left word-border-plus)))
            (set! indent-left 0))
        
        (if (not splitted-right)
            (if (equal? ctx "unten")
                (if (not stay)
                    (set! indent-right word-border-plus)))
            (set! indent-right 0))
        
        (cons indent-left indent-right)
    )
)


















