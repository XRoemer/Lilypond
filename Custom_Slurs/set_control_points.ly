\version "2.19.52"

tmp={\mark"
---- REGELN -------

Phrasing-Slur spanner-id

leer	Bogen keine Änderung
\=1		Bogen wechselt Stimme
\=2		übergreifender Bogen, sitzt oberhalb

Abkürzungen
X:
    kW  (kein Wechsel)
    VN  (Vorgänger oder Nachfolger, je nach Seite)
    aR  (am Rand - Grob Item)
    WR  (Wortrand)
    WR+ (Wortrand plus geringer Abstand)
    max (Hälfte des Zwischenraumes, max Maximalabstand)

Y:
    WU  (Wechsel nach unten)
    WO  (Wechsel nach oben)
    ein (Y zur Mittelzeile hin eingezogen)


- Bogen in einer Zeile:
    -links + rechts:
        -kW,VN: x:max, 	Y:ein
        -kw,aR: x:WR+,  Y:ein
    -links:
        -WU 	x:WR	Y:WR+
        -WO,VN	X:max	Y:ein
        -WO,aR	X:WR	Y:ein
    -rechts:
        -WU,VN	X:max	Y:ein
        -WU,aR	X:WR+	Y:ein
        -WO		X:WR	Y:WR+

- Bogen gesplittet, Anfang:
    -links wie Bogen in einer Zeile
    -rechts:
        - Krümmung verringert

- Bogen gesplittet, Ende:
    wie Anfang seitenverkehrt

- Bogen gesplittet, Mittelzeile
    - Krümmung an Seiten verringert

- übergreifender Bogen:
    -immer oben
    -gleiche Regeln wie bei Vorgängern,
     sollte etwas höher sitzen

"}



#(define (get-cp cps nr xy)   
    (define wert 
        (lambda (x) 
            (cond 
                ((= xy 0) 
                     (car x))
                ((= xy 1) 
                     (cdr x))
            )
        )
    )
    (cond 
      ((= 0 nr)
           (wert (car cps)))
      ((= 1 nr)
           (wert (cadr cps)))
      ((= 2 nr)
           (wert (caddr cps)))
      ((= 3 nr)
           (wert (cadddr cps)))
    )
)

#(define* (set-controlPoint cps nr xy-values) 
     (cond 
         ((= 0 nr)
              (set-car! cps xy-values))
         ((= 1 nr)
              (set-car! (cdr cps) xy-values))
         ((= 2 nr)
              (set-car! (cddr cps) xy-values))
         ((= 3 nr)
              (set-car! (cdddr cps) xy-values))
     )
)

#(define (get-ctx grob)
    ;; get ctx from note-columns annotation
    (let* (
        (note-column (ly:grob-parent grob X))
        (ctx  (ly:grob-property note-column 'annotation))
        )
        ;; if slur has no parent (because it sits on a edge)
        ;; get ctx from another nc in the same VerticalAxisGroup
        (if (equal? ctx '())
            (let* (
                (va-group (get-parent-in-hierarchie grob 'VerticalAxisGroup))
                (els (get-elements va-group))
                ;; function for break-loop
                (fkt (lambda (x) (grob::name (list-ref els x ))))
                (nc (break-loop  els fkt 'NoteColumn ))
                )
                (set! ctx (ly:grob-property nc 'annotation))
            )
        )
        ctx
    )
)

#(define (get-pap-col-members rank)
    ;; get LyricText and NoteColumns in PaperColumn
    ;; returns a hash-table
    ;; key: ctx
    ;; val: AxisGroupIndex
    (let* (
        (pap (hash-ref (hash-ref ht-columns rank) "grob"))
        (els (get-elements pap))
        (members (filter 
            (lambda (x)
                (or (equal? (grob::name x) 'LyricText)  (equal? (grob::name x) 'NoteColumn) )
            )els))
        (selected (make-hash-table))
        (tmp "")
        )
        (for-each (lambda (x)
            (set! tmp (ly:grob-property x 'annotation))      
            (if (not (equal? '() tmp))
                (hash-set!  selected tmp (list (ly:grob-get-vertical-axis-group-index x) x))))
            members
        )
        selected
    )
)  

#(define (get-other-ctx ctx)
    (if (equal? ctx "oben")
        "unten"
        "oben"))


#(define (get-slur-target grob rank ctx stay)
    ;; searches for the targetted lyric grob, the
    ;; slur should be set to. If not found, returns
    ;; the NoteColumn grob
    (let* (
        (pap-col-members (get-pap-col-members rank)) 
        (fkt 
            (lambda (x)
                (if (hash-ref pap-col-members (string-append "txt-" x))
                    (hash-ref pap-col-members (string-append "txt-" x))
                    (hash-ref pap-col-members x)
                )
            )  
         )
         )
         (if stay
             (fkt ctx)
             (fkt (get-other-ctx ctx)))
    )
)

#(define (change-slur-direction 
             new-y0 new-y1 new-y2 new-y3)
     
    (set! new-y1 (+ new-y0 (- new-y0 new-y1)))
    (set! new-y2 (+ new-y3 (- new-y3 new-y2)))
    (cons new-y1 new-y2)
    )

#(define (calculate-handles cps stay ctx left-target right-target
             diff-x diff-y diff-x-last diff-y-last)
    ;; CALCULATION OF HANDLES
    ;; This method is quite rude and might be
    ;; fine-tuned a lot.
    (let (
        ;; 1st CP
        (new-x0 diff-x)
        (new-y0 diff-y)
        
        ;; 2nd CP / HANDLE
        (new-x1 (+ (get-cp cps 1 0) diff-x ))
        (new-y1
            (if left-target
                (if (and (not stay) (equal? ctx "oben"))
                    (+ (get-cp cps 1 1) diff-y)
                    (+ (get-cp cps 1 1) 0))
                (if right-target
                    diff-y 
                    (+ (get-cp cps 1 1) 0 )
                )
            )
        )
        
        ;; 3rd CP / HANDLE
        (new-x2 (+ (get-cp cps 2 0) diff-x-last))
        (new-y2
            (if right-target
                (if left-target
                    (+ (get-cp cps 2 1) 0 )
                    (+ (get-cp cps 2 1) diff-y-last ))
                (if left-target
                    diff-y-last
                    (+ (get-cp cps 2 1) diff-y-last ))
            )
        )
        
        ;; 4th CP
        (new-x3 (+ (get-cp cps 3 0) diff-x-last))
        (new-y3 diff-y-last)
        
        (tmp 0)
        )
        
         ;; change slur direction if slur changes 
         ;; from bottom to top
         (if (and (equal? ctx "unten") (not stay))
             (begin
               (set! tmp
                     (change-slur-direction 
                       new-y0 new-y1 new-y2 new-y3))
               (set! new-y1 (car tmp))
               (set! new-y2 (cdr tmp))
             )
         )
         
         (set-controlPoint cps 0 (cons new-x0 new-y0)) 
         (set-controlPoint cps 1 (cons new-x1 new-y1))
         (set-controlPoint cps 2 (cons new-x2 new-y2))
         (set-controlPoint cps 3 (cons new-x3 new-y3))
    )
    cps
)


#(define (calculate-control-points grob rank-interval 
             neighbours cps slur-type)
    
    (let* (
        (ctx (get-ctx grob))
        ;; TO-DO:
        ;; there might be more options with slur-type
        (stay (equal? slur-type 'stay))
        (indent (calc-indent neighbours ctx stay))
        
        (rank-first (car rank-interval))
        (rank-last (cdr rank-interval))
        
        (left-target
         (if (member (car neighbours) (list 'splitted  ))
             #f ;; left nb is splitted
             (get-slur-target grob rank-first ctx #t)))
        
        (right-target
         (if (member (cdr neighbours) (list 'splitted ))
             #f ;; right nb is splitted
             (get-slur-target grob rank-last ctx stay)))
        
        (diff-x 0)
        (diff-y 0)
        (diff-x-last 0)
        (diff-y-last 0) 
        
        (changed-ctx ctx)
        )
        
        ;; It would be possible to shorten the following lines.
        ;; For a better overview and for to be able to work
        ;; on special cases, I've left them as they are.
        
         ;; left control-point
         (if left-target
             (begin
              (set! diff-x (get-x-value grob cps rank-interval ctx left-target (car neighbours) 2 -1))
              (set! diff-y (get-y-value grob ctx left-target stay))
             )
             ;; Slur is splitted on the left
            (begin
             ;(disp "Calc split-left")
             (set! diff-y (get-y-value-splitted grob cps ctx stay))
            )
         )
 
         ;; Change ctx, if slur changes system
         (set! changed-ctx
             (if (not stay)
                 (get-other-ctx ctx)
                 ctx))
         
         ;; right control-point
         (if right-target
             (begin
                 (set! diff-x-last (get-x-value grob cps rank-interval changed-ctx right-target (cdr neighbours) 2 1))
                 (set! diff-y-last (get-y-value grob ctx right-target stay))
             )
               ;; Slur is splitted on the right
              (begin
               ;(disp "Calc split-right")
               (set! diff-y-last (get-y-value-splitted grob cps ctx stay))
               )
         )
         
        ;; Add Indent
          (set! diff-y (+ diff-y (car indent)))
          (set! diff-y-last (+ diff-y-last (cdr indent)))
        
        
        (set! cps (calculate-handles cps stay ctx left-target right-target
             diff-x diff-y diff-x-last diff-y-last))
        (ly:grob-set-property! grob 'control-points cps)
    )
)


#(define (set-control-points grob cps rank-interval neighbours slur-type)
     
    ;;;;;;;;;;;;;;;;;;;;;;;; DEBUGGING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; Get some infos by uncommenting following lines
    ;; see methods in debugging.ly
    
    ;(show-info grob rank-interval neighbours slur-type)
    
    ;(debug-cases) ;; do something on special cases. see there
    
    ;(do-once (display-member-names-VAGroups grob) 0)
    
    ;; debugging method to write numbers to slur grobs in the engraved notes
    ; (draw-annotationB grob)  
    
    ;;;;;;;;;;;;;;;;;;;;;;;; DEBUGGING END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    (calculate-control-points grob rank-interval 
        neighbours cps slur-type)
)


















