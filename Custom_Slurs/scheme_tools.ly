\version "2.18.2"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCHEME Tools
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%% DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%
#(define (disp . args)      
     (format #t "\n")
     (for-each 
         (lambda (i)
         (format #t "~A  " i))
         args))

#(define (fdisp nr . args) 
     (let* (
         (str (format #f "~A~AA ~A " "~" nr "\t"))
        )
        (format #t "\n")
        (for-each 
            (lambda (i)
            (format #t str i))
            args)
     )
)

%%%%%%%%%%%%% LOOPS %%%%%%%%%%%%%%%%%%%%%%%%%%
#(define (dloop vals)
    (define n 0)
    (for-each 
        (lambda (x)
            (disp n)
            (if (list? n) (dloop n) n)
            (newline)
            (set! n (+ 1 n))
            (display x)
        )
        vals 
    )
)

% helper for faster code writing
% needs rework
#(define* (loop liste  #:optional (fkt #f) .  args)
    (if fkt
        (map (lambda (x) 
            (if (not(equal? args '()))
                (begin
                    (fkt (map (lambda (y) y ) args) x)
                )
                (fkt x))) 
            liste)
        (map (lambda (x) x) liste)))


% helper for faster code writing
% needs rework
#(define* (loopB liste  #:optional (fkt #f) .  args)
     (disp 'Liste (length liste))
     (disp 'FUNKTION fkt)
     (disp 'ARGS args)
    (if fkt
        (map (lambda (x) 
            (if (not(equal? args '()))
                (begin
                    (fkt (map (lambda (y) y ) args) x)
                )
                (fkt x))) 
            liste)
        (map (lambda (x) x) liste)))

#(define (break-loop elements fkt condit)
    ;; elements => list
    ;; breaks loop when fkt result equals condit
    ;; or running out of elements
    ;; there should be a better solution for
    ;; the line: set! result ...
    (let* (
        (result #f)
        )
        (do ((i 1 (1+ i))
             (x (fkt 0)  (fkt i))
             )
            (
            (begin 
                (set! result (list-ref elements (1- i) ))
                (= i (length elements)) or (equal? condit (fkt (1- i))))
            x)
        )
    result
    )
)

%%%%%%%%%%%%%%%%%%% LISTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#(define (nth n l)
    (if 
        (or (> n (length l)) (< n 0))        
        (error "Index out of bounds.")
        (if 
            (eq? n 0)
            (car l)
            (nth (- n 1) (cdr l))
        )
    )
)

#(define (list-cut! liste start stop)
    (if (or (> (+ start stop) (length liste))
            (> start stop))
        (throw 'FEHLER (disp "ERROR in list-cut! list out of bounds"  )))
    
    (let* (        
        (list-start (list-head liste  stop))
        (list-final (list-tail list-start  start))
        )
    list-final
    )
)
%%%%%%%%%%%%%%%%%% HASH TABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%

#(define (get-hash-table-keys ht)
    (let* (
        (all (hash-map->list cons ht))
        (keys (map
               (lambda (x)
                   (first x))
               all))
        )
        keys
    )
)

#(define (sort-hash-table-by-keys ht)
     ; returns a sorted list
    (let* (
        (keys (get-hash-table-keys ht))
        (sorted-keys (sort keys <))
        (sorted-ht-list (map
            (lambda (x)
                (cons x (hash-ref ht x )))
                sorted-keys))
        )
        sorted-ht-list
    )
)

%% for debugging reasons
% display ht-columns
#(define (display-ht ht)
     (let* (
         (all-paps (sort-hash-table-by-keys ht)))
         (for-each (lambda (x)
             (disp (car x) (hash-table->alist  (cdr x))))
             all-paps)))

% function for inserting into ht-columns
#(define (insert-in-ht ht nr mykey myval)
    (let* (
        (tmp (hash-ref ht nr))
        (ht-tmp (make-hash-table))
        )
        (if (equal? tmp #f)
            (begin
            (hash-set! ht-tmp mykey myval )
            (hash-set! ht nr ht-tmp )
            )
            (hash-set! tmp mykey myval )
        )
        ;(disp tmp ht nr)
    )
)
         

%%%%%%%%%%%%%%%%%% MISC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#(define first-time-list '())
#(define (do-once fkt arg nr)
     (if (equal? (member nr first-time-list) #f)
         (begin  
             (set! first-time-list 
                   (append first-time-list (list nr)))
             (fkt arg))))  



#(define (sum elemList)
  (if
    (null? elemList)
    0
    (+ (car elemList) (sum (cdr elemList)))
  )
)



% dummy function
#(define (do-nothing)
     0)