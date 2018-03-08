observeEvent(input$do_mapping_but,{
  
  
  write.serialConnection(con, "G90"); Sys.sleep(0.1) #relative positioning
  write.serialConnection(con, "G1F1"); Sys.sleep(0.1) # set speed
  
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
  
  Sys.sleep(input$time_to_stay_in_each_dot)
  
  withProgress(message = 'Moving', value = 0, {
    
    while(x + step <= input$xyRange){
      
      while(y + step <= input$xyRange){
        
        if (values$STOPIT) {
          return()
        }
        
        current_N <- current_N + 1
        incProgress(1/N , detail = paste0("Doing dot ", current_N, " out of ", N,  "\n Current position: x = ", x, ", y =", y, "\n"))
        
        #browser()
        command <- paste0("G1",
                          "X", 0, 
                          "Y", step)
        
        write.serialConnection(con, command);
        
        Sys.sleep(input$time_to_stay_in_each_dot)
        
        ## r program takes only right part of scren. 
        ## Andor solis in background open to full screen. 
        ## Move mouse to "take spectrum" button and press it
        ## Andor solis should be set up (time of collection etc.) before process starts
        
        rMouse::delay(100)
        #rMouse::move(20, 20)
        #rMouse::left()
        rMouse::delay(input$spectrum_collection_time)
        #rMouse::pos()
      
        #based on implementation of rMouse::specialKey(), 
        # another option - see https://stackoverflow.com/questions/19724305/can-i-control-the-mouse-cursor-from-within-r
        # list of vk keys codes https://stackoverflow.com/questions/15313469/java-keyboard-keycodes-list
        move(845,98)
        left()
        jRobot$keyPress(as.integer(17)) # Ctrl
        #jRobot$keyPress(as.integer(16)) # Shift
        jRobot$keyPress(as.integer(83)) # S
        jRobot$keyRelease(as.integer(17)) # Ctrl
        #jRobot$keyRelease(as.integer(16)) 
        jRobot$keyRelease(as.integer(83)) # S
        
        rMouse::type(paste("position, ,", x, ", ", y, ".R")) #special characters not allowed
        #rMouse::delay(2000)
        
        rMouse::specialKey("ENTER")
        
        #rMouse::delay(100)
        
        
        y <- y + step
        
        values$df <- values$df %>%
          dplyr::bind_rows(
            tibble(
              x = x,
              y = y
            )
          )
      }
      
      if (values$STOPIT) {
        return()
      }
      
      command <- paste0("G1",
                        "X", x + step, 
                        "Y", -y)
      
      write.serialConnection(con, command);
      
      Sys.sleep(input$time_to_stay_in_each_dot)
      
      x <- x + step
      y <- 0
      
      
    }  
    values$STOPIT <- FALSE
    
  })
  
  
  observeEvent(input$stop, {
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
