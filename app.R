#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


#https://stackoverflow.com/questions/30587883/is-it-possible-to-stop-executing-of-r-code-inside-shiny-without-stopping-the-sh

ui <- fluidPage(
   
   # Application title
   titlePanel("Control sample stage"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        textInput("com", "COM port", value = "COM4"),
        textOutput("is_open_connection"), 
        actionButton("connect", "Open connection"),
        actionButton("disconnect", "Close connection"),
        h4("-----"),
        
        ## USE inkscape svg - to path to specify coordinates for continous motion with a selected speed
        # http://www.inkscapeforum.com/viewtopic.php?t=11228
        
        # actionButton("set_current_asX0Y0", "Set current position as X0Y0 - zero of coordinate system"), # not implemented
        # 
        textInput("move_by_xy",
                     "Move sample by so many mm: X, Y",
                     value = "-1, 1"),
        actionButton("move_now_but", "Move now"), # not implement
        
        h4("-----"),
        numericInput("distance_between_dots",
                     "Specify distance between dots (both x and y) in mm",
                     value = 1),
        numericInput("xyRange",
                     "specify range of mapping (range of total x and y movement) in mm",
                     value = 15),
        numericInput("time_to_stay_in_each_dot",
                     "Time to stay in each dot (in sec)",
                     value = 10),
        numericInput("spectrum_collection_time", 
                  "Time setup in Andor Solis for specrum collection (in sec). 
                  Should be at least 5 seconds less than time of stay in one dot", 
                  value = 5),
        
        textInput("coordinates_of_save_button_for_mouse",
                  "Specify coordinates of 'save' button on Andor Solis",
                  value = "80, 100"),
        
       # actionButton("stop", "Stop"),
        
        h4("(will move in dot by dot pattern,
                     starting with present position. First go up, then right, then donw, then right, then up, etc."),
        actionButton("do_mapping_but", "Execute mapping") # not implement
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("plot_dots")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  values <- reactiveValues()
  
  library(serial)
  library(tidyverse)
  library(stringr)
  library(rMouse)
  # library(rJava)                     # load package
  # .jinit()                           # this starts the JVM
  # jRobot <- .jnew("java/awt/Robot")  # Create object of the Robot class
  # 
  
  source("connection.R", local = T)
   
  source("move_by_xy.R", local = T) 
  source("mapping.R", local = T)
}

# Run the application 
shinyApp(ui = ui, server = server)

