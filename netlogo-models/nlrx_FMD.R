library(nlrx)
library(ggplot2)
library(gganimate) # devtools::install_github('thomasp85/gganimate') - if you have troubles installing gganimate, you most likely also need to install gifski as system dependency

# Windows default NetLogo installation path (adjust to your needs!):
netlogopath <- file.path("C:/Program Files/NetLogo 6.0.4")
modelpath <- file.path("D:/github/myblog/Hyesop Shin_FMD.nlogo")
outpath <- file.path("D:/github/myblog/netlogo-models")

# Define nl object
nl <- nl(nlversion = "6.0.4",
         nlpath = netlogopath,
         modelpath = modelpath,
         jvmmem = 1024)

# Define experiment
nl@experiment <- experiment(expname = "nlrx_spatial",
                            outpath = outpath,
                            repetition = 1,
                            tickmetrics = "true",
                            idsetup = "setup",
                            idgo = "go",
                            runtime = 100,
                            #metrics = c("precision %infected 3"),
                            #metrics.turtles = list("turtles" = c("who", "pxcor", "pycor")),
                            #metrics.patches = c("pxcor", "pycor", "pcolor"),
                            constants = list(#"temperature" = "\"sheep-wolves-grass\"",
                              "temperature" = -10,
                              "Farm-Density" = 30,
                              "highway-effect" = "\"highway\"",
                              "cure-rate" = 50,
                              "prob-of-infection" = 60,
                              "wash-virus" != "true")
)

# Attach simdesign simple using only constants
nl@simdesign <- simdesign_simple(nl=nl,
                                 nseeds=1)

# Run simulations and store output in results
results <- run_nl_all(nl = nl)






