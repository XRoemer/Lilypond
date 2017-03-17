\version "2.19.52"

#(define (debug-cases)
     
    (let* (
        ;; Splits
        (splitted-left (equal? 'splitted (car neighbours)))
        (splitted-right (equal? 'splitted (cdr neighbours)))
        (splitted-both (and splitted-right splitted-left))
        (splitted (or splitted-right splitted-left))
        
        ;; Starting Points
        (has-left-nb  (number? (car neighbours)))
        (has-right-nb (number? (cdr neighbours)))
        (has-both-nbs (and has-left-nb has-right-nb))
         )
     
        ;; Debug method for inspecting special cases
        (if splitted 
            ;; Bogen gesplitted
            (begin
                (disp 'Bogen_gesplitted)
                (cond
                    (splitted-both
                        ;(disp 'Mittelbogen)
                        (do-nothing)
                        ; (if stay
    ;                             (disp 'bleibt stay)
    ;                             (disp 'bleibt stay))
                    )
                    (splitted-left
                        ;(disp 'links_gesplitted)
                        (cond
                            ((and stay has-right-nb)
                                ;(disp 'bleibt stay 'has-right-nb has-right-nb)
                                (do-nothing)
                                )
                            ((and stay (not has-right-nb))
                                ;(disp 'bleibt stay 'has-right-nb has-right-nb)
                                (do-nothing)
                                )
                            ((and (not stay) has-right-nb)
                                ;(disp 'bleibt stay 'has-right-nb has-right-nb)
                                (do-nothing)
                                )
                            ((and (not stay) (not has-right-nb))
                                ;(disp 'bleibt stay 'has-right-nb has-right-nb)
                                (do-nothing)
                                ))
                    )
                    (splitted-right
                        ;(disp 'rechts_gesplitted)
                        (cond
                            ((and stay has-left-nb)
                                ;(disp 'bleibt stay 'has-left-nb has-left-nb)
                                (do-nothing)
                                )
                            ((and stay (not has-left-nb))
                                ;(disp 'bleibt stay 'has-left-nb has-left-nb)
                                (do-nothing)
                                )
                            ((and (not stay) has-left-nb)
                                ;(disp 'bleibt stay 'has-left-nb has-left-nb)
                                (do-nothing)
                                )
                            ((and (not stay) (not has-right-nb))
                                ;(disp 'bleibt stay 'has-left-nb has-left-nb)
                                (do-nothing)
                                ))
                    )
                )
            )
              
            (begin  ;; ganzer Bogen
                ;(disp 'ganzer_Bogen)
                (cond 
                    ;; Bogen in einer Zeile, hat beide Nachbarn
                    ((and has-both-nbs stay)
                        ;(disp 'bleibt stay 'has-both-nbs has-both-nbs)
                        (do-nothing)
                        )
                    ;; Bogen in einer Zeile, hat beide Nachbarn
                    ((and has-both-nbs (not stay))
                        ;(disp 'bleibt stay 'has-both-nbs has-both-nbs)
                        (do-nothing)
                        )
                    ;; Bogen links Anfang
                    ((and (not has-left-nb) stay)
                        ;(disp 'bleibt stay 'links_Anfang)
                        (do-nothing)
                        )
                    ((and (not has-left-nb) (not stay))
                        ;(disp 'bleibt stay 'links_Anfang)
                        (do-nothing)
                        )
                    ;; Bogen rechts Ende
                    ((and (not has-right-nb) stay)
                        ;(disp 'bleibt stay 'rechts_Ende)
                        (do-nothing)
                         )
                    ((and (not has-right-nb) (not stay))
                        ;(disp 'bleibt stay 'rechts_Ende)
                        (do-nothing)
                        )
                    ;; Bogen in einer Zeile, hat keine Nachbarn
                    ((and (not has-both-nbs) stay)
                        ;(disp 'bleibt stay 'has-both-nbs has-both-nbs)
                        (do-nothing)
                        )
                    ;; Bogen in einer Zeile, hat keine Nachbarn
                    ((and (not has-both-nbs) (not stay))
                        ;(disp 'bleibt stay 'has-both-nbs has-both-nbs)
                        (do-nothing)
                        )
                    (#t ;;
                        (error "Hier ist ein Sonderfall!!"))
                        
                )  
            )
        ) 
    )
)

#(define (show-info grob rank-interval neighbours slur-type)
    (let* (
        (ctx (get-ctx grob))
        ;; Splits
        (splitted-left (equal? 'splitted (car neighbours)))
        (splitted-right (equal? 'splitted (cdr neighbours)))
        (splitted-both (and splitted-right splitted-left))
        (splitted (or splitted-right splitted-left))
        
        ;; Starting Points
        (has-left-nb  (number? (car neighbours)))
        (has-right-nb (number? (cdr neighbours)))
        (has-both-nbs (and has-left-nb has-right-nb))
        
        )
        ;; Display info in console
        (fdisp 0
            (format #f "CTX ~A" ctx)
            (format #f "Ranks ~A" rank-interval)
            (format #f "NBL ~A" (car neighbours))
            (format #f "NBR ~A" (cdr neighbours))
            (format #f "Type ~A" slur-type)
            (format #f "splitted ~A" splitted)
            (format #f "has-left ~A" has-left-nb)
            (format #f "has-right ~A" has-right-nb)
        )
    )
)

#(define (set-control-points-dbg grob cps rank-interval neighbours slur-type)
    ;; output is quite useless
    (let ((captured-stack #f))
      (catch #t
             (lambda ()
               (set-control-points grob cps rank-interval neighbours slur-type)
               )
             (lambda (mkey . parameters)
               (disp 'MYERROR mkey parameters))
             (lambda (mkey . parameters)
               ;; Capture the stack here:
               (set! captured-stack (make-stack #t))))
      
      (if captured-stack
          (let* (
              (mport (open-output-string))
              )
              (display-backtrace captured-stack mport #f #f '( "In" ) )
;                (disp captured-stack)
;                (disp (stack-length captured-stack))
                (disp "\n FROM THE STACK:")
               (disp (get-output-string mport))
               (throw 'FEHLER)
               mport
            ;(disp 'REF (stack-ref captured-stack 2))
            ;(display-application captured-stack)
         )
      )
  )
)
