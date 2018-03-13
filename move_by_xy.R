
observeEvent(input$move_now_but, {
  write.serialConnection(con, "G91"); Sys.sleep(1) #relative positioning
  write.serialConnection(con, paste0("G1F", input$speed*60)); Sys.sleep(1) # set speed
  
  move_by <- str_split(input$move_by_xy, ",", simplify = T) %>%
    as.numeric()

  # x and y are switched on actuall device
  command <- paste0("G1",
                    "X", move_by[2], 
                    "Y", move_by[1])
  write.serialConnection(con, command); Sys.sleep(1)
  write.serialConnection(con, "G92"); Sys.sleep(1)  # X0Y0 setup
})

observeEvent(input$set_current_asX0Y0, {
  write.serialConnection(con, "G90"); Sys.sleep(1)  # absolute position mode
  write.serialConnection(con, paste0("G1F", input$speed*60)); Sys.sleep(1) # set speed
  write.serialConnection(con, "G92X0Y0"); Sys.sleep(1)  # X0Y0 setup
})

observeEvent(input$return_toX0Y0, {
  
  write.serialConnection(con, "G90"); Sys.sleep(1)  # absolute position mode
  write.serialConnection(con, paste0("G1F", input$speed*60)); Sys.sleep(1) # set speed
  write.serialConnection(con, "G1X0Y0"); Sys.sleep(1)  # go to X0Y0
})