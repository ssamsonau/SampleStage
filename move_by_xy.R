
observeEvent(input$move_now_but, {
  write.serialConnection(con, "G90"); Sys.sleep(1) #relative positioning
  write.serialConnection(con, "G1F1"); Sys.sleep(1) # set speed
  
  move_by <- str_split(input$move_by_xy, ",", simplify = T) %>%
    as.numeric()
  
  command <- paste0("G1",
                    "X", move_by[1], 
                    "Y", move_by[2])
  write.serialConnection(con, command); Sys.sleep(1)
})

