\version "2.19.52"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Formatierung der Phrasierungsbögen
% keine id => Bogen bleibt in der Stimme
% \=1      => Bogen wechselt die Stimme
% \=2      => Übergreifender zusätzlicher Bogen

 
%% StimmeA-Toene bis SimmeB-Worte werden mit Code erzeugt,
%% daher der langgestreckte Satz.
music-top = \relative c''
    {\stemUp 

 		\us-oT
		\time 1/4
		b4 |
		b4\( |
		b4 |
		b4 \) |
		b4 |
		b4 |
		b4  |
		r4  |
		
 		r4 |
		b4 |
		b4 \break
		|
		r4 |
		b4 |
		r4 |
		b4  |
		b4 |
		
 		r4 |
		b4\=1\( |
		r4\=1\) |
		b4 \break
		|
		r4 |
		b4 |
		r4 |
		b4 |
		
 		r4 |
		b4\=1\(
		r4\=1\)
		b4\=1\(
		r4\=1\)
		b4\=1\(
		r4\=1\)
		b4\=1\(
		
 		r4\=1\) \break
 		
 		b4 \( b b b \) 
 		r r r r \break 
 		b b r r r
 		%b b r r r
		
		
     }



music-bottom = \relative c''
    {\stemDown 

 		\us-oT
		\time 1/4
		r4 |
		b4 |
		b4\( |
		r4 |
		b4\) |
		r4 |
		r4 |
		b4\=1\( |
		
 		b4 |
		r4 |
		r4 |
		b4 |
		r4\=1\) |
		b4 \=1\(
		r4 |
		r4 |
		
 		b4 |
		r4 |
		b4 |
		r4\=1\) |
		b4\=1\( \=2\(
		r4\=1\)
		b4 |
		r4 |
		
 		b4 |
		r4 |
		b4 |
		r4 |
		b4 |
		r4 |
		b4 |
		r4 |
		
 		b4\=2\)
 		
 		r4 r r r
 		b \( b b b \) 
 		b\( b \break b b \break 
 		b\)
		
     }

     
text-top = { 
    \lyricsto first {
      
		\new fly {
		    nach dem Schleicher durch den gelben Sand
			ist also ungerichtet die Reihe
			ziel ist leicht es
			wa ss au ma
			
			Hier ist ein Teilsatz, 
			       
        }
    }
}


text-bottom = {
    \lyricsto second {

		\new fly {
		    Testwort nochmals BTestwortB 
			ihr
			Suchen weitestgehend da
			so los vie ist
			das s ie s
			cht   
			
			der sich hier fortsetzt.
			noch ein sehr langer Bogen
        }
    }
}