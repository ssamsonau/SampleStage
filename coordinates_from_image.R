
image_xy <- reactive({
  inFile <- input$file1
  
  if (is.null(inFile)){
    imagePath <- "image_examples/drawing-1.png"
  }else{
    imagePath <- inFile$datapath
  }
  
  # https://cran.r-project.org/web/packages/imager/vignettes/gettingstarted.html
  library(imager)
  #img <- imager::load.image("image_examples/drawing-1.png")
  img <- imager::load.image(imagePath)
  img <- channel(img, 1)
  img <- 1-img
  plot(img, asp = 1)  
  
  
  img <- threshold(img)
  plot(img)
  coord <- which(img, arr.ind = T)
  
  library(tidyverse)
  xy <- coord[ , 1:2] %>%
    as_tibble
  
  #range(xy)
  #browser()
  
  conversion <- diff(range(xy$dim1)) / input$desired_x_range
  
  
  xy <- xy %>%
    mutate(dim1 = dim1 - min(dim1), 
           dim2 = dim2 - min(dim2)) %>%
    mutate(dim1 = dim1/conversion, 
           dim2 = dim2/conversion) %>%
    mutate(dim1 = round(dim1, digits = 3), 
           dim2 = round(dim2, digits = 3)) %>% # round down to 1 micron
    distinct()

  xy
})


output$image <- renderPlot({
  if(is.null(image_xy()))
    return()
  
  xy <- image_xy()
  
  plot(x = xy$dim1, y = xy$dim2, asp = 1,
       xlab = "x (mm)", ylab = "y (mm)"
       )
})

output$image_table <- DT::renderDataTable({
  if(is.null(image_xy()))
    return()
  
  image_xy()
})

observeEvent(input$move_by_picture_but, {
  if(is.null(image_xy()))
    return()
  
  xy <- image_xy()
  
  # now just do absolute positioning and go between dots
  
  withProgress(message = 'Working..', value = 0, {
    
    write.serialConnection(con, "G90"); Sys.sleep(1) #absolute positioning
    write.serialConnection(con, "G92X0Y0"); Sys.sleep(1)  # X0Y0 setup
    write.serialConnection(con, paste0("G1F", input$speed*60)); Sys.sleep(1) # set speed
    
    #browser()
    current_N <- 0
    
    distance <- function(xy0, xy1){
      sqrt((xy1[1] - xy0[1])^2 + (xy1[2] - xy0[2])^2)
    }
    
    xy_current <- c(0, 0)
    
    #for(i in 1:nrow(xy)){
    for(i in 1:10){

      x <- xy[i, 1] %>% as.numeric()
      y <- xy[i, 2] %>% as.numeric()
    
      current_N <- current_N + 1
      incProgress(1/nrow(xy) , detail = paste0("Moving to dot", current_N, " out of ", 
                                               nrow(xy),  "\n Target position: x = ", x, ", y =", y, "\n"))
    
      time_takes_to_move <- distance(xy[i, ] %>% as.numeric(), xy_current)/input$speed
      
      
      write.serialConnection(con, 
                             paste0("G1X", y, "Y", x)); #Sys.sleep(0.001)  # go to 
      xy_current <- xy[i, ] %>% as.numeric()
      
      Sys.sleep(time_takes_to_move)
      Sys.sleep(input$time_to_stay_in_dot)
    }
    
    
  })
  
  withProgress(message = 'Returning to initial position', value = 0, {
    # return to X0Y0
    write.serialConnection(con, "G1X0Y0")  
  })
  
  
})
