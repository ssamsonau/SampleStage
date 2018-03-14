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
        
        numericInput("speed", 
                     "How fast should the stage move (mm/sec)",  # program takes mm/min, so it should be later * 60
                     value = 0.02),
        
        ## USE inkscape svg - to path to specify coordinates for continous motion with a selected speed
        # http://www.inkscapeforum.com/viewtopic.php?t=11228
        
        
        # 
        textInput("move_by_xy",
                     "Move sample by so many mm: X, Y",
                     value = "-0.1, 0.1"),
        actionButton("move_now_but", "Move now"), # not implement
        actionButton("set_current_asX0Y0", "Set current position as X0Y0"), 
        actionButton("return_toX0Y0", "Return to X0Y0"), 
        
        h4("-----"),
        numericInput("distance_between_dots",
                     "Specify distance between dots (both x and y) in mm",
                     value = 0.1),
        numericInput("xyRange",
                     "specify range of mapping (range of total x and y movement) in mm",
                     value = 0.5),

        # numericInput("time_takes_to_move",
        #              "Time it takes to move between dots (in sec)",
        #              value = 2),
        # numericInput("time_to_stay_in_each_dot",
        #              "Time to stay in each dot (in sec)",
        #              value = 10),
        numericInput("spectrum_collection_time", 
                  "Time setup in Andor Solis for specrum collection (in sec)", 
                  value = 5),
        
        textInput("coordinates_of_takeSignal_button_for_mouse",
                  "Specify coordinates of 'Take signal' button on Andor Solis",
                  value = "158, 70"),
        # textInput("coordinates_of_save_button_for_mouse",
        #           "Specify coordinates of 'Save' button on Andor Solis",
        #           value = "84, 70"),
        
       # actionButton("stop", "Stop"),
        
        h4("(will move in dot by dot pattern,
                     starting with present position. First go up, then right, then donw, then right, then up, etc."),
        actionButton("do_mapping_but", "Execute mapping"),
        actionButton("stop_mapping_but", "Interupt (stop) mapping (DOES NOT WORK...")
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

