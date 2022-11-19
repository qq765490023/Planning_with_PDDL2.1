(define (problem my_problem)
  (:domain my_domain)
  (:objects 
    r1 r2 - mover 
    l1 l2 - loader
    
    c1 c2  - heavy
    c3 c4 - light
    
    lb - loadingbay 
    cp1 cp2 cp3 cp4 - crate_pose
    
  )
  (:init 
    (robot-at l1 lb) (robot-at l2 lb) (robot-at r1 lb)  (empty-robot r1) (empty-robot r2) (robot-at r2 lb) 
    (crate-at c1 cp1) (crate-at c2 cp2)(crate-at c3 cp3)(crate-at c4 cp4)
    (crate-pose c1 cp1)  (crate-pose c2 cp2) (crate-pose c3 cp3) (crate-pose c4 cp4)
    (different r1 r2)
    
    (active-a) (active-b) (active-no)
    (=(mover_battery r1) 5)
    (=(mover_battery r2) 5)
    (=(mover_position r1) 0)
    (=(mover_position r2) 0)
    (=(timeunit)0)

    (free l1)
    (=(loader-capability l1)200)
    (free l2) 
    (=(loader-capability l2)50)
    
    (=(count-a)2) (=(count-b)2) (=(count-no)0)
    (=(i)0)(=(j)0)(=(k)0)

    (=(distance c1)10)
    (=(weight c1)70)
    (not-fragil c1)
    (=(extra-time c1)0)
    (group-a c1)


    (=(distance c2)20)
    (=(weight c2)80)
    (fragil c2)
    (=(extra-time c2)2)
    (group-a c2)

    (=(distance c3)20)
    (=(weight c3)20)
    (not-fragil c3)
    (=(extra-time c3)0)
    (group-b c3)
    
    (=(distance c4)10)
    (=(weight c4)30)
    (not-fragil c4)
    (=(extra-time c4)0)
    (group-b c4)

  )
  (:goal (and 
     (crate-at-convayor c4)(crate-at-convayor c3) (crate-at-convayor c2) (crate-at-convayor c1)
     ))
  (:metric minimize (timeunit))
)