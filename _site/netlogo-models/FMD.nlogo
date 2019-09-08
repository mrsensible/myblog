breed [cows cow]
breed [pigs pig]
breed [trucks truck]
breed [farms farm]



globals
[%animals-infected
 repeat-again
 tick-in-simulation
]

turtles-own
  [ infected?
    exposed?
    exposured_length
    t_farmcode ]       ;; if true, the turtle is infectious


    
patches-own
[farm?
  farm_code]

farms-own
[make-farm?]

to setup
  __clear-all-and-reset-ticks


;;set road
ask patches
  [  
   set pcolor brown + 3
   if (pxcor >= 10 and pxcor <= 18)   or  (pycor >= 8 and pycor <= 10)     [ set pcolor gray + 1 ]
   if (pxcor >= -15 and pxcor <= -13) or  (pycor >= 8 and pycor <= 10)     [ set pcolor gray + 1 ]
   if (pxcor >= -15 and pxcor <= -13) or  (pycor >= -18 and pycor <= -16)  [ set pcolor gray + 1 ]
;   if (pxcor >= -24 and pxcor <= -23) and (pycor >= 1 and pycor <= 7)      [ set pcolor gray ]

;;draw road lines
   if ((pycor = 9)   and ((pxcor mod 3) = 0))  [ set pcolor yellow + 2 ]
   if ((pxcor = 14)  and ((pycor mod 4) = 0))  [ set pcolor yellow + 2 ]
   if ((pycor = -17) and ((pxcor mod 3) = 0))  [ set pcolor yellow + 2 ]    
   if ((pxcor = -14) and ((pycor mod 4) = 0))  [ set pcolor yellow + 2 ]
   ]


;;set fertilizer
   ask patches with [ (pxcor >= 7 and pxcor <= 9)     and  (pycor >= 8 and pycor <= 10)]     [ set  pcolor white ]
   ask patches with [ (pxcor >= 19 and pxcor <= 21)   and  (pycor >= 8 and pycor <= 10)]     [ set  pcolor white ]
   ask patches with [ (pxcor >= -15 and pxcor <= -13) and  (pycor >= 8 and pycor <= 10)]     [ set  pcolor white ]
   ask patches with [ (pxcor >= -15 and pxcor <= -13) and  (pycor >= -18 and pycor <= -16)]  [ set  pcolor white ]
   ask patches with [ (pxcor >= 7 and pxcor <= 9)     and  (pycor >= -18 and pycor <= -16)]  [ set  pcolor white ]
   ask patches with [ (pxcor >= 19 and pxcor <= 21)   and  (pycor >= -18 and pycor <= -16)]  [ set  pcolor white ]

setup-livestocks
setup-cows
setup-pigs
setup-trucks
setup-infect

end


to setup-livestocks
  
create-farms farm-density
 let loopnum 0
 while[loopnum != farm-density]
 [ask one-of farms with[make-farm? != 1]
   [ move-to one-of patches with[ pxcor > -28 and pxcor < 28 and pycor > -28 and pycor < 28 
     and pcolor = brown + 3 and mean[pcolor] of patches in-radius 3 = brown + 3 and count patches in-radius 4 with [pcolor = gray + 1] > 0
     and farm? != 1 and count farms in-radius 5 = 0 ]
   
    ask neighbors  [set pcolor [color] of myself set farm? 1 set farm_code [who] of myself]
    ask patch-here [set pcolor [color] of myself set farm? 1 set farm_code [who] of myself]
    set make-farm? 1
   ]
     
  set loopnum loopnum + 1 
 ]
 
     ask patches with [farm? = 1]
    [ask neighbors [set pcolor [pcolor] of myself set farm? 1 set farm_code [farm_code] of myself]]    
end 


to setup-cows
  set-default-shape cows "cow"
   create-cows cows-initial-number
     [ set color brown + 1
       set size 0.9
       set label-color black
       setxy random-xcor random-ycor
       ]
 ask cows  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1]]
           [setxy xcor ycor]
           set t_farmcode [farm_code] of patch-here]
       
end


to setup-pigs
  set-default-shape pigs "sheep"
  create-pigs pigs-initial-number
     [ set color pink + 1
       set size 0.8
       setxy random-xcor random-ycor
       ]
 ask pigs  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1]]
           [setxy xcor ycor]
           set t_farmcode [farm_code] of patch-here]
 
end

to setup-infect
ask one-of pigs with [ [farm?] of patch-here = 1] [set color 117 set exposed? true] 
end


to setup-trucks
  set-default-shape trucks "truck"
  create-trucks trucks-initial-number
       [set color 112
        set size 1
        setxy random-xcor random-ycor
       ]
 ask trucks [ifelse [pcolor] of patch-here != gray + 1 
            [ move-to one-of patches with [pcolor = gray + 1 ]][setxy xcor ycor]]
end



;---------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------


to go ;1TYM
; if ((count cows with [infected? = true] / cows-initial-number) > 0.3) and ((count pigs with [infected? = true] / pigs-initial-number) > 0.3) [stop]
  if (all? cows [infected? = true]) and (all? pigs [infected? = true]) [stop]


  
  
 ask cows  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]]
           [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]
           set heading random 360]]

 ask pigs  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]]
           [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]
           set heading random 360]]


exposure
infect
move-trucks
wash-virus
cum-plot
tick
update-plot
extend-car-effect
end
;;;;;;;;;;;;;;;;;;;;;

to gogo ;Infinite
;  if ((count cows with [infected? = true] / cows-initial-number) > 0.3) and ((count pigs with [infected? = true] / pigs-initial-number) > 0.3)
  if (all? cows [infected? = true]) and (all? pigs [infected? = true])
       [reset set repeat-again repeat-again + 1 ]
  if repeat-again =  stop-when [stop]

 ask cows  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]]
           [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]
           set heading random 360]]

 ask pigs  [ifelse [farm?] of patch-here != 1 [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]]
           [move-to one-of patches with [farm? = 1 and farm_code = [t_farmcode] of myself]
           set heading random 360]]


exposure
infect
move-trucks
wash-virus
extend-car-effect
cum-plot
update-plot
tick
ifelse ticks = 0 [set tick-in-simulation 0][set tick-in-simulation tick-in-simulation + 1]
end




to exposure
  ask turtles with [exposed? = true] [
  let prey one-of turtles in-radius 2
          if prey != nobody                           
          [ ask prey [
            if (random-float 100 < prob-of-infection) and ((-100)/ 53 * temperature >= random-float 10 )
            [ set color 117 set exposed? true]]]]
end

to infect
  let incubation (random 60)
  ask turtles with [exposed? = true]
  [if exposured_length > incubation [set color red set infected? true]
    set exposured_length exposured_length + 1]

end
      


to extend-car-effect

;   if car-effect? [ ifelse [infected?] of turtles-here != true [ask turtles-here in-radius 6]
;                  [set color red]]

if road-distance? [
ask trucks with [infected? = true] [
  let prey one-of turtles in-radius 6
          if prey != nobody                           
[ set color red set infected? true]]]

end

 

to move-trucks
if (highway-effect = "highway")
    [
   ask trucks with[pxcor >= 15 and pxcor <= 16]  [set heading ( 0 ) fd 1.5]  ;Highway heading north
   ask trucks with[pxcor >= 17 and pxcor <= 18]  [set heading ( 0 ) fd 1]
   ask trucks with[pxcor >= 12 and pxcor <= 13]   [set heading ( 180 ) fd 1.5] ;Highway heading south
   ask trucks with[pxcor >= 10 and pxcor <= 11]  [set heading ( 0 ) fd 1.5]
   ask trucks with[pxcor = 14]   [set heading ( 0 + 180 * random 2 ) fd 1.5] ;Highway joongangsun
    ]

if (highway-effect = "road")
    [
   ask trucks with[pxcor >= 15 and pxcor <= 18]  [set heading ( 0 ) fd 1]  ;Highway heading north
   ask trucks with[pxcor >= 10 and pxcor <= 13]   [set heading ( 180 ) fd 1] ;Highway heading south
   ask trucks with[pxcor = 14]   [set heading ( 0 + 180 * random 2 ) fd 1] ;Highway joongangsun
    ]

; National Road(West Sero)
   ask trucks with[pxcor = -13] [set heading ( 0 ) fd 1]  ;Upper national road
   ask trucks with[pxcor = -15] [set heading ( 180 ) fd 1]  ;Upper national road
   ask trucks with[pxcor = -14] [set heading ( 0 + 180 * random 2 ) fd 1] ; Joongangsun
      
; National Road(North)
   ask trucks with[pycor = 8] [set heading ( (90)) fd 1]  ;Lower national roady
   ask trucks with[pycor = 10] [set heading ( 270 ) fd 1]  ;Upper national road
   ask trucks with[pycor = 9] [set heading ( 90 + 180 * random 2 ) fd 1] ; Joongangsun

; National Road(South)
   ask trucks with[pycor = -18] [set heading ( (90)) fd 1]  ;Lower national roady
   ask trucks with[pycor = -16] [set heading ( 270 ) fd 1]  ;Upper national road
   ask trucks with[pycor = -17] [set heading ( 90 + 180 * random 2 ) fd 1] ; Joongangsun


; Junction
   ask trucks with[pxcor >= -15 and pxcor <= -13 and pycor >= 8 and pycor <= 10]    [set heading (random 4 * 90 ) fd 1]
   ask trucks with[pxcor >= 10 and pxcor <= 18   and pycor >= 8 and pycor <= 10]    [set heading (random 4 * 90 ) fd 1]
   ask trucks with[pxcor >= 10 and pxcor <= 18   and pycor >= -18 and pycor <= -16] [set heading (random 4 * 90 ) fd 1]
   ask trucks with[pxcor >= -15 and pxcor <= -13 and pycor >= -18 and pycor <= -16] [set heading (random 4 * 90 ) fd 1]

end


to wash-virus
  if wash-virus?
  [ask trucks
    [if infected? = true 
    [if pcolor = white 
    [if random-float 100 <  cure-rate [set color 112]]]]
  ]

end



to update-plot
  set-current-plot "FMD Status"
  set-current-plot-pen "susceptible"
  plot (( count cows with [(color != red) and (color != 117)] ) + ( count pigs with [(color != red) and (color != 117)]))
  set-current-plot-pen "exposed"
  plot (( count cows with [exposed? = true] ) + ( count pigs with [exposed? = true]))
  set-current-plot-pen "infected"
  plot (( count cows with [infected? = true] ) + ( count pigs with [infected? = true]))

end


to cum-plot
  set-current-plot "Cumulative plot"
  set-current-plot-pen "infected"
  plot (( count cows with [infected? = true] ) + ( count pigs with [infected? = true]))

end



to-report %infected
    report (((count cows with [infected? = true]) + (count pigs with [infected? = true]))
    / ((count cows) + (count pigs)))  * 100 
    
end
  


to reset
  ;ask cows[die]
  ;ask pigs[die]
  ;ask trucks[die]
  ask turtles[die]
setup-cows
setup-pigs
setup-trucks
setup-infect
;update-plot
set-current-plot "FMD status" clear-plot
set tick-in-simulation 0
end





;Copyright 2013 Hyesop Shin
@#$#@#$#@
GRAPHICS-WINDOW
528
24
1232
749
30
30
11.38
1
10
1
1
1
0
1
1
1
-30
30
-30
30
0
0
1
ticks
30.0

BUTTON
3
10
70
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
10
144
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
6
109
207
142
cows-initial-number
cows-initial-number
0
200
140
1
1
NIL
HORIZONTAL

SLIDER
6
153
206
186
pigs-initial-number
pigs-initial-number
0
300
210
1
1
NIL
HORIZONTAL

SLIDER
7
68
208
101
trucks-initial-number
trucks-initial-number
0
100
70
1
1
NIL
HORIZONTAL

SLIDER
192
347
382
380
prob-of-infection
prob-of-infection
0
100
60
1
1
(%)
HORIZONTAL

SWITCH
314
267
449
300
wash-virus?
wash-virus?
1
1
-1000

SLIDER
12
347
184
380
cure-rate
cure-rate
0
100
50
1
1
(%)
HORIZONTAL

MONITOR
369
400
503
449
%infected
%infected
17
1
12

PLOT
8
459
503
614
FMD status
(1/10) Days
Number
0.0
300.0
0.0
500.0
true
false
"" ""
PENS
"susceptible" 1.0 0 -10899396 true "" ""
"exposed" 1.0 0 -5204280 true "" ""
"infected" 1.0 0 -2674135 true "" ""

SLIDER
195
211
367
244
temperature
temperature
-10
-1
-1
1
1
NIL
HORIZONTAL

SLIDER
8
211
180
244
farm-density
farm-density
0
30
25
1
1
NIL
HORIZONTAL

BUTTON
157
10
386
43
go (repeating until stop-when)
gogo
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
241
66
379
111
stop-when
stop-when
10 50 100 200
1

MONITOR
137
400
233
449
repeat-again
repeat-again
17
1
12

PLOT
7
629
504
779
Cumulative plot
(1/10) Days
NO.
0.0
500.0
0.0
500.0
true
false
"" ""
PENS
"infected" 1.0 1 -2674135 true "" ""
"phase" 1.0 0 -1 true "" "plot(repeat-again)"
"pen-2" 1.0 0 -1 true "" "plot(tick-in-simulation)"

SWITCH
150
266
302
299
road-distance?
road-distance?
0
1
-1000

CHOOSER
4
265
142
310
highway-effect
highway-effect
"highway" "road"
0

MONITOR
240
400
359
449
NIL
tick-in-simulation
17
1
12

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

sheep 2
false
13
Polygon -7500403 true false 209 183 194 198 179 198 164 183 164 174 149 183 89 183 74 168 59 198 44 198 29 185 43 151 28 121 44 91 59 80 89 80 164 95 194 80 254 65 269 80 284 125 269 140 239 125 224 153 209 168
Rectangle -7500403 true false 180 195 195 225
Rectangle -7500403 true false 45 195 60 225
Rectangle -16777216 true false 180 225 195 240
Rectangle -16777216 true false 45 225 60 240
Polygon -7500403 true false 245 60 250 72 240 78 225 63 230 51
Polygon -7500403 true false 25 72 40 80 42 98 22 91
Line -16777216 false 270 137 251 122
Line -16777216 false 266 90 254 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
