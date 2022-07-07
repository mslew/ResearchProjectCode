breed [patients patient]
breed [HCWs HCW]

globals[
  patients-patch ;;patches identifying patients
  high-touch ;;patches identifying high-touch frequency surfaces
  low-touch ;;patches identifying low-touch frequency surfaces
  hallways ;hallways patches
  HCW-spawn-patch ;hallways where the HCWs spawn
  time ;master time
  number-discharges ;number of discharges
]

patients-own[
  disease-status-at-admission ;creates a random initial disease-status for the patients
  current-disease-status ;updates the current disease status of patients
  time-since-current-disease-status ;time of having this status
  length-of-stay ;length of stay in the room
  patients-zone ;what zone of the ward the patient is in
  time-since-visit
  visit-time
  time-since-succ-screening ;what time since successful screening
  time-since-unsucc-screening ;what time since unsuccessful screening
  will-ID ;if a patient gets IDd for treatment
  will-treat-succ ;will treat CDI successfully
  will-ID-no-count ;count of how many times will-IDs are no
  new-disease-status ;this is solely used for the if statements in update-disease-status so they don't get called twice.
  time-since-treatment ;have some time here before going back to susceptible
]

patches-own[
  initial-high-touch-level ;high-touch surface contamination level
  initial-low-touch-level ;low-touch surface contamination level
  active-high-touch-level ;active high-touch surface contamination level
  active-low-touch-level ;active low-touch surface contamination level
  HCW-patch-zone ;what zone a patient patch is in
  patient-status
]

HCWs-own[
  HCW-zone ;what zone the HCWs work in
]

to setup
  clear-all
  create-hallways ;;sets background yellow(room space color) and creates the hallways between them
  patient-patch-color-setup ;;creates a patch in each room that identifies as the patient
  low-touch-patch-color-setup ;;creates a patch in each room that identifies as the low-touch surfaces
  high-touch-patch-color-setup ;;creates a patch in each room that identifies as the high-touch surfaces
  HCW-zone-setup ;sets up zones for HCWs
  HCW-spawn-zone-setup ;setup spawn zone for HCWs
  set-patches ;;sets all the globals to the corresponding color
  set-initial-HCW ;sets initial HCW
  set-initial-patients ; sets inital patients
  high-low-touch-setup ;sets values for high and low touch patches
  reset-ticks
end

to go
  ask patients [
    update-disease-status
    update-time
  ]

  ;every day we clean high-touch. check to discharge patients. admit patients
  if time mod 1440 = 0[
    admit-patients
    clean-high-touch
    discharge-patients
  ]
  ;add 15 to overall elapsed time
  set time (time + 15)
  tick
end

;sets background yellow(room space color) and creates the hallways between them
to create-hallways
  ask patches [set pcolor yellow]
  ask patches [
    if (pxcor = -8 or pxcor = -5 or pxcor = -2 or pxcor = 1 or pxcor = 4 or pxcor = 7 or
    pycor = -9 or pycor = -6 or pycor = -3 or pycor = 0 or pycor = 3 or pycor = 6 or pycor = 9) [set pcolor grey]
  ]
end

;creates a patch in each room that identifies as the patient
to patient-patch-color-setup
  ask patches [
    if (pxcor = -7 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor white]
    if (pxcor = -4 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor white]
    if (pxcor = -1 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor white]
    if (pxcor = 2 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor white]
    if (pxcor = 5 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor white]
  ]
end

;creates a patch in each room that identifies as the low-touch surfaces
to low-touch-patch-color-setup
  ask patches [
    if (pxcor = -6 and (pycor = 7 or pycor = 4 or pycor = 1 or pycor = -2 or pycor = -5 or pycor = -8)) [set pcolor 27]
    if (pxcor = -3 and (pycor = 7 or pycor = 4 or pycor = 1 or pycor = -2 or pycor = -5 or pycor = -8)) [set pcolor 27]
    if (pxcor = 0 and (pycor = 7 or pycor = 4 or pycor = 1 or pycor = -2 or pycor = -5 or pycor = -8)) [set pcolor 27]
    if (pxcor = 3 and (pycor = 7 or pycor = 4 or pycor = 1 or pycor = -2 or pycor = -5 or pycor = -8)) [set pcolor 27]
    if (pxcor = 6 and (pycor = 7 or pycor = 4 or pycor = 1 or pycor = -2 or pycor = -5 or pycor = -8)) [set pcolor 27]
  ]
end

;creates a patch in each room that identifies as the high-touch surfaces
to high-touch-patch-color-setup
   ask patches [
    if (pxcor = -6 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor 17]
    if (pxcor = -3 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor 17]
    if (pxcor = 0 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor 17]
    if (pxcor = 3 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor 17]
    if (pxcor = 6 and (pycor = 8 or pycor = 5 or pycor = 2 or pycor = -1 or pycor = -4 or pycor = -7)) [set pcolor 17]
  ]
end

;this sets up the zones for each HCW to work in
to HCW-zone-setup
  ask patches [
    if (pxcor = -7 and (pycor = 8 or pycor = 5 or pycor = 2)) [set HCW-patch-zone 1]
    if (pxcor = -4 and (pycor = 8 or pycor = 5 or pycor = 2)) [set HCW-patch-zone 2]
    if (pxcor = -1 and (pycor = 8 or pycor = 5 or pycor = 2)) [set HCW-patch-zone 3]
    if (pxcor = 2 and (pycor = 8 or pycor = 5 or pycor = 2)) [set HCW-patch-zone 4]
    if (pxcor = 5 and (pycor = 8 or pycor = 5 or pycor = 2)) [set HCW-patch-zone 5]

    if (pxcor = -7 and (pycor = -1 or pycor = -4 or pycor = -7)) [set HCW-patch-zone 6]
    if (pxcor = -4 and (pycor = -1 or pycor = -4 or pycor = -7)) [set HCW-patch-zone 7]
    if (pxcor = -1 and (pycor = -1 or pycor = -4 or pycor = -7)) [set HCW-patch-zone 8]
    if (pxcor = 2 and (pycor = -1 or pycor = -4 or pycor = -7)) [set HCW-patch-zone 9]
    if (pxcor = 5 and (pycor = -1 or pycor = -4 or pycor = -7)) [set HCW-patch-zone 10]
  ]
end

;this is to assign patches were the HCWs spawn and set their zones
to HCW-spawn-zone-setup
  ask patches[
    if (pxcor = -8 and pycor = 8) [set HCW-patch-zone 1]
    if (pxcor = -5 and pycor = 8) [set HCW-patch-zone 2]
    if (pxcor = -2 and pycor = 8) [set HCW-patch-zone 3]
    if (pxcor = 1 and pycor = 8) [set HCW-patch-zone 4]
    if (pxcor = 4 and pycor = 8) [set HCW-patch-zone 5]

    if (pxcor = -8 and pycor = -1) [set HCW-patch-zone 6]
    if (pxcor = -5 and pycor = -1) [set HCW-patch-zone 7]
    if (pxcor = -2 and pycor = -1) [set HCW-patch-zone 8]
    if (pxcor = 1 and pycor = -1) [set HCW-patch-zone 9]
    if (pxcor = 4 and pycor = -1) [set HCW-patch-zone 10]
  ]

  ;set the specific initial starting points for HCWs patches to be black
  ask patches [
    if (pycor = 8 and (pxcor = -8 or pxcor = -5 or pxcor = -2 or pxcor = 1 or pxcor = 4)) [set pcolor black]
    if (pycor = -1 and (pxcor = -8 or pxcor = -5 or pxcor = -2 or pxcor = 1 or pxcor = 4)) [set pcolor black]
  ]

  ;set HCW-spawn-patch to black patches, but then switch back to white to match the hallways
  set HCW-spawn-patch patches with [pcolor = black]
  ask HCW-spawn-patch[set pcolor grey ]
end

;sets all the globals to the corresponding color and initilaize some values
to set-patches
  set patients-patch patches with [pcolor = white]
  set high-touch patches with [pcolor = 17]
  set low-touch patches with [pcolor = 27]
  set hallways patches with [pcolor = grey]
end

;set up 10 HCW agents in hallways
to set-initial-HCW
  let initial-healthcare 10
  create-HCWs initial-healthcare[
    set size .75
    set color black
    set shape "person"
    move-to one-of HCW-spawn-patch with [not any? HCWs-here]
  ]
  ask HCWs[
    set HCW-zone HCW-patch-zone
  ]
end

;set up 30 initial patients
to set-initial-patients
  let initial-patients 30
  create-patients initial-patients[
    set size .75
    set color white
    set shape "person"
    move-to one-of patients-patch with [not any? patients-here]

    ;sets up initial disease-status for the patients
    let disease-status-number random-float 1 ;provides a random decimal not higher than 1
    ifelse disease-status-number < .75[ ;resistant probability
      set disease-status-at-admission "resistant"
      set current-disease-status "resistant"
      set color green
    ][ifelse disease-status-number  < .75 + .09 [ ;susceptible probability
        set disease-status-at-admission "susceptible"
        set current-disease-status "susceptible"
        set color brown
      ][ifelse disease-status-number < .99[ ;colonized probability
          set disease-status-at-admission "colonized"
          set current-disease-status "colonized"
          set color blue
        ][ ;else = diseased
          set disease-status-at-admission "diseased"
          set current-disease-status "diseased"
          set color violet
        ]
      ]
    ]
  ]
  ask patients[
   set patients-zone HCW-patch-zone
  ]
end

;set values for high and low touch patches from sliders
to high-low-touch-setup
  ask high-touch[
    set initial-high-touch-level high-touch-contam-level
  ]
  ask low-touch[
    set initial-low-touch-level low-touch-contam-level
  ]
end

;determine disease-status for patients
to update-disease-status
  set new-disease-status "no"
  let prob-colonized-to-diseased .024 / 96 ;phi
  let alpha 0.5 / 96   ;;probability of becoming susceptible
  let theta 0.033 / 96 ;;probability of becoming resistant again
  let epsilon 0.08 / 96 ;probability of becoming susceptible from diseased
  let random-prob random-float 1
  let turnover 96 ;turnover for successful screening

  ;instead of writing many if elses. I added a and inside of each if statement. thus we know if we need to check or not.
  ;If it is not a new disease status we check, else we dont.
  if current-disease-status = "resistant" and new-disease-status = "no"[
    if random-prob < alpha[
      set current-disease-status "susceptible"
      set color brown
      set time-since-current-disease-status 0
      set new-disease-status "yes"
    ]
  ]
  ;;probability of susceptible patients to become resistant
  if current-disease-status = "susceptible" and new-disease-status = "no"[ ;;if for now until have more elses to use ifelse
      if random-prob < theta[ ;;same as above
       set current-disease-status "resistant"
       set color green
       set time-since-current-disease-status 0
       set new-disease-status "yes"
    ]
  ]
  if current-disease-status = "susceptible" and new-disease-status = "no"[
    susceptible-to-colonized
  ]
  if current-disease-status = "colonized" and new-disease-status = "no"[
    high-touch-shedding
    low-touch-shedding
    if random-prob < prob-colonized-to-diseased[
      set current-disease-status "diseased"
      set color violet
      set time-since-current-disease-status 0
      set new-disease-status "yes"
    ]
  ]
  if current-disease-status = "diseased" and new-disease-status = "no"[ ;diseased to susceptible here: use epsilon.
    high-touch-shedding
    low-touch-shedding
      if random-prob < epsilon and time-since-treatment = 0[
        set time-since-current-disease-status 0
        ifelse random-float 1 < prob-succ-treat [set will-treat-succ "yes"][set will-treat-succ "no"]
        ifelse random-float 1 < sensitivity [
          set will-ID "yes"
          set time-since-succ-screening 0
          set time-since-treatment 0 ;start the time for switching back to susceptible
          update-screening-times
        ][
          set will-ID "no"
          set time-since-unsucc-screening 0
          update-screening-times
        ]
      ]
      if will-ID  = "yes" and will-treat-succ = "yes" and time-since-treatment >= 2880[ ;add aditional parameter that keeps track of time of being treated with CDiff. 2 day wait.
        set current-disease-status "susceptible"
        set color brown
        set time-since-current-disease-status 0
        set new-disease-status "yes"
    ]
      if will-ID = "no" and will-ID-no-count < 2[ ;two successive no's and then we are done.
        set will-ID-no-count will-ID-no-count + 1
        if time-since-unsucc-screening > turnover [ ;after an unseccessful screen, symptomatic patient is screened again
          ifelse random-float 1 < sensitivity [ ;determines if the screening will work
            set will-ID "yes"
            set time-since-succ-screening 0
            update-screening-times
       ][
          set will-ID "no"
          set time-since-unsucc-screening 0
          update-screening-times
        ]
      ]
    ]
    ;final check here to increment the time-since-treatment so we implement the delay of disease status
    if will-ID = "yes" and will-treat-succ = "yes"[
      set time-since-treatment (time-since-treatment + 15)
    ]
  ]
end

;update times for patients
to update-time
  set length-of-stay length-of-stay + 15
  set time-since-current-disease-status time-since-current-disease-status + 15
end

;sub-model to update times for when a patient gets screened.
to update-screening-times
  ask patients with [current-disease-status = "diseased" and will-ID = "yes"] [set time-since-succ-screening time-since-succ-screening + 15]
  ask patients with [current-disease-status = "diseased" and will-ID = "no"] [set time-since-unsucc-screening time-since-unsucc-screening + 15]
end

;how the high-touch patches gets its spores
to high-touch-shedding
  let colonized-contacts-per-tick 9.424 / 96 ;probability of colonized patient adding spores to a high touch surface
  let diseased-contacts-per-tick 9.424 / 96 ;probability of diseased patient adding spores to a high touch surface

  let colonized-spores-per-contact .006 ;each time a colonized patient touches a high touch, this is how many spores are added per cm^2
  let diseased-spores-per-contact .013 ;each time a diseased patient touches a high touch, this is how many spores are added per cm^2

  let random-num random-float 1

  if current-disease-status = "colonized"[
    if random-num < colonized-contacts-per-tick[
      ask patch-at-heading-and-distance 90 1 [set active-high-touch-level active-high-touch-level + colonized-spores-per-contact] ;sets patch's level 1 grid east of patient
    ]
  ]

  if current-disease-status = "diseased"[
    if random-num < diseased-contacts-per-tick[
      ask patch-at-heading-and-distance 90 1 [set active-high-touch-level active-high-touch-level + colonized-spores-per-contact] ;sets patch's level 1 grid east of patient
    ]
  ]

  ;here is the block for changing colors. Darker colors for more spores. 17 -> 16 -> 15
  ask patch-at-heading-and-distance 90 1 [
   ;here is the block for changing colors
    if active-high-touch-level > 0 and active-high-touch-level <= 0.05[
      set pcolor 17 ;sets patch's level 1 grid east of patient to low level color
    ]
    if active-high-touch-level > 0.05 and active-high-touch-level <= 0.1[
      set pcolor 16 ;sets patch's level 1 grid east of patient to medium level color
    ]
    if active-high-touch-level > 0.1[
      set pcolor 15 ;sets patch's level 1 grid east of patient to high level color
    ]
  ]
end

;how the high-touch patches gets its spores
to low-touch-shedding
  let colonized-contacts-per-tick 4.818 / 96 ;probability of colonized patient adding spores to a low touch surface
  let diseased-contacts-per-tick 4.818 / 96 ;probability of diseased patient adding spores to a low touch surface

  let colonized-spores-per-contact .006 ;each time a colonized patient touches a low touch, this is how many spores are added per cm^2
  let diseased-spores-per-contact .013 ;each time a diseased patient touches a low touch, this is how many spores are added per cm^2

  let random-num random-float 1

  if current-disease-status = "colonized"[
    if random-num < colonized-contacts-per-tick[
      ask patch-at-heading-and-distance 135 1 [set active-low-touch-level active-low-touch-level + colonized-spores-per-contact] ;sets patch's level 1 grid southeast of patient. add more spores
    ]
  ]

  if current-disease-status = "diseased"[
    if random-num < diseased-contacts-per-tick[
      ask patch-at-heading-and-distance 135 1 [set active-low-touch-level active-low-touch-level + colonized-spores-per-contact] ;sets patch's level 1 grid southeast of patient. add more spores
    ]
  ]

  ;here is the block for changing colors. Darker colors for more spores. 27 -> 26 -> 25
  ask patch-at-heading-and-distance 135 1 [
   ;here is the block for changing colors
    if active-low-touch-level > 0 and active-low-touch-level <= 0.05[
      set pcolor 27 ;sets patch's level 1 grid east of patient to low level color
    ]
    if active-low-touch-level > 0.05 and active-low-touch-level <= 0.1[
      set pcolor 26 ;sets patch's level 1 grid east of patient to medium level color
    ]
    if active-low-touch-level > 0.1[
      set pcolor 25 ;sets patch's level 1 grid east of patient to high level color
    ]
  ]
end

;cleaning high-touch. happens once a day. random percentage
to clean-high-touch
  let spores-killed-from-extra-cleaning .33 + (random-float (.99 - .33)) ;make the percentage of spores killed a random percentage in a range of .33-.99
  ask high-touch [
    set active-high-touch-level (active-high-touch-level - (active-high-touch-level * spores-killed-from-extra-cleaning))
  ]
end

;susceptible to colonized block utilizing the touch surfaces.
to susceptible-to-colonized
  let K 7.5 ;half saturation constant
  let B 0.338 ;colonization rate upon transfer of spores from a fomite
  let high-touch-level 0 ;set this initially to 0
  let low-touch-level 0 ;set this initially to 0

  ;set these high and low touch levels to the values from in the patients room
  ask patch-at-heading-and-distance 90 1 [ ;high touch
    set high-touch-level active-high-touch-level
  ]
  ask patch-at-heading-and-distance 135 1[ ;low touch
    set low-touch-level active-low-touch-level
  ]

  ;create chances and random values
  let chance-from-high-touch (B * (high-touch-level / (K + high-touch-level))) / 96
  let chance-from-low-touch (B * (low-touch-level / (K + low-touch-level))) / 96

  let random-num random-float 1
  let random-num2 random-float 1

  ifelse random-num < .66[ ;percentage to touch high-touch
    if random-num2 < chance-from-high-touch[
      set current-disease-status "colonized"
      set color blue
      set time-since-current-disease-status 0
      set new-disease-status "yes"
    ]
  ][
    if random-num2 < chance-from-low-touch[
      set current-disease-status "colonized"
      set color blue
      set time-since-current-disease-status 0
      set new-disease-status "yes"
    ]
  ]
end

;discharge patients submodel
to discharge-patients
  let random-num random-float 1

  ask patients[
    if current-disease-status = "resistant"[
      if random-num < 0.33[
        if any? patients with [current-disease-status = "resistant"][
          let patient-count count patients with [current-disease-status = "resistant"] ;this is to keep track of how many patients are getting discharged
          set number-discharges number-discharges + patient-count ;add to total count
          ask patients with [current-disease-status = "resistant"] [die]
          clean-at-discharge
        ]
      ]
    ]
    if current-disease-status = "susceptible"[
        if random-num < 0.15[
          if any? patients with [current-disease-status = "susceptible"][
            let patient-count count patients with [current-disease-status = "susceptible"] ;this is to keep track of how many patients are getting discharged
            set number-discharges number-discharges + patient-count
            ask patients with [current-disease-status = "susceptible"] [die]
            clean-at-discharge
        ]
      ]
    ]
    if current-disease-status = "colonized"[
      if random-num < 0.15[
        if any? patients with [current-disease-status = "colonized"][
          let patient-count count patients with [current-disease-status = "colonized"] ;this is to keep track of how many patients are getting discharged
          set number-discharges number-discharges + patient-count
          ask patients with [current-disease-status = "colonized"] [die]
          clean-at-discharge
        ]
      ]
    ]
    if current-disease-status = "diseased"[
      if random-num < 0.068[
          if any? patients with [current-disease-status = "diseased"][
            let patient-count count patients with [current-disease-status = "diseased"] ;this is to keep track of how many patients are getting discharged
            set number-discharges number-discharges + patient-count
            ask patients with [current-disease-status = "diseased"] [die]
            clean-at-discharge
        ]
      ]
    ]
  ]
end

;admit patients if there is an empty room
to admit-patients
  let R-chance .75 ;percentage for resistant
  let S-chance .09 ;susceptible
  let C-chance .15 ;colonized
  let D-chance .01 ;diseased
  let n 0
  let empty-rooms count patients-patch with [not any? patients-here]

  while [n < empty-rooms][
    let random-num random-float 1
    if random-num < D-chance[ ;diseased
      create-patients 1[
        set size .75
        set shape "person"
        set current-disease-status "diseased"
        set color violet
        set time-since-current-disease-status 0
        move-to one-of patients-patch with [not any? patients-here]
      ]
    ]
    if random-num < S-chance[ ;susceptible
      create-patients 1[
        set size .75
        set shape "person"
        set current-disease-status "susceptible"
        set color brown
        set time-since-current-disease-status 0
        move-to one-of patients-patch with [not any? patients-here]
      ]
    ]
    if random-num < C-chance[ ;colonized
      create-patients 1[
        set size .75
        set shape "person"
        set current-disease-status "colonized"
        set color blue
        set time-since-current-disease-status 0
        move-to one-of patients-patch with [not any? patients-here]
      ]
    ]
    if random-num < R-chance[ ;resistant
      create-patients 1[
        set size .75
        set shape "person"
        set current-disease-status "resistant"
        set color green
        set time-since-current-disease-status 0
        move-to one-of patients-patch with [not any? patients-here]
      ]
    ]
    ;need another block here for a chance the number is greater than .75
    set n n + 1
  ]
  set n 0
end

;cleaning sub-model at discharge. called within discharge-patients submodel
to clean-at-discharge
  let sigma .83 ;proportion of high-touch and low-touch spores killed due to disinfection upon discharge

  ;ask surfaces to be cleaned at discharge
  ask patch-at-heading-and-distance 90 1 [ ;high touch
    set active-high-touch-level (active-high-touch-level - (active-high-touch-level * sigma))
  ]
  ask patch-at-heading-and-distance 135 1[ ;low touch
    set active-low-touch-level (active-low-touch-level - (active-low-touch-level * sigma))
  ]
end












@#$#@#$#@
GRAPHICS-WINDOW
229
10
445
266
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-8
7
-9
9
1
1
1
ticks
30.0

BUTTON
5
28
68
61
setup
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

SLIDER
9
90
195
123
high-touch-contam-level
high-touch-contam-level
0
0.1
0.07
0.01
1
NIL
HORIZONTAL

SLIDER
9
125
198
158
low-touch-contam-level
low-touch-contam-level
0
.1
0.02
.01
1
NIL
HORIZONTAL

BUTTON
70
28
133
61
go
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

BUTTON
135
28
220
61
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
159
181
192
prob-succ-treat
prob-succ-treat
0
1
0.7
.05
1
NIL
HORIZONTAL

SLIDER
9
195
181
228
sensitivity
sensitivity
0
1
0.5
.05
1
NIL
HORIZONTAL

MONITOR
9
232
165
277
number-of-discharges
number-discharges
17
1
11

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
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
