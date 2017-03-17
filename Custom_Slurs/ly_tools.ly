\version "2.18.2"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lilypond HELPER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#(define annot-zaehler 0)
#(define (draw-annotation grob)
    ;; for debugging:
    ;; draws a number to the grob
    (ly:grob-set-nested-property! grob (list 'details 'spanner-id ) annot-zaehler)
    (ly:grob-set-property! grob  'annotation (number->string annot-zaehler))      
    (set! annot-zaehler (+ annot-zaehler 1))
)

#(define (draw-annotationB grob)
    ;; for debugging:
    ;; draws a number to the grob
    ;; and a counter plus a line to the console
    (ly:grob-set-nested-property! grob (list 'details 'spanner-id ) annot-zaehler)
    (ly:grob-set-property! grob  'annotation (number->string annot-zaehler))
    (ly:grob-set-property! grob  'annotation-line #t)
    (disp (string-append  (number->string annot-zaehler) " ----------------" ))
    (set! annot-zaehler (+ annot-zaehler 1))
)

#(define (props grob)
     (dloop  (ly:grob-properties grob ) )
     )

#(define (bprops grob)
     (dloop  (ly:grob-basic-properties grob ) )
     )

#(define (grob-name grob)
    (assq-ref (ly:grob-property grob 'meta) 'name))
#(define (get-elements grob)
     (ly:grob-array->list (ly:grob-object  grob 'elements)))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#(define (get-system-grob grob)
     (if (not ( equal? (symbol->string (grob::name grob)) "System"))
         (get-system-grob (ly:grob-parent grob X))
         grob)
)


#(define (disp-member-names-VAGroups vertAlign)
     ;; This method displays all members inside
     ;; the same VerticalAlignGroup
     ;; Handy for Navigation between Grobs
     ;; Use method below to call from any grob
    
    (disp "")
     
    (let* (
              
        (vertAlign-Elements (ly:grob-array->list (ly:grob-object  vertAlign 'elements)))
        (tmp '())
        (tmp-li '())       
        )
    
        (for-each (lambda (e)
              ;; display the VerticalAxisGroup the loop is running at.
              (disp 
                  (string-append  
                      "    " (symbol->string(grob-name e)) " "
                      (number->string (ly:grob-get-vertical-axis-group-index e)) "    "
                  ))
            
              (set! tmp (ly:grob-array->list (ly:grob-object  e 'elements)))
              
              ;; inner loop:
              ;; loops over each element found in VerticalAxisGroup
              ;; writes the name of each element to temp-li, if it 
              ;; hasn't been written already.
              (for-each 
                    (lambda (x)
                        (if  (not (equal? (grob::name x) #f))
                            (if (equal? (member (symbol->string (grob::name x)) tmp-li) #f)
                                (set!  tmp-li (append tmp-li (list (symbol->string (grob::name x)))))
                                )
                            )
                    )
                    tmp 
              )
              
              (disp tmp-li)
              (set! tmp-li '())
              )
        
            vertAlign-Elements
        )  
    )
    (disp "")
)

#(define (display-member-names-VAGroups grob)
     ;; This method displays all members inside
     ;; the same VerticalAlignGroup
     ;; Handy for Navigation between grobs
     ;; Might be called from any grob
    (let* ((vertAlign (get-parent-in-hierarchie grob 'VerticalAlignment)))
        (disp-member-names-VAGroups vertAlign)))


#(define (get-parent-in-hierarchie grob searchword)
     ;; goes up in hierarchie until it finds
     ;; a grob named searchword     
     (define result #f)
     
     (define (get-par grob)
     
         (define compare 
             (lambda (x) 
                 (and (ly:grob? x) 
                      (equal? searchword (grob-name x)))))   

        (let* (
            (parx   (ly:grob-parent grob X))
            (pary   (ly:grob-parent grob Y))
            )
            
            ;(disp (list parx (compare parx) pary (compare pary)))

            (cond 
                ((not(equal? result #f))                     
                     result )
                ((compare parx)
                    (set! result parx)
                    result)
                ((compare pary)
                    (set! result pary)
                    result)
                (else
                    (if (ly:grob? parx)
                        (get-par parx))
                    (if(ly:grob? pary)
                        (get-par pary))  
                )
            )
        )
    )
    ;; the inner function gets called from here
    (let* (
        (result (get-par grob))
        )
        ;; check if we found something
        (if (ly:grob? result)
            result
            #f
        )
    )
)