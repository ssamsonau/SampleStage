values$STOPIT <- F

observeEvent(input$do_mapping_but,{
  
  if(is.null(check_connection()))
    return(NULL)
  
  con <- values$con
  
  
  write.serialConnection(con, "G91"); Sys.sleep(0.1) #relative positioning
  write.serialConnection(con, paste0("G1F", input$speed*60)); Sys.sleep(1) # set speed
  
  step <- input$distance_between_dots
  
  N <- round(input$xyRange / step)
  N <- N*N
  
  #browser()
  x <- y <- 0
  values$df <- tibble(
    x = 0,
    y = 0
  )
  
  current_N <- 0
  
  #Sys.sleep(input$spectrum_collection_time * 1.2)
  
  #browser()
  
  withProgress(message = 'Moving', value = 0, {
    
    goingUpOrDown <- 1
    time_takes_to_move <- step/input$speed
    
    while(x < input$xyRange + step * 0.5){
      
      while(between(y, -step * 0.5, input$xyRange + step * 0.5)){
        
        if (values$STOPIT) {
          return()
        }
        
        current_N <- current_N + 1
        incProgress(1/N , detail = paste0("Doing dot ", current_N, " out of ", N,  "\n Current position: x = ", x, ", y =", y, "\n"))
        
        #browser()
        ## r program takes only right part of scren. 
        ## Andor solis in background open to full screen. 
        ## Move mouse to "take spectrum" button and press it
        ## Andor solis should be set up (time of collection etc.) before process starts
        
        rMouse::delay(100)
        #rMouse::move(20, 20)
        #rMouse::left()
        #rMouse::pos()
      
        #based on implementation of rMouse::specialKey(), 
        # another option - see https://stackoverflow.com/questions/19724305/can-i-control-the-mouse-cursor-from-within-r
        # list of vk keys codes https://stackoverflow.com/questions/15313469/java-keyboard-keycodes-list
        #move(845,98)
        
        
        ## Press button to take signal
        xy_take <- input$coordinates_of_takeSignal_button_for_mouse
        xy_take <- str_split(xy_take, ",", simplify = T) %>%
          as.numeric()
        
        rMouse::move(xy_take[1], xy_take[2])
        
        left()
        Sys.sleep(input$spectrum_collection_time * 1.2) 
        
        # Now save it
        
        jRobot$keyPress(as.integer(17)) # Ctrl
        #jRobot$keyPress(as.integer(16)) # Shift
        jRobot$keyPress(as.integer(83)) # S
        jRobot$keyRelease(as.integer(17)) # Ctrl
        #jRobot$keyRelease(as.integer(16)) 
        jRobot$keyRelease(as.integer(83)) # S
        # 
        # if(!dir.exists(paste0(getwd(), "/results")))
        #   dir.create(paste0(getwd(), "/results"))
        # 
        #string_to_type <- paste0(getwd(), "/results/", "position ", x, ", ", y) 
        string_to_type <- paste0("position ", round(x, digits = 5), ", ", round(y, digits = 5)) 
        
        string_to_type <- str_replace_all(string_to_type, 
                                           "\\.", "-")
        string_to_type <- paste0(string_to_type)
        rMouse::type(string_to_type) #special characters not allowed
#rMouse::delay(2000)
        
        rMouse::delay(100)
        rMouse::specialKey("ENTER")
        rMouse::delay(200)
        rMouse::specialKey("ENTER")
        rMouse::delay(200)
        #rMouse::delay(100)
        
        
        
        
        values$df <- values$df %>%
          dplyr::bind_rows(
            tibble(
              x = x,
              y = y
            )
          )
        #browser()
        # x and y are switched on actuall device
        
        if(between(y + goingUpOrDown * step, -step * 0.5, input$xyRange + step * 0.5)){
          command <- paste0("G1",
                            "X", goingUpOrDown * step, 
                            "Y", 0)
          
          write.serialConnection(con, command);
          Sys.sleep(time_takes_to_move * 1.2)  
        }
        
        
        y <- y + goingUpOrDown * step
        
      }
      
      if (values$STOPIT) {
        return()
      }
      
      goingUpOrDown <- goingUpOrDown * (-1)
      
      # x and y are switched on actuall device
      command <- paste0("G1",
                        "X", 0, 
                        "Y", step)
      
      write.serialConnection(con, command);
      Sys.sleep(time_takes_to_move * 1.2)
      
      
      x <- x + step
      
      y <- y + goingUpOrDown * step
      
    }  
    values$STOPIT <- FALSE
    
  })
  
  
  observeEvent(input$stop_mapping_but, {
    values$STOPIT <- TRUE
  })
  
  output$plot_dots <- renderPlot({
    ggplot(values$df) +
      geom_point(aes(x = x, y = y)) +
      xlim(0, input$xyRange) +
      ylim(0, input$xyRange) +
      coord_fixed(ratio = 1)
  })  
})
