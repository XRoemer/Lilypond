\version "2.19.52"

\include "ly_tools.ly"
\include "scheme_tools.ly"

\include "set_control_points.ly"
\include "calculate_x_values.ly"
\include "calculate_y_values.ly"

\include "debugging.ly"
\include "definitions.ily"


#(define (get-ht-value keyA keyB)
    (hash-ref (hash-ref ht-columns keyB) keyA))


#(define (shape-slurs grob)
;; This method is executed last. Uses the information
;; of preceding methods (in ht-columns and ht-va-distances)
;; to calculate slur positions.
;; It classifies the slurs and starts calculate-control-points
   (let* (
            ;; original ControlPoints
            (cps (ly:slur::calc-control-points grob))
            (ncs (ly:grob-array->list (ly:grob-object grob 'note-columns)))
            
            (left-pc-neighbour '())
            (right-pc-neighbour '())
            
            ; spanner: pair of most left, most right PaperColumn of grob
            (rank-interval  ( ly:grob-spanned-rank-interval  grob ))
            ;; get grobs from the hash-table ht-column, created in engraver method
            (pap-col-left (get-ht-value "grob" (car rank-interval)))
            (pap-col-right (get-ht-value "grob" (cdr rank-interval)))
            ;; spanner-id is used for determing the slur-type
            (spanner-id (ly:grob-property grob 'spanner-id))
            
            (slur-type 
                (cond
                    ((equal? '() spanner-id)
                        'stay)
                    ((equal? 1 spanner-id)
                        'change)
                    ;; might be expanded for further 
                    ;; special cases
                    (#t
                        'extra)))
                        
        )
        
        ;; get and extract informations about positions
        ;; and neighbours
        (if
            ;; grob Item has no properties, so 
            ;; grob::name returns #f
            ;; It indicates a system line break
            (equal? (grob::name pap-col-left) #f)
            (set! left-pc-neighbour 'splitted)
            (begin
                (set! left-pc-neighbour  (get-ht-value "grob" (- (car rank-interval) 1)))
                 (if (equal? (grob::name left-pc-neighbour) #f)
                     (set! left-pc-neighbour 'first_note) 
                     (set! left-pc-neighbour (- (car rank-interval) 2))
                 )
            )
        )
        (if
            (equal? (grob::name pap-col-right) #f)
            (set! right-pc-neighbour 'splitted)
            (begin
                (set! right-pc-neighbour (get-ht-value "grob" (+ 1 (cdr rank-interval))))
                (if (equal? (grob::name right-pc-neighbour) #f)
                    (set! right-pc-neighbour 'last_note) 
                    (set! right-pc-neighbour (+ 2 (cdr rank-interval)))
                )
            )
        )
        
        (set-control-points grob cps rank-interval 
            (cons left-pc-neighbour right-pc-neighbour) slur-type)
        
    )   
)


% counts PaperColumns and NonMusicalPaperColumns
#(define counterPC 0)

% hash table, holding PaperColumns, Lyrics and Notes
% key is the counterPC
#(define ht-columns (make-hash-table))
% Table entry looks like:
% 
% col-counter
%	col 		grob
%	oben 		grob
%	mitte-oben 	grob
%	mitte-unten grob
%	unten		grob

     
collect_cols_slurs_and_lyrics =
%% This method is executed second on second compilation pass. It collects infos and writes them
%% to the hash table ht-columns, keys are the ranks of (NonMusical-) PaperColumns
%% It writes the context of Text and NoteColumns to their property 'annotation
%% for later readout.
#(make-engraver   
    (acknowledgers
        ;; receive PaperColums and NonMusicalPaperColumns
        ;; System linebreaks will later change from NonMus.. to Items
        ;; automatically.
        ((paper-column-interface engraver grob source-engraver)          
            ; (disp 'pap-col counterPC grob)
            (insert-in-ht ht-columns counterPC "grob" grob)
            (set! counterPC (1+ counterPC ))
        )
  
        ((text-interface  engraver grob source-engraver)
            ; for debugging: write counter to line
            ;(ly:grob-set-property! grob 'text (number->string counterPC))
            (let* (
                (id (ly:context-id (ly:translator-context engraver)))
                )
                ; (disp '---lyrics counterPC id)
                (if (member id (list "txt-oben" "txt-unten"))
                    (begin
                        (insert-in-ht ht-columns (1+ counterPC) id grob)
                        (ly:grob-set-property! grob 'annotation id))
                )
                
            )
        )
        ((note-column-interface  engraver grob source-engraver)
            (let* (
                (id (ly:context-id (ly:translator-context engraver)))
                )
                ;(disp '---note counterPC id)
                (if (member id (list "oben" "unten"))
                    (begin
                        (insert-in-ht ht-columns (1+ counterPC) id grob)
                        (ly:grob-set-property! grob 'annotation id)
                        )
                )
                (if (member id (list "first" "second"))
                    (begin
                        (insert-in-ht ht-columns (1+ counterPC) id grob)
                        (ly:grob-set-property! grob 'annotation id)
                        )
                )
            )
        )
    )
)

#(define counter-va-lines 1)
#(define ht-va-distances (make-hash-table))

#(define (get-slur-extentsB layout pages)
;; This method is the first to be executed. It starts at the end
;; of first compilation pass.
;; It iterates over pages/system-lines/VerticalAlignment/VerticalAxisGroup.
;; Writes the distance between each VerticalAxisGroup
;; and the system baseline to the hash table ht-va-distances.
;; Key is the number of the system line, counted by
;; counter-va-lines
    (for-each (lambda (page)
        (for-each (lambda (line)
            (let* (
                (sys-grob (ly:prob-property line 'system-grob))
                )
                (if (not (equal? sys-grob '()))
                    (begin
                        (let* (
                            (vertAlign (ly:system::get-vertical-alignment sys-grob))
                            (va-groups (get-elements vertAlign))
                            (tmp '())
                            )
                            (for-each 
                             (lambda (group)
                                 ;; a VAGroup with no elements (e.g. no lyrics) will turn
                                 ;; to a spanner grob. As it has no properties, grob::name
                                 ;; returns false.
                                (if (grob::name group)
                                    ;; calculate relative position between 
                                    ;; system baseline and VAGroup
                                    (set! tmp (append tmp (list 
                                           (ly:grob-relative-coordinate group sys-grob Y))))
                                    (set! tmp (append tmp '(0 0)))
                                )
                             )
                             va-groups
                            )
                            (hash-set! ht-va-distances
                                         (number->string counter-va-lines)
                                         tmp)
                            (set! counter-va-lines (1+ counter-va-lines))
                        )
                    )
                )
            ))
            (ly:prob-property page 'lines)
        ))
        pages
    )
)    

#(define system-line-counter 0)
#(define (count-system-lines grob) 
;; This method is called first on each system line in the second compilation pass.
;; It sets the system-line-counter to track the current system-line
    (if start-second-pass
        (begin
            (if display-system-line-counter
                (disp 'SYSTEM-LINE-NR  system-line-counter))
            (set! system-line-counter (1+ system-line-counter))
        )
    )
)

%% Two methods for starting methods on the right compilation pass.
#(define (get-slur-extents layout pages)
    (if (not start-second-pass)
        (get-slur-extentsB layout pages)))

#(define (start-shaping grob)     
     (if start-second-pass
         (shape-slurs grob)
         (draw-annotation grob)))

%% for debugging
%% further debug methods can be switched on
%% in set_control_points.ly
#(define display-system-line-counter #f)

custom-slurs =
#(define-music-function (parser location)
     ()
    #{
      \override Staff.PhrasingSlur.cross-staff = ##t
      \override Staff.PhrasingSlur.color = #red
      \override Staff.PhrasingSlur.after-line-breaking = #start-shaping 
      \override Score.SystemStartBar.after-line-breaking = #count-system-lines
    #})


















