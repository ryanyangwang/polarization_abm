; =============================================================================
; AGENT-BASED MODEL FOR STRONG/MINIMAL SOCIAL/MEDIA INFLUENCE (CALIBRATED VERSION)
; =============================================================================
;
; TITLE: Social and Media Influence on Political Polarization
;
; PURPOSE: This model explores the emergence of political polarization through:
;   - Social influence among neighboring agents
;   - Media influence from ideologically varied news sources
;   - Selective exposure to attitude-congruent information
;   - Homophily in the selection of discussion partners
;
; MAIN VARIABLES:
;   - global-social-influence: Strength of neighbor-to-neighbor influence (0-1)
;   - global-media-influence: Strength of media-to-agent influence (0-1)
;   - global-selective-exposure: Preference for ideologically aligned media (0-1)
;   - global-homogenous-discussion: Preference for similar discussion partners (0-1)
;
; OUTCOME MEASURES:
;   - Affective polarization
;   - Ideology distribution and variance
;   - Social and media diversity indices
; =============================================================================

extensions [ rnd csv ]

; =============================================================================
; GLOBAL VARIABLES
; =============================================================================
globals [
  ; PRIMARY OUTCOME MEASURES
  mean-affective                  ; Mean affective polarization
  sd-affective                    ; Standard deviation of affective polarization
  mean-affective-dem              ; Mean affective polarization for Democrats
  mean-affective-rep              ; Mean affective polarization for Republicans
  mean-affective-ind              ; Mean affective polarization for Independents
  mean-ideology                   ; Population mean ideology (1-5 scale)
  sd-ideology                     ; Standard deviation of ideology
  mean-agent-diversity            ; Mean diversity of social interactions
  mean-agent-diversity-dem        ; Social diversity for Democrats
  mean-agent-diversity-rep        ; Social diversity for Republicans
  mean-agent-diversity-ind        ; Social diversity for Independents
  mean-media-diversity            ; Mean diversity of media consumption
  mean-media-diversity-dem        ; Media diversity for Democrats
  mean-media-diversity-rep        ; Media diversity for Republicans
  mean-media-diversity-ind        ; Media diversity for Independents
  happy-percent                   ; Percentage of satisfied agents
]

; =============================================================================
; AGENT DEFINITIONS
; =============================================================================

; HUMAN AGENTS: Individuals with political attitudes and behaviors
breed [humans human]
humans-own [
  ; CORE POLITICAL ATTRIBUTES
  party                          ; "dem" or "rep"
  ideology                       ; 1-5: Liberal to conservative scale
  affective-polarization         ; 0-10: Emotional polarization toward out-party

  ; INDIVIDUAL SUSCEPTIBILITY PARAMETERS (vary around global means)
  soc-influ                      ; 0-1: Individual social influence susceptibility
  sel-exp                        ; 0-1: Individual selective exposure tendency
  hom-disc                       ; 0-1: Individual homophily in discussions

  ; BEHAVIORAL FREQUENCIES
  news-freq                      ; Number of media sources consumed per tick
  dis-freq                       ; Number of neighbors considered for interaction

  ; SATISFACTION AND MOBILITY
  happy?                         ; Boolean: Is agent satisfied with environment?
  unhappy-ticks                  ; Consecutive ticks of dissatisfaction
  ticks-since-last-move          ; Cooldown timer for relocation
  mood-streak                    ; Streak counter for happiness transitions

  ; INTERACTION TRACKING (reset each tick)
  interacted-partners-this-tick  ; List of social partners this tick
  consumed-media-this-tick       ; List of media consumed this tick
]

; MEDIA AGENTS: News sources and information outlets
breed [media medium]
media-own [
  media-type                     ; "liberal", "moderate", "conservative"
  media-ideology                 ; 1-5: Ideological position of outlet
  media-influ                    ; 0-1: Individual influence strength
  tmpProb                        ; Temporary probability for weighted sampling
]


; =============================================================================
; INITIALIZATION PROCEDURES
; =============================================================================

to setup
  clear-all
  ifelse validation? [
    setup-humans-from-csv
  ] [
    setup-humans
  ]
  setup-media

  ; Initialize interaction tracking for all agents
  ask humans [
    set interacted-partners-this-tick []
    set consumed-media-this-tick []
    update-comfort
  ]
  update-globals
  reset-ticks
end


; =============================================================================
; IMPORT VALIDATION DATA
; =============================================================================


to setup-humans-from-csv
  clear-turtles  ;; optional: just removes old agents, not patches

  let raw-data csv:from-file "calibration.csv"
  let data but-first raw-data

  foreach data [
    row ->

    let pid         item 0 row
    let p_party     item 1 row
    let p_ideology  item 2 row
    let p_newsfreq  item 3 row
    let p_disfreq   item 4 row
    let p_ap        item 5 row

    create-humans 1 [
      let target-patch one-of patches with [ not any? turtles-here ]
      if target-patch = nobody [ stop ]
      move-to target-patch

      ;; Set appearance
      set shape "person"
      set size 1

      ;; Party + color
      set party p_party
      if p_party = "dem" [ set color blue ]
      if p_party = "rep" [ set color red ]
      if p_party = "ind" [ set color gray ]

      ;; Key political vars
      set ideology max list 1 min list 5 p_ideology
      set affective-polarization max list 0 min list 10 p_ap

      ;; Frequency values
      set news-freq p_newsfreq
      set dis-freq  p_disfreq

      ;; Initialize others randomly or as fixed
      set sel-exp bound01 (global-selective-exposure + random-normal 0 0.1)
      set soc-influ bound01 (global-social-influence + random-normal 0 0.1)
      set hom-disc bound01 (global-homogenous-discussion + random-normal 0 0.1)

      set happy? false
      set mood-streak 0
      set ticks-since-last-move 0
    ]
  ]

end


; CREATE AND INITIALIZE HUMAN AGENTS
to setup-humans
  let num-humans round (count patches * population-density / 100)

  ; Validate density constraints
  if num-humans + (round (count patches * media-density / 100)) > count patches [
    user-message "Error: Combined population and media density exceeds 100%."
    stop
  ]

  create-humans num-humans [
    ; Place agent on empty patch
    let target-patch one-of patches with [ not any? turtles-here ]
    if target-patch = nobody [
      user-message (word "Error: Could not find empty patch for human " who)
      stop
    ]
    move-to target-patch

    ; Set visual properties
    set shape "person"
    set size 1

    ; Assign party affiliation and color
    let r random-float 100

    if r < independent% [
      set party "ind"
      set color gray
      set ideology min list 3.5 max list 2.5 (random-normal 3 0.3)
    ]

    if (r >= independent%) and (r < independent% + ((100 - independent%) / 2)) [
      set party "dem"
      set color blue
      set ideology min list 2 max list 1 (random-normal 1.5 0.3)
    ]

    if r >= independent% + ((100 - independent%) / 2) [
      set party "rep"
      set color red
      set ideology min list 5 max list 4 (random-normal 4.5 0.3)
    ]

    ; Initialize individual susceptibility parameters with variation around global means
    let σ 0.1  ; Standard deviation for individual differences
    set soc-influ bound01 (global-social-influence + random-normal 0 σ)
    set sel-exp bound01 (global-selective-exposure + random-normal 0 σ)
    set hom-disc bound01 (global-homogenous-discussion + random-normal 0 σ)

    ; Initialize political attitudes
    set affective-polarization (random-float 10.0)
    set ideology max list 1 min list 5 (random-normal 2.5 0.8)  ; Centered distribution

    ; Set behavioral frequencies
    set news-freq (1 + random 5)
    set dis-freq (1 + random 5)

    ; Initialize state variables
    set ticks-since-last-move 0
    set mood-streak 0
    set happy? false
  ]
end

; CREATE AND INITIALIZE MEDIA OUTLETS
to setup-media
  let num-media round (count patches * media-density / 100)

  create-media num-media [
    ; Place media outlet on empty patch
    let target-patch one-of patches with [ not any? turtles-here ]
    if target-patch = nobody [
      user-message (word "Error: Could not find empty patch for media " who)
      stop
    ]
    move-to target-patch

    ; Set visual properties
    set shape "house"
    set size 1

    ; Assign media type and ideology (40% liberal, 20% moderate, 40% conservative)
    let r random-float 100
    ifelse r < 40 [
      set media-type "liberal"
      set color blue - 2
      set media-ideology (1.0 + random-float 1.0)  ; 1-2 range
    ] [ ifelse r < 60 [
        set media-type "moderate"
        set color gray - 1
        set media-ideology (2.5 + random-float 1.0)  ; 2.5-3.5 range
      ] [
        set media-type "conservative"
        set color red - 2
        set media-ideology (4.0 + random-float 1.0)  ; 4-5 range
      ]
    ]

    ; Set individual influence strength with variation around global mean
    let σ 0.1
    set media-influ bound01 (global-media-influence + random-normal 0 σ)
  ]
end

; =============================================================================
; MAIN SIMULATION LOOP
; =============================================================================

to go
  if ticks >= max-ticks [ stop ]

  ; Process all human agents
  ask humans [
    agent-media-interaction        ; Media consumption and social interaction
    update-comfort                 ; Calculate satisfaction with environment
    set ticks-since-last-move (ticks-since-last-move + 1)

    ; Apply affective polarization decay
    set affective-polarization (affective-polarization * (1 - ap-decay-rate))
  ]

  update-globals                   ; Calculate population-level measures
  move-unhappy-humans              ; Relocate dissatisfied agents
  tick
end

; =============================================================================
; PARTNER AND MEDIA SELECTION ALGORITHMS
; =============================================================================

; SELECT MEDIA SOURCES BASED ON SELECTIVE EXPOSURE PREFERENCES
; Uses exponential weighting to favor ideologically similar sources
to-report human-selects-media-sources
  let μ ideology
  let ap affective-polarization / 10
  let β beta-media-bias * sel-exp * (1 + ap)

  ; Calculate ideological window based on selective exposure and affective polarization
  let base-max (4 * (1 - sel-exp))
  let max-diff max list 0 (base-max - (ap * consumption-modifier))

  ; Create candidate pool within ideological window
  let pool media with [abs (media-ideology - μ) <= max-diff]
  if not any? pool [ set pool media ]  ; Fallback to all media if none qualify

  ; Assign exponential weights based on ideological distance
  ask pool [
    let d abs(media-ideology - μ)
    set tmpProb exp(- β * d)
  ]

  ; Handle numerical underflow
  let Z sum [tmpProb] of pool
  if Z <= 0 [
    ask pool [ set tmpProb 1 ]
    set Z sum [tmpProb] of pool
  ]

  ; Normalize probabilities
  ask pool [ set tmpProb tmpProb / Z ]

  ; Perform weighted sampling
  let n-consume min list news-freq count pool
  let chosen rnd:weighted-n-of n-consume pool [tmpProb]

  report turtle-set chosen
end

; SELECT SOCIAL PARTNERS BASED ON HOMOPHILY PREFERENCES
; Uses same exponential weighting logic as media selection
to-report human-selects-social-partners
  let μ ideology
  let ap affective-polarization / 10
  let β hom-disc * discussion-modifier * (1 + ap)

  ; Get nearby humans (use 2x buffer for selection pool)
  let potential-candidates-list []
  if dis-freq > 0 and any? other humans [
    let sorted-other-humans sort-on [distance myself] (other humans)
    ifelse length sorted-other-humans > dis-freq * 2 [
      set potential-candidates-list (sublist sorted-other-humans 0 (dis-freq * 2))
    ] [
      set potential-candidates-list sorted-other-humans
    ]
  ]
  if empty? potential-candidates-list [ report no-turtles ]

  ; Calculate exponential weights based on ideological distance
  let scored-candidates []
  foreach potential-candidates-list [ candidate ->
    let d abs([ideology] of candidate - μ)
    let w exp(- β * d)
    set scored-candidates lput (list candidate w) scored-candidates
  ]

  ; Normalize weights
  let total-weight sum map [pair -> item 1 pair] scored-candidates
  if total-weight <= 0 [ report no-turtles ]

  let normed-candidates map [pair ->
    list (item 0 pair) (item 1 pair / total-weight)
  ] scored-candidates

  ; Build cumulative distribution for sampling
  let cumsum 0
  let cumulative-list []
  foreach normed-candidates [pair ->
    let agent item 0 pair
    let weight item 1 pair
    set cumsum cumsum + weight
    set cumulative-list lput (list agent cumsum) cumulative-list
  ]

  ; Sample agents using cumulative distribution
  let chosen-agents []
  repeat dis-freq [
    let r random-float 1
    let match first filter [pair -> item 1 pair >= r] cumulative-list
    if not member? (item 0 match) chosen-agents [
      set chosen-agents lput (item 0 match) chosen-agents
    ]
  ]

  report turtle-set chosen-agents
end

; =============================================================================
; INFLUENCE MECHANISMS
; =============================================================================

; MAIN INTERACTION PROCEDURE FOR EACH AGENT PER TICK
to agent-media-interaction
  set interacted-partners-this-tick []
  set consumed-media-this-tick []
  let original-human self

  ; PHASE 1: MEDIA CONSUMPTION
  let chosen-media-sources-agentset [human-selects-media-sources] of original-human
  if any? chosen-media-sources-agentset [
    ask chosen-media-sources-agentset [
      let current-media-outlet self
      ask original-human [
        human-is-influenced-by-media self current-media-outlet
        set consumed-media-this-tick lput current-media-outlet consumed-media-this-tick
      ]
    ]
  ]

  ; PHASE 2: SOCIAL INTERACTION
  let chosen-social-partners-agentset [human-selects-social-partners] of original-human
  if any? chosen-social-partners-agentset [
    ask chosen-social-partners-agentset [
      let current-partner self
      ask original-human [
        human-is-influenced-by-social-partner self current-partner
        set interacted-partners-this-tick lput current-partner interacted-partners-this-tick
      ]
    ]
  ]

  ; Ensure values remain within valid bounds
  set ideology max (list 1.0 (min (list 5.0 ideology)))
  set affective-polarization max (list 0.0 (min (list 10.0 affective-polarization)))
end

; PROCESS MEDIA INFLUENCE ON HUMAN AGENT
; Includes backfire effects and affective polarization dynamics
to human-is-influenced-by-media [consumer media-outlet]
  ask consumer [
    let ideology-before-consumption ideology
    let current-AP-scaled (affective-polarization / 10.0)
    let outlet-ideology [media-ideology] of media-outlet
    let outlet-inherent-strength [media-influ] of media-outlet
    let initial-diff-media (outlet-ideology - ideology-before-consumption)
    let ideological-disagreement abs(initial-diff-media)
    let normalized-disagreement (ideological-disagreement / 4.0)
    let direction-multiplier 1
    let midpoint 3.0

    ; Determine political sides and extremity for backfire effect
    let agent-extreme? (ideology-before-consumption <= 2 or ideology-before-consumption >= 4)
    let source-extreme? (outlet-ideology <= 2 or outlet-ideology >= 4)

    let agent-side 0
    if ideology-before-consumption < 3.0 [ set agent-side -1 ]
    if ideology-before-consumption > 3.0 [ set agent-side 1 ]

    let source-side 0
    if outlet-ideology < 3.0 [ set source-side -1 ]
    if outlet-ideology > 3.0 [ set source-side 1 ]

    let prob-of-backfire 0.0
    if (agent-extreme? and source-extreme? and agent-side != 0 and source-side != 0 and agent-side != source-side) [
      set prob-of-backfire p-backfire-when-incongruent
    ]

    if random-float 1.0 < prob-of-backfire [
      set direction-multiplier -1
    ]

    ; Calculate media receptivity (reduced by AP when disagreement is high)
    let media-receptivity-due-to-AP 1.0
    if normalized-disagreement > 0.05 [
      set media-receptivity-due-to-AP (1.0 - (current-AP-scaled * normalized-disagreement * 0.5))
      set media-receptivity-due-to-AP max (list 0.0 media-receptivity-due-to-AP)
    ]

    ; UPDATE IDEOLOGY
    let learning-component (global-media-influence * outlet-inherent-strength * media-receptivity-due-to-AP * initial-diff-media)
    set ideology (ideology + (direction-multiplier * learning-component))

    ; UPDATE AFFECTIVE POLARIZATION
    ifelse (direction-multiplier = -1 and ideological-disagreement > 0.05) [
      ; backfire effect increases AP
      set affective-polarization (affective-polarization + disagreement-penalty * backfire-amp)
    ] [
      ; Standard AP update based on interaction type
      let ideological-distance-factor (ideological-disagreement / 4.0)
      let ap-amplifier (1 + (affective-polarization / 10.0))

      ifelse (ideological-disagreement <= like-minded-threshold) [
        ; Like-minded media reinforcement
        let like-minded-effect (like-minded-ap-boost * (1 - ideological-distance-factor) * ap-amplifier)
        set affective-polarization (affective-polarization + like-minded-effect)
      ] [
        ifelse (ideological-disagreement > disagreement-threshold) [
          ; Highly disagreeable media increases AP
          set affective-polarization (affective-polarization + disagreement-penalty)
        ] [
          ; Cross-cutting media may reduce AP
          if (ideological-disagreement > cross-cutting-threshold AND ideological-disagreement <= disagreement-threshold) [
            let optimal-distance 0.5
            let cross-cutting-effectiveness (1 - abs(ideological-distance-factor - optimal-distance))
            let cross-cutting-effect (cross-cutting-ap-reduction * cross-cutting-effectiveness * ap-amplifier)
            set affective-polarization (affective-polarization - cross-cutting-effect)
          ]
        ]
      ]
    ]
  ]
end

; PROCESS SOCIAL INFLUENCE FROM DISCUSSION PARTNER
; Uses identical logic to media influence for consistency
to human-is-influenced-by-social-partner [agent1 social-partner]
  ask agent1 [
    let ideology-before-interaction ideology
    let current-AP-scaled (affective-polarization / 10.0)
    let partner-ideology [ideology] of social-partner
    let initial-diff-social (partner-ideology - ideology-before-interaction)
    let ideological-disagreement abs(initial-diff-social)
    let normalized-disagreement (ideological-disagreement / 4.0)
    let direction-multiplier 1
    let midpoint 3.0

    ; Determine political sides and extremity for backfire effect
    let agent-extreme? (ideology-before-interaction <= 2 or ideology-before-interaction >= 4)
    let source-extreme? ([ideology] of social-partner <= 2 or [ideology] of social-partner >= 4)

    let agent-side 0
    if ideology-before-interaction < 3.0 [ set agent-side -1 ]
    if ideology-before-interaction > 3.0 [ set agent-side 1 ]

    let source-side 0
    if [ideology] of social-partner < 3.0 [ set source-side -1 ]
    if [ideology] of social-partner > 3.0 [ set source-side 1 ]

    let prob-of-backfire 0.0
    if (agent-extreme? and source-extreme? and agent-side != 0 and source-side != 0 and agent-side != source-side) [
      set prob-of-backfire p-backfire-when-incongruent
    ]

    if random-float 1.0 < prob-of-backfire [
      set direction-multiplier -1
    ]
    ; Calculate social receptivity (reduced by AP when disagreement is high)
    let social-receptivity-due-to-AP 1.0
    if normalized-disagreement > 0.05 [
      set social-receptivity-due-to-AP (1.0 - (current-AP-scaled * normalized-disagreement))
      set social-receptivity-due-to-AP max (list 0.0 social-receptivity-due-to-AP)
    ]

    ; UPDATE IDEOLOGY
    let learning-component (soc-influ * social-receptivity-due-to-AP * initial-diff-social)
    set ideology (ideology + (direction-multiplier * learning-component))

    ; UPDATE AFFECTIVE POLARIZATION (same logic as media influence)
    ifelse (direction-multiplier = -1 and ideological-disagreement > 0.05) [
      set affective-polarization (affective-polarization + disagreement-penalty * backfire-amp)
    ] [
      let ideological-distance-factor (ideological-disagreement / 4.0)
      let ap-amplifier (1 + (affective-polarization / 10.0))

      ifelse (ideological-disagreement <= like-minded-threshold) [
        let like-minded-effect (like-minded-ap-boost * (1 - ideological-distance-factor) * ap-amplifier)
        set affective-polarization (affective-polarization + like-minded-effect)
      ] [
        ifelse (ideological-disagreement > disagreement-threshold) [
          set affective-polarization (affective-polarization + disagreement-penalty)
        ] [
          if (ideological-disagreement > cross-cutting-threshold AND ideological-disagreement <= disagreement-threshold) [
            let optimal-distance 0.5
            let cross-cutting-effectiveness (1 - abs(ideological-distance-factor - optimal-distance))
            let cross-cutting-effect (cross-cutting-ap-reduction * cross-cutting-effectiveness * ap-amplifier)
            set affective-polarization (affective-polarization - cross-cutting-effect)
          ]
        ]
      ]
    ]
  ]
end

; =============================================================================
; AGENT SATISFACTION AND SPATIAL DYNAMICS
; =============================================================================

; CALCULATE AGENT SATISFACTION WITH CURRENT ENVIRONMENT
; Based on ideological alignment of social and media interactions
to update-comfort
  let agent-ideology ideology
  let agent-AP affective-polarization

  ; Calculate social comfort from recent interactions
  let total-interacted-partners length interacted-partners-this-tick
  let sum-social-similarity 0
  if total-interacted-partners > 0 [
    foreach interacted-partners-this-tick [partner ->
      let diff abs (agent-ideology - [ideology] of partner)
      set sum-social-similarity (sum-social-similarity + (1 - (diff / 4.0)))
    ]
  ]
  let social-comfort-metric ifelse-value (total-interacted-partners > 0)
                            [sum-social-similarity / total-interacted-partners] [0]

  ; Calculate media comfort from recent consumption
  let total-consumed-media length consumed-media-this-tick
  let sum-media-similarity 0
  if total-consumed-media > 0 [
    foreach consumed-media-this-tick [media-item ->
      let diff abs (agent-ideology - [media-ideology] of media-item)
      set sum-media-similarity (sum-media-similarity + (1 - (diff / 4.0)))
    ]
  ]
  let media-comfort-metric ifelse-value (total-consumed-media > 0)
                           [sum-media-similarity / total-consumed-media] [0]

  ; Calculate overall comfort and tolerance levels
  let current-comfort-index ((social-comfort-metric + media-comfort-metric) / 2)
  set current-comfort-index (current-comfort-index - baseline-stress)
  let current-tolerance (1 / (1 + exp (agent-AP - 5)))
  set current-tolerance max (list 0.001 current-tolerance)

  ; Determine probability of unhappiness
  let prob-to-be-unhappy 0.0
  if current-comfort-index < current-tolerance [
    set prob-to-be-unhappy ((current-tolerance - current-comfort-index) / current-tolerance)
  ]
  set prob-to-be-unhappy max (list 0.0 (min (list 1.0 prob-to-be-unhappy)))

  ; Update happiness with hysteresis to prevent rapid mood swings
  let flip-threshold 1
  let unhappy-draw? (random-float 1.0 < prob-to-be-unhappy)

  ifelse happy? [
    ifelse unhappy-draw? [
      set mood-streak (mood-streak + 1)
      if mood-streak >= flip-threshold [
        set happy? false
        set mood-streak 0
      ]
    ] [
      set mood-streak 0
    ]
  ] [
    ifelse not unhappy-draw? [
      set mood-streak (mood-streak + 1)
      if mood-streak >= flip-threshold [
        set happy? true
        set mood-streak 0
      ]
    ] [
      set mood-streak 0
    ]
  ]

  ; Update unhappiness streak counter
  ifelse happy? [
    set unhappy-ticks 0
  ] [
    set unhappy-ticks (unhappy-ticks + 1)
  ]
end

; RELOCATE UNHAPPY AGENTS TO MORE COMPATIBLE ENVIRONMENTS
to move-unhappy-humans
  let movers humans with [ (not happy?) and ticks-since-last-move >= 2 ]

  ask movers [
    let R search-radius
    let candidates patches in-radius R with [ not any? turtles-here ]

    if any? candidates [
      ; Score patches based on social and media compatibility
      let best max-one-of candidates [
        (social-comfort-weight * (agent-sim-here myself)) +
        ((1 - social-comfort-weight) * (media-sim-here myself))
      ]
      move-to best
      set ticks-since-last-move 0
      set unhappy-ticks 0
    ]
  ]


end

; =============================================================================
; MEASUREMENT AND ANALYSIS FUNCTIONS
; =============================================================================

; CALCULATE SIMILARITY BETWEEN TWO IDEOLOGY VALUES
to-report sim [x y]
  report 1 - (abs (x - y) / 4)
end

; AVERAGE IDEOLOGICAL SIMILARITY TO HUMANS IN NEIGHBORHOOD
to-report agent-sim-here [seeker]
  let nb humans-on neighbors4
  ifelse any? nb [
    let focal [ideology] of seeker
    report mean [ sim focal ideology ] of nb
  ] [
    report 0
  ]
end

; AVERAGE IDEOLOGICAL SIMILARITY TO MEDIA IN NEIGHBORHOOD
to-report media-sim-here [seeker]
  let nb media-on neighbors4
  ifelse any? nb [
    let focal [ideology] of seeker
    report mean [ sim focal media-ideology ] of nb
  ] [
    report 0
  ]
end

; =============================================================================
; OUTCOME MEASUREMENT PROCEDURES
; =============================================================================

; UPDATE ALL POPULATION-LEVEL OUTCOME MEASURES
to update-globals
  ; Affective polarization
  set mean-affective mean [affective-polarization] of humans
  set sd-affective standard-deviation [affective-polarization] of humans
  set mean-affective-dem mean [affective-polarization] of humans with [ party = "dem" ]
  set mean-affective-rep mean [affective-polarization] of humans with [ party = "rep" ]
  set mean-affective-ind mean [affective-polarization] of humans with [ party = "ind" ]


  ; Population ideology statistics
  set mean-ideology mean [ideology] of humans
  set sd-ideology standard-deviation [ideology] of humans

  ; Agent diversity indices
  let avals map [h -> agent-diversity-index h] sort humans
  set mean-agent-diversity mean avals

  let dem-adivs map [h -> agent-diversity-index h] sort humans with [party = "dem"]
  let rep-adivs map [h -> agent-diversity-index h] sort humans with [party = "rep"]
  let ind-adivs map [h -> agent-diversity-index h] sort humans with [party = "ind"]
  set mean-agent-diversity-dem mean dem-adivs
  set mean-agent-diversity-rep mean rep-adivs
  set mean-agent-diversity-ind mean ind-adivs

  ; Media diversity indices
  let mvals map [h -> media-diversity-index h] sort humans
  set mean-media-diversity mean mvals

  let dem-mdivs map [h -> media-diversity-index h] sort humans with [party = "dem"]
  let rep-mdivs map [h -> media-diversity-index h] sort humans with [party = "rep"]
  let ind-mdivs map [h -> media-diversity-index h] sort humans with [party = "ind"]
  set mean-media-diversity-dem mean dem-mdivs
  set mean-media-diversity-rep mean rep-mdivs
  set mean-media-diversity-ind mean ind-mdivs

  ; Agent satisfaction measure
  set happy-percent (100 * count humans with [happy? = true]) / (count humans)
end

; BIN CONTINUOUS IDEOLOGY INTO DISCRETE CATEGORIES FOR DIVERSITY CALCULATION
to-report binned-ideology [raw]
  report max list 1 min list 5 round raw
end

; CALCULATE SHANNON DIVERSITY INDEX FOR SOCIAL INTERACTIONS
; Measures ideological diversity of discussion partners
to-report agent-diversity-index [a-human]
  let partner-list [interacted-partners-this-tick] of a-human
  if not is-list? partner-list or empty? partner-list [ report 0 ]

  let ideo-bins map [p -> binned-ideology [ideology] of p] partner-list
  let categories [1 2 3 4 5]
  let total length ideo-bins
  let counts map [c -> length filter [x -> x = c] ideo-bins] categories
  let probs map [n -> n / total] counts

  let H 0
  foreach probs [p ->
    if p > 0 [ set H (H - (p * ln p)) ]
  ]
  report H / ln 5  ; Normalize to 0-1 scale
end

; CALCULATE SHANNON DIVERSITY INDEX FOR MEDIA CONSUMPTION
; Measures ideological diversity of consumed media sources
to-report media-diversity-index [a-human]
  let media-list [consumed-media-this-tick] of a-human
  if not is-list? media-list or empty? media-list [ report 0 ]

  let ideo-list map [m -> binned-ideology [media-ideology] of m] media-list
  let bins [1 2 3 4 5]
  let total length ideo-list
  let counts map [b -> length filter [x -> x = b] ideo-list] bins
  let probs map [c -> c / total] counts

  let H 0
  foreach probs [p ->
    if p > 0 [ set H (H - (p * ln p)) ]
  ]
  report H / ln 5  ; Normalize to 0-1 scale
end

; UTILITY FUNCTION: BOUND VALUES BETWEEN 0 AND 1
to-report bound01 [x]
  report max list 0 min list 1 x
end
@#$#@#$#@
GRAPHICS-WINDOW
275
10
713
449
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-21
21
-21
21
0
0
1
ticks
30.0

PLOT
720
10
920
135
Percent Happy
time
%
0.0
25.0
0.0
100.0
true
false
"" ""
PENS
"Happy%" 1.0 0 -16777216 true "" "plot happy-percent"

BUTTON
15
10
105
43
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

BUTTON
105
10
185
43
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
0

SLIDER
15
390
265
423
global-homogenous-discussion
global-homogenous-discussion
0
1
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
15
355
265
388
global-selective-exposure
global-selective-exposure
0
1
0.9
0.05
1
NIL
HORIZONTAL

MONITOR
15
210
135
255
Democrats
count humans with [shape = \"person\" and color = blue]
17
1
11

PLOT
920
10
1120
135
Affective polarization
time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"general" 1.0 0 -16777216 true "" "plot mean-affective"
"democrats" 1.0 0 -13345367 true "" "plot mean-affective-dem"
"republicans" 1.0 0 -2674135 true "" "plot mean-affective-rep"
"independent" 1.0 0 -7500403 true "" "plot mean-affective-ind"

BUTTON
185
10
265
43
NIL
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

MONITOR
135
210
265
255
Liberal media
count media
17
1
11

MONITOR
865
10
920
55
Happy%
( 100.0 * count humans with [ happy? ]) / count humans
2
1
11

MONITOR
1070
10
1120
55
Mean
mean [affective-polarization] of humans
2
1
11

SLIDER
15
105
265
138
population-density
population-density
0
100
40.0
1
1
%
HORIZONTAL

SLIDER
15
140
265
173
independent%
independent%
1
100
20.0
1
1
%
HORIZONTAL

SLIDER
15
175
265
208
media-density
media-density
0
100
30.0
1
1
%
HORIZONTAL

PLOT
720
135
1120
260
Agent Diversity index
NIL
NIL
0.0
10.0
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot mean-agent-diversity"
"pen-1" 1.0 0 -14070903 true "" "plot mean-agent-diversity-dem"
"pen-2" 1.0 0 -5298144 true "" "plot mean-agent-diversity-rep"
"pen-3" 1.0 0 -7500403 true "" "plot mean-agent-diversity-ind"

PLOT
720
260
1120
385
Media consumption index
NIL
NIL
0.0
10.0
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 0 -10141563 true "" "plot mean-media-diversity"
"pen-1" 1.0 0 -14070903 true "" "plot mean-media-diversity-dem"
"pen-2" 1.0 0 -5298144 true "" "plot mean-media-diversity-rep"
"pen-3" 1.0 0 -7500403 true "" "plot mean-media-diversity-ind"

MONITOR
1070
135
1120
180
Mean
mean-agent-diversity
2
1
11

MONITOR
1065
260
1120
305
Mean
mean-media-diversity
2
1
11

SLIDER
505
475
715
508
p-backfire-when-incongruent
p-backfire-when-incongruent
0
1
0.3
0.01
1
NIL
HORIZONTAL

PLOT
720
385
920
510
Human ideology
Ideology
Count
0.0
5.0
0.0
10.0
true
true
"" ""
PENS
"Reps" 1.0 1 -5298144 true "" "plot-pen-reset\n\nlet rep-counts map [ideology-bin-value ->\n                   count humans with [party = \"rep\" and floor ideology = ideology-bin-value]\n                 ] (range 1 6 1)\nlet x-category 1\nlet x-offset 0.15\n\nforeach rep-counts [current-bin-count ->\n  plotxy (x-category + x-offset) current-bin-count\n  set x-category x-category + 1\n]"
"Dems" 1.0 1 -14070903 true "" "\nplot-pen-reset\n\nlet dem-counts map [ideology-bin-value ->\n                    count humans with [party = \"dem\" and floor ideology = ideology-bin-value]\n                  ] (range 1 6 1) ;; (range 1 6 1) creates the list [1 2 3 4 5]\n\nlet x-category 1\nlet x-offset -0.15  \n\nforeach dem-counts [current-bin-count ->\n  plotxy (x-category + x-offset) current-bin-count\n  set x-category x-category + 1\n]"
"Inds" 1.0 1 -7500403 true "" "plot-pen-reset\n\nlet ind-counts map [ideology-bin-value ->\n                    count humans with [party = \"ind\" and floor ideology = ideology-bin-value]\n                  ] (range 1 6 1)\n\n;; Plot each bar slightly to the CENTER of the x-value for its category\nlet x-category 1\nlet x-offset 0  \nforeach ind-counts [current-bin-count ->\n  plotxy (x-category + x-offset) current-bin-count\n  set x-category x-category + 2\n]"

PLOT
920
385
1120
510
Media ideology
Ideology
Count
0.0
5.0
0.0
10.0
true
false
"" ";; Clear previous bars for this pen only for this tick's redraw\nplot-pen-reset\n\n;; Calculate counts for each ideology bin (1 through 5)\nlet counts map [ideology-bin-value ->\n                 count media with [floor media-ideology = ideology-bin-value]\n               ] (range 1 6 1)\n\n;; Plot each bar\nlet x-value 1\nforeach counts [current-bin-count ->\n  plotxy x-value current-bin-count\n  set x-value x-value + 1\n]"
PENS
"default" 1.0 1 -16777216 true "" ""

SLIDER
15
285
265
318
global-media-influence
global-media-influence
0
1
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
15
320
265
353
global-social-influence
global-social-influence
0
1
0.9
0.05
1
NIL
HORIZONTAL

SLIDER
20
450
265
483
discussion-modifier
discussion-modifier
0
5
2.0
0.25
1
NIL
HORIZONTAL

SLIDER
20
485
265
518
consumption-modifier
consumption-modifier
0
5
2.0
0.25
1
NIL
HORIZONTAL

SLIDER
275
475
500
508
disagreement-threshold
disagreement-threshold
0
4
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
275
510
500
543
disagreement-penalty
disagreement-penalty
0
2
0.4
0.05
1
NIL
HORIZONTAL

SLIDER
275
545
500
578
like-minded-threshold
like-minded-threshold
0
4
0.3
0.05
1
NIL
HORIZONTAL

SLIDER
15
45
155
78
max-ticks
max-ticks
50
1000
100.0
10
1
NIL
HORIZONTAL

SLIDER
275
580
500
613
like-minded-ap-boost
like-minded-ap-boost
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
275
615
500
648
cross-cutting-threshold
cross-cutting-threshold
0
4
0.3
0.05
1
NIL
HORIZONTAL

SLIDER
275
650
500
683
cross-cutting-ap-reduction
cross-cutting-ap-reduction
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
20
615
265
648
social-comfort-weight
social-comfort-weight
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
505
545
715
578
ap-decay-rate
ap-decay-rate
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
505
510
715
543
backfire-amp
backfire-amp
0
5
1.5
0.1
1
NIL
HORIZONTAL

PLOT
720
510
920
635
Ideology
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean-ideology"

PLOT
920
510
1120
635
Standard-deviation
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sd-affective"
"pen-1" 1.0 0 -7500403 true "" "plot sd-ideology"

MONITOR
870
510
920
555
Mean
mean-ideology
2
1
11

MONITOR
1070
510
1120
555
SD
sd-ideology
2
1
11

SLIDER
20
580
265
613
baseline-stress
baseline-stress
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
20
520
265
553
beta-media-bias
beta-media-bias
0
6
2.0
0.1
1
NIL
HORIZONTAL

SLIDER
20
650
265
683
search-radius
search-radius
1
5
5.0
1
1
NIL
HORIZONTAL

TEXTBOX
20
85
170
103
Population settings
13
0.0
1

TEXTBOX
20
265
170
283
Experimental variables
13
0.0
1

TEXTBOX
20
430
170
448
Interaction modifiers
13
0.0
1

TEXTBOX
20
560
170
578
Mobility settings
13
0.0
1

TEXTBOX
275
455
425
473
Polarization dyanamics
13
0.0
1

TEXTBOX
505
455
655
473
Backfire effects
13
0.0
1

SWITCH
155
45
265
78
validation?
validation?
0
1
-1000

@#$#@#$#@
## ACKNOWLEDGMENT

This calibrated version of the model was developed as part of a study examining the mechanisms of affective polarization within digital and interpersonal communication environments. Agent attributes were empirically calibrated using nationally representative survey data collected in 2019. The authors thank the NetLogo community for their ongoing support and modeling tools.


---

## WHAT IS IT?

This agent-based model simulates the emergence of **affective political polarization** in a population of individuals (human agents) who interact with both local neighbors and global media sources.

The model explores how four key mechanisms interact to shape polarization over time:

- **Social influence**: interpersonal discussion with ideologically similar or different neighbors  
- **Media influence**: exposure to ideologically slanted media outlets  
- **Selective exposure**: preference for attitude-consistent information sources  
- **Homophily**: tendency to interact with like-minded individuals

It also includes a **backfire effect**, where exposure to ideologically opposing content can intensify polarization, reflecting identity-protective cognition.

This version is **calibrated using U.S. national survey data** (see Appendix A), allowing the model to reflect realistic distributions of party ID, ideology, affective polarization, and behavioral frequency (news consumption and discussion).


---

## HOW TO USE IT

1. Adjust global parameters (e.g., `global-social-influence`, `global-media-influence`, `global-selective-exposure`, `global-homogenous-discussion`) to define your communication scenario. See the technical appendix for a full explanation of parameter settings.
2. Click **Setup** to initialize the grid with empirically calibrated agents and media outlets.
3. Click **Go** to begin the simulation. At each time step (tick), the model simulates:
   - Interpersonal discussions
   - Media consumption
   - Ideological updating
   - Affective polarization dynamics
   - Relocation based on ideological comfort and tolerance

The model supports experimental conditions aligned with minimal, strong, social-dominant, and media-dominant communication effect scenarios.


---

## THINGS TO NOTICE

- Under what conditions does **affective polarization** increase most rapidly?
- How does **homophily** shape the formation of echo chambers?
- Do agents relocate more in high or low polarization environments?
- What happens to **social diversity** versus **media diversity** over time?


---

## THINGS TO TRY

- Set `global-selective-exposure` to `0` to explore the effects of non-selective, open media consumption.
- Compare low vs. high values of `global-homogenous-discussion` to observe the impact of partner filtering.
- Modify the **backfire effect parameters** (`p-backfire-when-incongruent`, `backfire-amp`) to see how hostile encounters affect polarization trajectories.
- Simulate all 16 experimental conditions using NetLogo’s **BehaviorSpace** tool and compare the final levels of affective polarization, social diversity, and media diversity.

---

## NETLOGO FEATURES

- Implements a **backfire mechanism** where agents become more polarized after extreme ideological conflict.
- Uses **interaction frequency** to define social radius and media consumption load.
- Models **selective exposure** through exponential weighting of media ideology in selection.
- Measures **diversity** using normalized Shannon entropy for both social and media exposure.
- Includes agent-level heterogeneity around global parameters (e.g., social influence, selective exposure).


---

## RELATED MODELS

- **Segregation** (Schelling model) – spatial relocation based on neighborhood similarity
- **Network-Based Polarization Models** – models of opinion dynamics with homophily and bounded confidence


---

## CREDITS AND REFERENCES

This model draws on theoretical and empirical foundations from:

- Bail, C. A., Argyle, L. P., Brown, T. W., Bumpus, J. P., Chen, H., Hunzaker, M. F., ... & Volfovsky, A. (2018). Exposure to opposing views on social media can increase political polarization. Proceedings of the National Academy of Sciences, 115(37), 9216-9221.
- Bennett, W. L., & Iyengar, S. (2008). A new era of minimal effects? The changing foundations of political communication. Journal of communication, 58(4), 707-731.
- Axelrod, R. (1997). The dissemination of culture: A model with local convergence and global polarization. Journal of conflict resolution, 41(2), 203-226.
- Törnberg, P. (2022). How digital media drive affective polarization through partisan sorting. Proceedings of the National Academy of Sciences, 119(42), e2207159119.

The simulation design is informed by frameworks in political communication, computational social science, and sociophysics.


---

## HOW TO CITE

If you use this model, please cite:

**[Author Names]. (2025).** *Selective Exposure to News, Homogeneous Political Discussion Networks, and Affective Political Polarization: An Agent-Based Modeling Test of Minimal Versus Strong Communication Effects*. [Journal Name – under review].


---
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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -7500403 true true 110 5 80

person business
false
14
Rectangle -1 true false 120 90 180 180
Polygon -16777216 true true 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true false 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true false 110 5 80
Rectangle -7500403 true false 127 76 172 91
Line -16777216 true 172 90 161 94
Line -16777216 true 128 90 139 94
Polygon -16777216 true true 195 225 195 300 270 270 270 195
Rectangle -16777216 true true 180 225 195 300
Polygon -16777216 true true 180 226 195 226 270 196 255 196
Polygon -16777216 true true 209 202 209 216 244 202 243 188
Line -16777216 true 180 90 150 165
Line -16777216 true 120 90 150 165

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="population_market_lowlow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <steppedValueSet variable="population" first="100" step="100" last="1000"/>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="population_market_hihi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <steppedValueSet variable="population" first="100" step="100" last="1000"/>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="population_market_midmid" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <steppedValueSet variable="population" first="100" step="100" last="1000"/>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dem_lib_midmid" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <steppedValueSet variable="democrats%" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="liberal%" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="backfire_midmid" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="backfire_rate" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="backfire_lowlow" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="backfire_rate" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="backfire_hihi" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="backfire_rate" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_midmid" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_lowlow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_hihi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="homo_midmid" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="homo_lowlow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="homo_hihi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_hilow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_lowhi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="homo_hilow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="homo_lowhi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="population_market_hilow" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <steppedValueSet variable="population" first="100" step="100" last="1000"/>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="population_market_lowhi" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <steppedValueSet variable="population" first="100" step="100" last="1000"/>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;low&quot;"/>
      <value value="&quot;moderate&quot;"/>
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="dem_lib_bothboth_saturated" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <steppedValueSet variable="democrats%" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="liberal%" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="selective_homo" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-polarized</metric>
    <metric>percent-polarized-dem</metric>
    <metric>percent-polarized-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <enumeratedValueSet variable="population">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="&quot;saturated&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire_rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="1.5"/>
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_selective_exposure" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="1.5"/>
      <value value="9"/>
    </enumeratedValueSet>
    <steppedValueSet variable="global_homo_discussion" first="0.1" step="0.1" last="0.9"/>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_tolerance">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="moving">
      <value value="&quot;selective&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="influence+selectivity" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>percent-happy</metric>
    <metric>percent-happy-dem</metric>
    <metric>percent-happy-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <metric>agent-diversity-index</metric>
    <metric>dem-agent-diversity-index</metric>
    <metric>rep-agent-diversity-index</metric>
    <metric>media-diversity-index</metric>
    <metric>dem-media-diversity-index</metric>
    <metric>rep-media-diversity-index</metric>
    <enumeratedValueSet variable="moving">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_homo_discussion">
      <value value="0.3"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_selective_exposure">
      <value value="0.3"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="media_market">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="influence+market" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 1000 [ go ]</go>
    <metric>percent-happy</metric>
    <metric>percent-happy-dem</metric>
    <metric>percent-happy-rep</metric>
    <metric>mean-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <metric>agent-diversity-index</metric>
    <metric>dem-agent-diversity-index</metric>
    <metric>rep-agent-diversity-index</metric>
    <metric>media-diversity-index</metric>
    <metric>dem-media-diversity-index</metric>
    <metric>rep-media-diversity-index</metric>
    <enumeratedValueSet variable="moving">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_dis_influence">
      <value value="3"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_media_influence">
      <value value="3"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="democrats%">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="media_market" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="liberal%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global_change_rate">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="revise_influence_selectivity" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>mean-affective</metric>
    <metric>sd-affective</metric>
    <metric>mean-affective-dem</metric>
    <metric>mean-affective-rep</metric>
    <metric>mean-affective-ind</metric>
    <metric>mean-ideology</metric>
    <metric>sd-ideology</metric>
    <metric>mean-agent-diversity</metric>
    <metric>mean-agent-diversity-dem</metric>
    <metric>mean-agent-diversity-rep</metric>
    <metric>mean-agent-diversity-ind</metric>
    <metric>mean-media-diversity</metric>
    <metric>mean-media-diversity-dem</metric>
    <metric>mean-media-diversity-rep</metric>
    <metric>mean-media-diversity-ind</metric>
    <metric>happy-percent</metric>
    <enumeratedValueSet variable="max-ticks">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-social-influence">
      <value value="0.1"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-media-influence">
      <value value="0.1"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-homogenous-discussion">
      <value value="0.1"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="global-selective-exposure">
      <value value="0.1"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="validation?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="search-radius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="disagreement-threshold">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="disagreement-penalty">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cross-cutting-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="cross-cutting-ap-reduction">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="like-minded-ap-boost">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="like-minded-threshold">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="baseline-stress">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-media-bias">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discussion-modifier">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="consumption-modifier">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-comfort-weight">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="backfire-amp">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p-backfire-when-incongruent">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ap-decay-rate">
      <value value="0.08"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
