library(jsonlite)
library(plumber)

create_routes <- function() {
  route1 <- data.frame(
    lon = c(77.240511, 77.240303, 77.240095), 
    lat = c(28.642676, 28.645268, 28.647861)
  )
  route2 <- data.frame(
    lon = c(77.246915, 77.246887, 77.246859),
    lat = c(28.640005, 28.642924, 28.645843)
  )
  route3 <- data.frame(
    lon = c(77.232604, 77.235832, 77.239061),
    lat = c(28.642016, 28.641317, 28.640618)
  )
  return(list(route1 = route1, route2 = route2, route3 = route3))
}
bus_states <- list()

create_bus <- function(route, bus_id, speed) {
  if (is.null(bus_states[[as.character(bus_id)]])) {
    bus_states[[as.character(bus_id)]] <<- list(
      bus_id = bus_id,
      route_id = paste0("R", bus_id),
      speed = speed,
      current_point = 1,
      progress = 0,
      lon = route$lon[1],
      lat = route$lat[1],
      route = route,  
      stopped = FALSE  # Flag bus reached the end
    )
  }
  
  #updates and returns the bus position
  function() {
    bus_info <- bus_states[[as.character(bus_id)]]
    route_length <- nrow(bus_info$route) # 3
    
    if (bus_info$stopped) {
      bus_info$timestamp <- Sys.time()
      return(bus_info)  #just return cur state , no updates as stopped
    }
    
    # If at end of the route, stop the bus
    if (bus_info$current_point >= route_length) {
      bus_info$progress <- 1 
      bus_info$lon <- bus_info$route$lon[route_length] #last pos nth
      bus_info$lat <- bus_info$route$lat[route_length]
      bus_info$stopped <- TRUE
      bus_info$timestamp <- Sys.time()
      bus_states[[as.character(bus_id)]] <<- bus_info
      return(bus_info)
    }
    
    # Move bus forward
    bus_info$progress <- bus_info$progress + bus_info$speed
    
    if (bus_info$progress < 1) {
      #line between current and next point
      current <- bus_info$current_point
      next_point <- current + 1
      bus_info$lon <- bus_info$route$lon[current] + 
        bus_info$progress * (bus_info$route$lon[next_point] - bus_info$route$lon[current])
      
      bus_info$lat <- bus_info$route$lat[current] + 
        bus_info$progress * (bus_info$route$lat[next_point] - bus_info$route$lat[current])
    } else {
      # Move to the next point
      bus_info$current_point <- bus_info$current_point + 1
      bus_info$progress <- 0
      if (bus_info$current_point <= route_length) {
        bus_info$lon <- bus_info$route$lon[bus_info$current_point]
        bus_info$lat <- bus_info$route$lat[bus_info$current_point]
      }
    }
    bus_info$timestamp <- Sys.time()
    
    bus_states[[as.character(bus_id)]] <<- bus_info
    
    return(bus_info)
  }
}

routes <- create_routes()
bus1 <- create_bus(routes$route1, 1, speed = 0.1)
bus2 <- create_bus(routes$route2, 2, speed = 0.1)
bus3 <- create_bus(routes$route3, 3, speed = 0.1)
buses <- list(bus1, bus2, bus3)

#* @get /buses
#* @serializer json
function() {
  bus_positions <- lapply(buses, function(bus_fn) {
    bus_fn() 
  })
  

  return(bus_positions)
}