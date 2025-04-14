library(shiny)
library(leaflet)
library(httr)
library(jsonlite)

ui <- fluidPage(
  titlePanel("Real-time Bus Tracking"),
  leafletOutput("map", height = "800px")
)

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 77.240821, lat = 28.640471, zoom = 14)
  })
  
  get_bus_data <- function() {
    message("Fetching data at: ", Sys.time())
      response <- GET("http://localhost:31289/buses")
      if (status_code(response) == 200) {
        content_text <- content(response, "text", encoding = "UTF-8")
        parsed_data <- fromJSON(content_text)
        return(parsed_data)
      } else {
        message("API error: ", status_code(response))
        return(NULL)
      }
    }
  
  
  bus_timer <- reactiveTimer(1000)
  
  observe({
    bus_timer()  # Trigger every 1 second
    
    bus_data <- get_bus_data()
    if (!is.null(bus_data)) {
      bus_df <- {
        bus_df <- bus_data
        bus_df$id <- as.numeric(bus_df$bus_id)
        bus_df$lat <- as.numeric(bus_df$lat)
        bus_df$lng <- as.numeric(bus_df$lon)
        bus_df$route <- bus_df$route_id
        bus_df
      }
    }
      print(bus_df) 
      
      if (!is.null(bus_df) && nrow(bus_df) > 0) {
        leafletProxy("map") %>%
          clearMarkers() %>%  # Clear old markers
          addCircleMarkers(
            data = bus_df,
            lng = ~lng,
            lat = ~lat,
            label = ~paste("Bus ID:", id, "Route:", route),
            radius = 12,
            color = "brown",
            fillColor = "yellow",
            fillOpacity = 0.9,
            stroke = TRUE,
            weight = 2
          )
      }
    })
}

shinyApp(ui, server)
