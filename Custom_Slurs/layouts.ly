\version "2.19.52"

\paper {
  system-system-spacing.padding = #0
  system-system-spacing.basic-distance = #0
  system-system-spacing.minimal-distance = #0
  score-markup-spacing.basic-distance = #0
  score-markup-spacing.minimal-distance = #0
  score-system-spacing.minimal-distance = #0
  score-system-spacing.basic-distance = #0
  indent = 0.0\cm
 
  print-page-number = ##t
  print-first-page-number = ##t
  oddHeaderMarkup = \markup \null
  evenHeaderMarkup = \markup \null
  oddFooterMarkup = 
      \markup {
        \fill-line {
          \on-the-fly #print-page-number-check-first
          \fromproperty #'page:page-number-string 
      }}
  evenFooterMarkup = \oddFooterMarkup

  myStaffSize = #18
 #(define fonts
    (make-pango-font-tree "Trebuchet MS"
    "Nimbus Sans"
    "Luxi Mono"
    (/ myStaffSize 20)))   
}


farbe =  #(x11-color 'grey65)
white =  #(x11-color 'grey100)

Layout-Noten = {

  % Farben
  \override Voice.NoteHead.color = \farbe
  \override Voice.Stem.color = \farbe
  \override Voice.Beam.color = \farbe
  \override Voice.TupletNumber.color = \farbe
  \override Voice.Dots.color = \farbe
  \override Voice.Rest.color = \farbe
  \override Staff.BarLine.color = #white
  \override Voice.DynamicText.color = #red

  \override Staff.StaffSymbol.line-count = #0
  \override Staff.NoteHead.font-size = #-4

  % Hals
  \override Voice.Stem.length = #3
  \override Voice.Stem.thickness = #1
  % Hals mit Balken
  \override Voice.Stem.length-fraction = #0.6
  \override Voice.Flag.font-size = #-5
  \override Voice.Beam.beam-thickness = #0.3
  \override Voice.Beam.length-fraction = #0.6
  \override Voice.Beam.auto-knee-gap = #0.1
  \override Voice.Beam.gap = #0.
 
  \override TupletBracket.stencil = ##f
 
  % Abstand Akzente
  \override Staff.Script.padding = #1
 
  \override Voice.Script.color = #red
  
  % Ausblenden des Pausenstencils, wird trotzdem berechnet
  % Noten können so aber nicht ohne Fehler ausgeblendet werden
%   \override Voice.Rest.stencil = ##f
%   \override Staff.NoteHead.stencil = ##f
%   \override Voice.Stem.stencil =##f
  
  % \override Voice.Rest.color = \white
%   \override Staff.NoteHead.color = \white
%   \override Voice.Stem.color = \white
}

Layout = {
  \override Staff.StaffSymbol.line-count = #1
  %\override Staff.StaffSymbol.thickness = #0.2
  \override Staff.Stem.transparent = ##t
  % Hals
  \override Voice.Stem.length = #2
  % Hals mit Balken
  \override Voice.Stem.length-fraction = #0
  \override Staff.NoteHead.font-size = #-100
  % Balken
  \override Voice.Beam.beam-thickness = #0
  \override Voice.Beam.length-fraction = #0
  \override Voice.Dots.stencil = ##f
  \override Voice.Stem.stencil = ##f
  \override Voice.Flag.stencil = ##f
  \override Voice.TupletNumber.stencil = ##f
  \override Staff.TextScript.stencil  = ##f
  \override Staff.Rest.stencil  = ##f
 
  \override Staff.BarLine.bar-extent = #'(-.8 . .8)
  \override Staff.BarLine.hair-thickness = #'1.5
  
  \override Voice.PhrasingSlur.cross-staff = ##t
    
}


abstand = {
  \override
      VerticalAxisGroup.default-staff-staff-spacing =
      #'((basic-distance . 0)
         (minimum-distance . 0)
         (padding . 0)
         )      
}

% unsichtbare Noten - ohne Taktstriche
us-oT = {
  \override Voice.Beam.stencil = ##f
  \override Voice.Stem.stencil = ##f
  \override Voice.Flag.stencil = ##f
  \override Voice.Rest.stencil = ##f
  \override Voice.NoteHead.transparent = ##t
  \override Voice.Dots.transparent = ##t
  \override Staff.BarLine.stencil = ##f 
  \override Voice.Script.Y-offset = #0
}




layout-top = {
    \Layout-Noten
    \abstand
    \override Staff.Script.direction = #UP
    \override PhrasingSlur.direction = #UP
    \dynamicUp  
}

layout-middle = {
    \Layout
    \abstand
    \override StaffSymbol.color = #farbe
    % can't remove PhrasingSlur from the middle staff
    % by \remove "Phrasing_slur_engraver",
    % whereas \consists would work well
    \override PhrasingSlur.stencil = ##f
}

layout-bottom = {
    \Layout-Noten
    
    \override PhrasingSlur.direction = #DOWN
}
