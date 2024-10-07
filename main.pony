use "time"
use "collections"
use "random"

actor Main
  var actors: Array[Worker tag]
  var converged_actors: Array[Bool]
  var converged_count: USize = 0
  var has_converged: Bool = false // Flag to track if convergence is reached
  var numNodes:USize = 0
  var topology:String = ""
  var algorithm:String = ""
  let sys:Env
  var start_time: (I64, I64)


  new create(env: Env) =>
    let args = env.args
    sys=env
    start_time=Time.now()
    actors= Array[Worker tag]
    converged_actors=Array[Bool]
    // Check if sufficient arguments are passed
    if (args.size() < 4) then
        env.out.print("Usage: <numNodes> <topology> <algorithm>")
        return    
    end
    numNodes = try args(1)?.usize()? else 0 end

    topology = try args(2)? else "" end
    algorithm = try args(3)? else "" end
    if ( numNodes == 0) then
        env.out.print("Invalid number of nodes")
        return    
    end
    numNodes = 
      if (topology == "3d") or (topology == "imp3d") then
          let side = (numNodes.f64().pow(1.0 / 3.0)).round().usize()
          side * side * side
      else
        numNodes
      end

    
    actors = Array[Worker tag](numNodes)
    converged_actors = Array[Bool](numNodes)
    
    try
        for i in Range(0, numNodes) do
            converged_actors.insert(i,false)? 
            actors.insert(i, Worker(sys, i, algorithm, this))?
        end
    else
        env.out.print("Error during setup")
    end
    
    try
      build_topology()?
      start()
    else
      sys.out.print("Error building topology")
    end

  fun ref build_topology() ? =>
    match topology
      | "line" => build_line_topology()?
      | "3d" => build_3d_topology()?
      | "full" => build_full_topology()?
      | "imp3d" => build_imp_3d_topology()?
      else
        sys.out.print("Invalid Topology Selection")
    end

  fun ref build_line_topology() ? =>
    sys.out.print("Building Line Topology...")
    for i in Range(0, numNodes) do
      if i > 0 then
        actors(i)?.add_neighbor(actors(i - 1)?)
      end
      if i < (numNodes - 1) then
        actors(i)?.add_neighbor(actors(i + 1)?)
      end
    end

  fun ref build_3d_topology() ? =>
    let side = (numNodes.f64().pow(1.0 / 3.0)).round().usize()
    for i in Range(0, numNodes) do
      let x = i % side
      let y = (i / side) % side
      let z = i / (side * side)
      if x > 0 then actors(i)?.add_neighbor(actors(i - 1)?) end
      if x < (side - 1) then actors(i)?.add_neighbor(actors(i + 1)?) end
      if y > 0 then actors(i)?.add_neighbor(actors(i - side)?) end
      if y < (side - 1) then actors(i)?.add_neighbor(actors(i + side)?) end
      if z > 0 then actors(i)?.add_neighbor(actors(i - (side * side))?) end
      if z < (side - 1) then actors(i)?.add_neighbor(actors(i + (side * side))?) end
    end
  
  fun ref build_imp_3d_topology() ? =>
    let side = (numNodes.f64().pow(1.0 / 3.0)).round().usize()
    for i in Range(0, numNodes) do
      let x = i % side
      let y = (i / side) % side
      let z = i / (side * side)
      let neighbor_indx = Array[USize]
      if x > 0 then 
        actors(i)?.add_neighbor(actors(i - 1)?) 
        neighbor_indx.push(i - 1)
      end
      if x < (side - 1) then 
        actors(i)?.add_neighbor(actors(i + 1)?) 
        neighbor_indx.push(i + 1)
      end
      if y > 0 then 
        actors(i)?.add_neighbor(actors(i - side)?) 
        neighbor_indx.push(i - side)
      end
      if y < (side - 1) then 
        actors(i)?.add_neighbor(actors(i + side)?) 
        neighbor_indx.push(i + side)
      end
      if z > 0 then 
        actors(i)?.add_neighbor(actors(i - (side * side))?) 
        neighbor_indx.push(i - (side * side))
      end
      if z < (side - 1) then 
        actors(i)?.add_neighbor(actors(i + (side * side))?) 
        neighbor_indx.push(i + (side * side))
      end
      while true do
        let random_neighbor = (Time.now()._2.usize() % actors.size())
        if (is_actor_added(i, neighbor_indx)) then
          actors(i)?.add_neighbor(actors(random_neighbor)?)
          break
        end
      end
    end

  fun ref is_actor_added(x: USize, arr: Array[USize]): Bool =>
      try
        for i in Range(0, arr.size()) do
          if arr(i)? == x then
            return false
          end
        end
        true
      else
        return false
      end



  fun ref build_full_topology() ? =>
    sys.out.print("Building Full Topology...")  
    for parent in Range(0, numNodes) do
      for child in Range(0, numNodes) do
        if(parent!=child)then
          actors(parent)?.add_neighbor(actors(child)?)
        end
      end
    end

  be start() =>
    start_time=Time.now()
    match algorithm
      | "gossip" => try actors(Time.now()._2.usize() % actors.size())?.spread_rumor() end
      | "pushsum" => try actors(Time.now()._2.usize() % actors.size())?._push_sum() end
      else
        sys.out.print("Invalid Algorithm selection")
    end
  be worker_converged(worker_id:USize) =>
    try
      if(converged_actors(worker_id)? ==false)then
        sys.out.print("Node "+worker_id.string()+" converged.")
        converged_count = converged_count + 1
        converged_actors(worker_id)? =true

        if(converged_count==actors.size())then
          let end_time = Time.now()
          let elapsed_seconds = (end_time._1 - start_time._1).f64()
          let elapsed_nanoseconds = (end_time._2 - start_time._2).f64()
          let total_elapsed = elapsed_seconds + (elapsed_nanoseconds / 1_000_000_000)

        sys.out.print("Total Number of converged Node : " + converged_count.string()+" Time (s)->"+total_elapsed.string())
        for i in Range(0, actors.size()) do
          // if algorithm=="pushsum" then
          //   try actors(i)?.getFinalConverge()?end
          // end
          try actors(i)?.stop()?end
        end
       return
    end
      end
    else
      sys.out.print("Index Out Of Bound "+worker_id.string()+" Array size->"+actors.size().string())
    end  
    
  
  
actor Worker
  let env:Env
  let worker_id: USize
  let worker_algorithm: String
  let main_ref: Main tag
  var neighbors: Array[Worker tag] = Array[Worker tag]
  var rumor_count: USize = 0
  var converged: Bool = false
  var _rand: Rand
  var s: F64 = 0.0
  var w: F64 = 1.0
  var push_sum_count: USize = 0
  var new_ratio:F64=0.0
  new create(env':Env,id_param: USize, algorithm_param: String, main_param: Main tag) =>
    env=env'
    worker_id = id_param
    s=id_param.f64()
    worker_algorithm = algorithm_param
    main_ref = main_param
    _rand = Rand(Time.now()._2.u64())
    
  be add_neighbor(neighbor: Worker tag) =>
    neighbors.push(neighbor)

  be spread_rumor() =>
    try
        if not converged then

          rumor_count = rumor_count + 1
          let random_neighbor_node=neighbors((_rand.int(neighbors.size().u64())).usize())?
          random_neighbor_node.spread_rumor()
          if rumor_count >= 10 then
            main_ref.worker_converged(worker_id)
            //env.out.print("Worker converged Rumor " + worker_id.string()+" "+rumor_count.string())
          end
        end
    else
      // env.out.print("Worker converged Rumor " + worker_id.string()+" "+rumor_count.string())
      env.out.print("Issue in spreading rumours")
    end

  be stop()=>
    converged=true

  be getId()=>
    env.out.print("Worker Id"+worker_id.string())
  
  be getFinalConverge()=>
    env.out.print("Worker Converg  "+worker_id.string()+"  "+new_ratio.string())
  
  be _push_sum() =>
    if not converged then

      let old_ratio:F64 = s / w
      let total_s:F64 = s / 2.0
      let total_w:F64 = w / 2.0
      s = total_s
      w = total_w
      
      new_ratio = s / w
      //env.out.print("Push Sum workerid "+worker_id.string()+" oldratio "+old_ratio.string()+" New ratio "+new_ratio.string())
      if (old_ratio - new_ratio).abs() < 1e-10 then  // Relaxed threshold
        push_sum_count = push_sum_count + 1
      else
        push_sum_count = 0
      end
      //try neighbors((_rand.int(neighbors.size().u64())).usize())?.getId()?end
      let neighbor = try neighbors((_rand.int(neighbors.size().u64())).usize())? else return end
      neighbor.receive_push_sum(total_s, total_w)
      if push_sum_count >= 3 then
        main_ref.worker_converged(worker_id)
      end
    end
    
  be receive_push_sum(received_s: F64, received_w: F64) =>
    s = s + received_s
    w = w + received_w
    _push_sum()