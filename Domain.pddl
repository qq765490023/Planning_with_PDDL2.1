;Notice that i there is the funciton (timeunits) used to calculat the total duration of the plan 
;and it used to minimize the cost, bu using it in the :metric in problem file

;Notice also that the actions are ordred in a the usual order of the majority of the plans

(define (domain my_domain)
  (:requirements :strips :typing :durative-actions :fluents :negative-preconditions :disjunctive-preconditions)
 (:types 
        crate - object
        robot - object
        location - object
    	mover loader - robot
    	heavy light - crate 
    	loadingbay crate_pose - location)
            
  (:predicates 
    	 (robot-at ?robot - robot ?loc - location)
    	 (empty-robot ?robot - robot)
    	 (holding-robot ?robot - robot ?crate - crate)
    	 (different ?mover1 - robot ?mover2 - robot)
    	 (crate-at ?crate - crate ?loc - location)  
    	 (crate-pose ?crate - crate ?loc - location)
   	     (crate-carried ?crate - crate ?robot - robot)
    	 (crate-2carried ?crate - crate ?robot1 - robot ?robot2 - robot)
   	     (crate-at-convayor ?crate - crate)
     	 (not-fragil ?crate - crate)
  	     (fragil ?crate - crate)
  	     (free ?loader - loader) 
  	     (busy ?loader - loader) 
         (active-a) (active-b) (active-no)  ;-no it means does not belong to any groupe
         (group-a ?c - crate)(group-b ?c - crate) (group-no ?c - crate)    
     )

  (:functions 
    	(distance ?crate - crate)
    	(weight ?crate - crate)
    	(extra-time ?crate)
   	    (loader-capability ?loader - loader)
        (count-a) (count-b) (count-no) ;number of crates that belong to a specific group
        (i) (j) (k);(i) counters of group-a (j) counters of group-b (k) counters of group-no
        (timeunit) ;The cost that will be used in a metric to be minimized and getting optimal solution 
        
        (mover_battery ?mover - mover)
        (mover_position ?mover - mover)
    
    )


  (:durative-action charge
      :parameters (?mover - mover ?loadingbay - loadingbay )
      :duration (= ?duration 1)
      :condition (and
            (at start (empty-robot ?mover))
           (at start (robot-at ?mover ?loadingbay))
            (at end (robot-at ?mover ?loadingbay))
            )
      :effect (and
          (at start (increase (timeunit) 1)) 
          (at end (assign (mover_battery ?mover) 22))
       )
  )


(:durative-action move_empty 
    :parameters(?mover - mover ?crate - crate ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :duration (= ?duration (/(distance ?crate)10 )  )
    :condition (and 
        (at start (>= (mover_battery ?mover) (+(/(distance ?crate)10) (/(*(distance ?crate)(weight ?crate))100))))
        (at start (> (mover_battery ?mover) 5))
      	(at start (robot-at ?mover ?loadingbay)) 
      	(at start (crate-at ?crate ?crate_pose))
      	(at start (not (robot-at ?mover ?crate_pose))) 
      	(at start (crate-pose ?crate ?crate_pose))
        (at start (> (mover_battery ?mover ) 0)) ;;;;;;;;;;;;;;
        (at end   (>= (mover_battery ?mover ) 0)) ;;;;;;;;;;;;;;
      )
        
    :effect (and
      	(at end (robot-at ?mover ?crate_pose ))
      	(at end (not(robot-at ?mover ?loadingbay))) 
        (at start (decrease (mover_battery ?mover ) (/(distance ?crate)10 ) )) ;;;;;;;;;;;;;;
        (at end (increase (mover_position ?mover ) (distance ?crate))) ;;;;;;;;;;;;;;
      	(at start (increase (timeunit) (/(distance ?crate)10 ) )) ))
        
(:action change_groupe
    :parameters () 
    :precondition (or (>=(i)(count-a)) (>=(j)(count-b)) (>=(k)(count-no)))
    :effect(and
         (assign (i) 0) (assign (k) 0) (assign (k) 0)
         (active-a) (active-b) (active-no)
      ))
 
(:action pickup_light
    :parameters (?mover - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and   
        (robot-at ?mover ?crate_pose)   (crate-pose ?light ?crate_pose) (crate-at ?light ?crate_pose) (not-fragil ?light) 
        (group-no ?light) (active-no) ) 
    :effect(and 
        (not(active-a)) (not(active-b))
        (increase (k) 1)
       	(holding-robot ?mover ?light) (crate-carried ?light ?mover) 
        (not(empty-robot ?mover)) (not(crate-at ?light ?crate_pose)) ) )

(:action pickup_light_A
    :parameters (?mover - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and   
        (robot-at ?mover ?crate_pose)   (crate-pose ?light ?crate_pose) (crate-at ?light ?crate_pose) (not-fragil ?light) 
        (active-a) (group-a ?light) ) 
    :effect(and 
        (not(active-b)) (not(active-no))
        (increase (i) 1)
       	(holding-robot ?mover ?light) (crate-carried ?light ?mover) 
        (not(empty-robot ?mover)) (not(crate-at ?light ?crate_pose)) ) )

(:action pickup_light_B
    :parameters (?mover - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and   
        (robot-at ?mover ?crate_pose)   (crate-pose ?light ?crate_pose) (crate-at ?light ?crate_pose) (not-fragil ?light)
        (group-b ?light) (active-b) )
    :effect(and 
        (not(active-a)) (not(active-no))
        (increase (j) 1)
       	(holding-robot ?mover ?light) (crate-carried ?light ?mover) 
        (not(empty-robot ?mover)) (not(crate-at ?light ?crate_pose)) ) )
    


(:durative-action move_light_1r
    :parameters(?mover - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose ) 
    :duration (= ?duration (/(*(distance ?light)(weight ?light))100)  )
    :condition (and 
     	 (at start (robot-at ?mover ?crate_pose)) ;at loadfinbay
     	 (at start (crate-carried ?light ?mover)) ;at pose
         (at start (holding-robot ?mover ?light))
     	 (at start (crate-pose ?light ?crate_pose))
         (at start (> (mover_battery ?mover ) 0)) ;;;;;;;;;;;;;;
         (at end (>= (mover_battery ?mover ) 0)) ;;;;;;;;;;;;;;

          )
    :effect (and
      	 (at end (robot-at ?mover ?loadingbay )) 
      	 (at end (not(robot-at ?mover ?crate_pose)))
         (at start (decrease (mover_battery ?mover ) (/(*(distance ?light)(weight ?light))100) )) ;;;;;;;;;;;;;;
         (at end (decrease (mover_position ?mover ) (mover_position ?mover ))) ;;;;;;;;;;;;;;
 
      	 (at start (increase (timeunit) (/(*(distance ?light)(weight ?light))100) )) ))

(:action drop_1
    :parameters (?mover - mover ?crate - light  ?loc - location ?loader - loader)
    :precondition (and 
         (holding-robot ?mover ?crate) (crate-carried ?crate ?mover) (robot-at ?mover ?loc)
         (free ?loader))
    :effect (and  
         (not(holding-robot ?mover ?crate)) (not(crate-carried ?crate ?mover)) (crate-at ?crate ?loc)     
         (empty-robot ?mover)  ))
 
(:action pickup_2light
    :parameters (?mover1 - mover ?mover2 - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and  
        (robot-at ?mover1 ?crate_pose) (robot-at ?mover2 ?crate_pose)  (crate-pose ?light ?crate_pose)  (fragil ?light)
        (crate-at ?light ?crate_pose) (group-no ?light) (active-no)) 
    :effect  (and 
       (not(active-a)) (not(active-b))
       (increase (k) 1)
       (holding-robot ?mover1 ?light)(holding-robot ?mover2 ?light) (crate-2carried ?light ?mover1 ?mover2) 
       (not(empty-robot ?mover1))  (not(empty-robot ?mover2)) (not(crate-at ?light ?crate_pose)) )) 

(:action pickup_2light_A
    :parameters (?mover1 - mover ?mover2 - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and  
        (robot-at ?mover1 ?crate_pose) (robot-at ?mover2 ?crate_pose)  (crate-pose ?light ?crate_pose)  (fragil ?light)
        (crate-at ?light ?crate_pose)(active-a) (group-a ?light)) 
    :effect  (and 
       (not(active-b)) (not(active-no))
       (increase (i) 1)
       (holding-robot ?mover1 ?light)(holding-robot ?mover2 ?light) (crate-2carried ?light ?mover1 ?mover2) 
       (not(empty-robot ?mover1))  (not(empty-robot ?mover2)) (not(crate-at ?light ?crate_pose)) )) 
            
(:action pickup_2light_B
    :parameters (?mover1 - mover ?mover2 - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :precondition (and  
        (robot-at ?mover1 ?crate_pose) (robot-at ?mover2 ?crate_pose)  (crate-pose ?light ?crate_pose)  (fragil ?light)
        (crate-at ?light ?crate_pose) (group-b ?light) (active-b)) 
    :effect  (and 
       (not(active-a)) (not(active-no))
        (increase (j) 1)
       	(holding-robot ?mover1 ?light)(holding-robot ?mover2 ?light) (crate-2carried ?light ?mover1 ?mover2) 
        (not(empty-robot ?mover1))  (not(empty-robot ?mover2)) (not(crate-at ?light ?crate_pose)) )) 


(:durative-action move_light_2r
    :parameters(?mover1 - mover ?mover2 - mover ?light - light ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :duration (= ?duration (/(*(distance ?light)(weight ?light))150)  )
    :condition (and 
      (at start (crate-pose ?light ?crate_pose))
      (at start (robot-at ?mover1 ?crate_pose)) (at start (robot-at ?mover2 ?crate_pose))
      (at start (crate-2carried ?light ?mover1 ?mover2))
      (at start (holding-robot ?mover1 ?light)) (at start (holding-robot ?mover2 ?light))
      (at start (different ?mover1 ?mover2))
      (at start (> (mover_battery ?mover1 ) 0)) ;;;;;;;;;;;;;;
      (at end (>= (mover_battery ?mover1 ) 0)) ;;;;;;;;;;;;;;
      (at start (> (mover_battery ?mover2 ) 0)) ;;;;;;;;;;;;;;
      (at end (>= (mover_battery ?mover2 ) 0)) ;;;;;;;;;;;;;;
       )
    :effect (and
      (at end (robot-at ?mover1 ?loadingbay))
      (at end (robot-at ?mover2 ?loadingbay))
      (at end (not(robot-at ?mover1 ?crate_pose)))
      (at end (not(robot-at ?mover2 ?crate_pose)))
      (at start (decrease (mover_battery ?mover1 ) (/(*(distance ?light)(weight ?light))150) )) ;;;;;;;;;;;;;;
      (at end (decrease (mover_position ?mover1 ) (mover_position ?mover1 ))) ;;;;;;;;;;;;;;
      (at start (decrease (mover_battery ?mover2 ) (/(*(distance ?light)(weight ?light))150) )) ;;;;;;;;;;;;;;
      (at end (decrease (mover_position ?mover2 ) (mover_position ?mover2 ))) ;;;;;;;;;;;;;;
 
      (at start (increase (timeunit) (/(*(distance ?light)(weight ?light))150) ))))     	

          
(:action pickup_heavy
    :parameters (?mover1 - mover ?mover2 - mover ?heavy - heavy  ?crate_pose - crate_pose)
    :precondition (and 
        (empty-robot ?mover1) (empty-robot ?mover2) (crate-pose ?heavy ?crate_pose)
        (robot-at ?mover1 ?crate_pose)(robot-at ?mover2 ?crate_pose)(crate-at ?heavy ?crate_pose)
        (different ?mover1 ?mover2)(group-no ?heavy) (active-no))
    :effect (and 
        (not(active-a)) (not(active-b))
        (increase (k) 1)
        (holding-robot ?mover1 ?heavy) (holding-robot ?mover2 ?heavy) 
        (crate-carried ?heavy ?mover1)(crate-2carried ?heavy ?mover1 ?mover2) 
        (not(empty-robot ?mover1)) (not(empty-robot ?mover2)) (not(crate-at ?heavy ?crate_pose))))

(:action pickup_heavy_A
    :parameters (?mover1 - mover ?mover2 - mover ?heavy - heavy  ?crate_pose - crate_pose)
    :precondition (and 
        (empty-robot ?mover1) (empty-robot ?mover2) (crate-pose ?heavy ?crate_pose)
        (robot-at ?mover1 ?crate_pose)(robot-at ?mover2 ?crate_pose)(crate-at ?heavy ?crate_pose)
        (different ?mover1 ?mover2)(active-a) (group-a ?heavy))
    :effect (and
        (not(active-b)) (not(active-no))
        (increase (i) 1)
        (holding-robot ?mover1 ?heavy) (holding-robot ?mover2 ?heavy) 
        (crate-carried ?heavy ?mover1)(crate-2carried ?heavy ?mover1 ?mover2) 
        (not(empty-robot ?mover1)) (not(empty-robot ?mover2)) (not(crate-at ?heavy ?crate_pose))))

(:action pickup_heavy_B
    :parameters (?mover1 - mover ?mover2 - mover ?heavy - heavy  ?crate_pose - crate_pose)
    :precondition (and 
        (empty-robot ?mover1) (empty-robot ?mover2) (crate-pose ?heavy ?crate_pose)
        (robot-at ?mover1 ?crate_pose)(robot-at ?mover2 ?crate_pose)(crate-at ?heavy ?crate_pose)
        (different ?mover1 ?mover2)(group-b ?heavy) (active-b))
    :effect (and 
        (not(active-a)) (not(active-no))
        (increase (j) 1)
        (holding-robot ?mover1 ?heavy)   (holding-robot ?mover2 ?heavy) 
        (crate-carried ?heavy ?mover1)   (crate-2carried ?heavy ?mover1 ?mover2) 
        (not(empty-robot ?mover1))       (not(empty-robot ?mover2))   (not(crate-at ?heavy ?crate_pose))))


(:durative-action move_heavy
    :parameters(?mover1 - mover ?mover2 - mover ?heavy - heavy ?loadingbay - loadingbay ?crate_pose - crate_pose) 
    :duration (= ?duration (/(*(distance ?heavy)(weight ?heavy))100)  )
    :condition (and 
      (at start (crate-pose ?heavy ?crate_pose))
      (at start (robot-at ?mover1 ?crate_pose)) (at start (robot-at ?mover2 ?crate_pose)) (at start (crate-pose ?heavy ?crate_pose))
      (at start (crate-2carried ?heavy ?mover1 ?mover2))
      (at start (holding-robot ?mover1 ?heavy)) (at start (holding-robot ?mover2 ?heavy))
      (at start (different ?mover1 ?mover2))
      (at start (> (mover_battery ?mover1 ) 0)) ;;;;;;;;;;;;;;
      (at end (>= (mover_battery ?mover1 ) 0)) ;;;;;;;;;;;;;;
      (at start (> (mover_battery ?mover2 ) 0)) ;;;;;;;;;;;;;;
      (at end (>= (mover_battery ?mover2 ) 0)) ;;;;;;;;;;;;;;

      )        
    :effect (and
      (at end (robot-at ?mover1 ?loadingbay))
      (at end (robot-at ?mover2 ?loadingbay))
      (at end (not(robot-at ?mover1 ?crate_pose)))
      (at end (not(robot-at ?mover2 ?crate_pose)))
      (at start (decrease (mover_battery ?mover1 ) (/(*(distance ?heavy)(weight ?heavy))100) )) ;;;;;;;;;;;;;;
      (at end (decrease (mover_position ?mover1 ) (mover_position ?mover1 ))) ;;;;;;;;;;;;;;
      (at start (decrease (mover_battery ?mover2 ) (/(*(distance ?heavy)(weight ?heavy))100) )) ;;;;;;;;;;;;;;
      (at end (decrease (mover_position ?mover2 ) (mover_position ?mover2 ))) ;;;;;;;;;;;;;;
 
      (at start (increase (timeunit) (/(*(distance ?heavy)(weight ?heavy))100) ))))
  
(:action drop_2
    :parameters (?mover1 - mover ?mover2 - mover ?crate - crate  ?loc - location ?loader - loader)
    :precondition (and 
        (robot-at ?mover1 ?loc) (robot-at ?mover2 ?loc) (holding-robot ?mover1 ?crate) (holding-robot ?mover2 ?crate)
        (crate-2carried ?crate ?mover1 ?mover2)
        (different ?mover1 ?mover2)
        (free ?loader))
    :effect (and 
           (not(holding-robot ?mover1 ?crate)) (not(holding-robot ?mover2 ?crate))
           (not(crate-2carried ?crate ?mover1 ?mover2))
           (crate-at ?crate ?loc) (empty-robot ?mover1) (empty-robot ?mover2) ))
           
(:durative-action load
    :parameters(?crate - crate ?loc - location  ?loader - loader  ) 
    :duration (= ?duration (+ 4(extra-time ?crate))  )
    :condition (and 
       (at start (crate-at ?crate ?loc))
       (at start (robot-at ?loader ?loc))
       (at start (free ?loader))
       (at start (<(weight ?crate)(loader-capability ?loader))))           
    :effect (and
      (at start (not(free ?loader)))
      (at start (busy ?loader))
      (at start (not(crate-at ?crate ?loc)))
      (at start (increase (timeunit) (/(distance ?crate)10 ) )) 
      (at end (free ?loader))
      (at end (not(busy ?loader)))
      (at end (crate-at-convayor ?crate)))
))

  