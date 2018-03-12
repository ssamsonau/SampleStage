# https://cran.r-project.org/web/packages/imager/vignettes/gettingstarted.html
library(imager)
img <- imager::load.image("image_examples/drawing-1.png")
img <- channel(img, 1)
img <- 1-img
plot(img)
#img <- grayscale(img)

img <- threshold(img)
plot(img)
coord <- which(img, arr.ind = T)

library(tidyverse)
xy <- coord[ , 1:2] %>%
  as_tibble

range(xy)

desired_x_range <- 1 # in mm
conversion <- range(xy)[1]/desired_x_range


xy <- xy %>%
  mutate(dim1 = dim1 - min(dim1), 
         dim2 = dim2 - min(dim2)) %>%
  mutate(dim1 = dim1/conversion, 
         dim2 = dim2/conversion) %>%
  mutate(dim1 = round(dim1, digits = 3), 
         dim2 = round(dim2, digits = 3)) %>% # round down to 1 micron
  distinct()

plot(x = xy$dim1, y = xy$dim2, asp = 1)
# now just do absolute positioning and go between dots