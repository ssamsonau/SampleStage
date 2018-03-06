library(serial)
library(stringr)


# G90/G91 swithing between relative and abs modes
# G1X0Y0 - return to zero position
# G1F1 - set speed (number after F in mm/sec probably)
# M114 - return current position
# G92 - X0Y0 setup


####### Make connection

con <- serialConnection(name = "con1",
                        port = "COM4",
                        translation = "cr",
                        mode = "9600,n,8,1",
                        newline = 1)

open(con); Sys.sleep(1)

write.serialConnection(con, "*IDN?"); Sys.sleep(1)
read.serialConnection(con); Sys.sleep(1)

write.serialConnection(con, "G90"); Sys.sleep(1)
write.serialConnection(con, "G1X-5Y-5F1"); Sys.sleep(1)

Sys.sleep(1)
write.serialConnection(con, "G1X-1.00001525878907Y-1.00001525878907"); Sys.sleep(1)

Sys.sleep(1)
write.serialConnection(con, "G1X0Y0"); Sys.sleep(1)

close(con)
