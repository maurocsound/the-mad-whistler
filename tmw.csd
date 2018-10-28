/*
  tmw.csd:
  
  Copyright (C) 2018 Mauro Giubileo
  This file is part of the project "THE MAD WHISTLER".
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 16
nchnls = 2
0dbfs  = 1

; GLOBAL VARIABLES TO SET SOME GENERAL PARAMS:
; --------------------------------------------
gixres      =   1024
giyres      =   128

giMinFrq    =   262
giMaxFrq    =   4000

giBlowVol   =   0.25
giReverb    =   0.5

; GUI SECTION:
; ------------
FLpanel "THE MAD WHISTLER v0.11 - (C)2018 by Mauro Giubileo", gixres, giyres, -1, -1, 3
FLpanelEnd
FLrun

; MACRO SECTION:
; --------------

; SCALE
; If x1 is in the interval [a1, b1], this macro returns the corresponding x2 value 
; in the interval [a2, b2].
#define SCALE('x1' FROM 'a1' 'b1' TO 'a2' 'b2') #           \
    ( ($x1 - ($a1)) / ($b1 - ($a1)) * ($b2 - ($a2)) + $a2 ) \
#

; INSTRUMENT SECTION:
; -------------------

instr 1
    koutx,  \
    kouty,  \
    kinside FLxyin  0, gixres, 0, giyres, 0, gixres, 0, giyres
    
    kamp    init    0
    kfrq    init    0
    
    ; get the amplitude and frequency values from the mouse position:
    kouty   =       $SCALE( 'kouty' FROM: ['giyres / 5' --> 'giyres'] 
                                      TO: ['0'          --> '0.5'   ] )
                           
    kouty   =       (kouty < 0)? 0 : kouty
    kamp    =       kamp * 0.95 + kouty * 0.05
    
    koutx   =       $SCALE( 'koutx' FROM: ['0'        --> 'gixres'  ] 
                                      TO: ['giMinFrq' --> 'giMaxFrq'] )
                           
    kfrq    =       kfrq * 0.95 + koutx * 0.05
    
    ; the blow:
    kRand   rand    1
    aBlow   rand    kRand
    aBlow   *=      kamp * kRand
    
    kBlwVol =       $SCALE( 'kfrq' FROM: ['giMinFrq' --> 'giMaxFrq'  ] 
                                     TO: ['0'        --> '0.9'       ] )
                                     
    kBlwVol =       giBlowVol * (1 - kBlwVol)
    aBlow   *=      kBlwVol                      
    kBlwFrq max     320, kfrq * 0.5
    aBlow   clfilt  aBlow, kBlwFrq, 0, 2
    
    ; the whistle:
    aWhstl  oscili  kamp, kfrq
    
    ; the blow + the whistle + reverb:
    aout    =       aBlow + aWhstl 
    aout    reverb  aout / 4, giReverb
    
            outs    aout, aout
endin

</CsInstruments>
<CsScore>
i1 0 z
</CsScore>
</CsoundSynthesizer>
