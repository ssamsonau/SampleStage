# SampleStage

Shiny app for automatic xy movement control of a stage with a sample.

Application can only work locally as it relies on com-port connection with Arduino

Modes:
  1. Mapping: collect spectra in many places of the sample. User specifies how many dots are needed, and the distance between them. Computer will send directions to Arduino to move stage the stage and then will press "collect" button on spectrometer.
  2. Lasing: mode for defining patterns in photoresist using laser. user uploads a picture with a patter. Program will generate map of pixels to go over and then will move the stage to corresponding coordinates. User can specify the speed of motion and how long to stay in each dot.
