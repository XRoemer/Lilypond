\version "2.19.52"


\include "layouts.ly"
\include "music.ly"

\include "shape_slurs.ly"

\header {
  title = "Custom Phrasing-Slurs Example"
}

  
my-score =
\score  {
  <<   
    \new Staff  = "staff_oben"  
        \with {\layout-top}
        
        \new Voice = "oben" 
        \music-top
        
    \new Staff = "staff_mitte"
        \with {\layout-middle}

        <<                  
            \new Voice = "first"  
                \music-top
            \new Voice = "second"
                \music-bottom
                  
            \new Lyrics = "txt-oben" 
                \with {alignAboveContext = "staff_mitte"}
                \text-top
            \new Lyrics = "txt-unten" 
                \with {\override LyricText.extra-offset = #'(0 . -.6)}
                \text-bottom
        >>
    
    \new Staff  = "staff_unten"
        \with {\layout-bottom}
        
        \new Voice = "unten" 
        \music-bottom   
        
  >>

  \layout  {
        
    \context {
      \Score
      \remove "Bar_number_engraver"
      \remove "Bar_engraver"
    }

    \context {
        \Staff
        \remove "Time_signature_engraver"
        \remove "Clef_engraver"
    }
   
    \context {
      \Lyrics
     
      \remove "Hyphen_engraver"
      \remove "Lyric_engraver"
     
      \accepts "fly"
      \accepts "standard"
    }
       
    \context {
      \name standard
      \type "Engraver_group"     
      \consists "Bar_engraver"
      \consists "Lyric_engraver"
      \consists "Hyphen_engraver"
     
      \override LyricText.self-alignment-X = #1  
      \alias Lyrics       
    }
   
    \context {
      \name fly
      \type "Engraver_group"           
      \consists "Lyric_engraver"
      \consists "Hyphen_engraver"     
      \override LyricText.self-alignment-X = #0      
      \alias Lyrics
    }  
  }
}


%%%%%%%%%%%%%%%%%%% COMPILATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Settable Properties
#(define SLUR-Y-INDENT 1.0)		% slur indent from word baseline towards middleline
#(define MAX-X-EXTENT 2.1)		% maximum of how much a slur is shifted toward the next word
#(define FIX-X-EXTENT 1.5)		% fixed distance in x direction, used at system-line's start and end



#(calculate-custom-phrasingslurs my-score)

\my-score


