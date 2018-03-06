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
        
        current_N <- current_N + 1
        incProgress(1/N , detail = paste0("Doing dot ", current_N, " out of ", N,  "\n Current position: x = ", x, ", y =", y, "\n"))
        
        #browser()
        command <- paste0("G1",
                          "X", 0, 
                          "Y", step)
        
        write.serialConnection(con, command);
        
        Sys.sleep(input$time_to_stay_in_each_dot)
        
        y <- y + step
        
        
        
        values$df <- values$df %>%
          dplyr::bind_rows(
            tibble(
              x = x,
              y = y
            )
          )
      }
      
      command <- paste0("G1",
                        "X", x + step, 
                        "Y", -y)
      
      write.serialConnection(con, command);
      
      Sys.sleep(input$time_to_stay_in_each_dot)
      
      x <- x + step
      y <- 0
      
      
    }  
  })
  
  
  output$plot_dots <- renderPlot({
    ggplot(values$df) +
      geom_point(aes(x = x, y = y)) +
      xlim(0, input$xyRange) +
      ylim(0, input$xyRange) +
      coord_fixed(ratio = 1)
  })  
})
