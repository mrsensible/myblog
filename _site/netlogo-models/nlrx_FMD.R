Sys.setenv(JAVA_HOME= "/usr/lib/jvm/java-11-openjdk-amd64")


library(nlrx)
library(ggplot2)
library(gganimate) # devtools::install_github('thomasp85/gganimate') - if you have troubles installing gganimate, you most likely also need to install gifski as system dependency

# Windows default NetLogo installation path (adjust to your needs!):
netlogopath <- file.path("/home/hyesop/NetLogo 6.0.4")
outpath <- file.path("/home/hyesop/github/myblog/netlogo-models")

## Step1: Create a nl obejct:
nl <- nl(nlversion = "6.0.4",
         nlpath = netlogopath,
         modelpath = file.path(outpath, "Hyesop Shin_FMD.nlogo"),
         jvmmem = 1024)



# Define experiment
nl@experiment <- experiment(expname = "nlrx_spatial",
                            outpath = outpath,
                            repetition = 1,
                            tickmetrics = "true",
                            idsetup = "setup",
                            idgo = "go",
                            runtime = 100,
                            metrics = c("precision %infected 3"),
                            metrics.turtles = list("turtles" = c("who", "pxcor", "pycor")),
                            metrics.patches = c("pxcor", "pycor", "pm10"),
                            constants = list(#"temperature" = "\"sheep-wolves-grass\"",
                              "temperature" = -10,
                              "Farm-Density" = 30,
                              #"highway-effect" = "\"highway\"",
                              "cure-rate" = 50,
                              "prob-of-infection" = 60
                              )
)

# Attach simdesign simple using only constants
nl@simdesign <- simdesign_simple(nl=nl,
                                 nseeds=1)

# Run simulations and store output in results
results <- run_nl_all(nl = nl)



# Attach results to nl object:
setsim(nl, "simoutput") <- results

# Report spatial data:
results_unnest <- unnest_simoutput(nl)


# Split tibble into turtles and patches tibbles and select each 10th step:
results_unnest_turtles <- results_unnest %>%
  dplyr::filter(agent=="turtles") %>%
  dplyr::filter(`[step]` %in% seq(10,80,10))
results_unnest_patches <- results_unnest %>%
  dplyr::filter(agent=="patches") %>%
  dplyr::filter(`[step]` %in% seq(10,80,10))

# Create facet plot:
ggplot() +
  facet_wrap(~`[step]`, ncol=4) +
  coord_equal() +
  geom_tile(data=results_unnest_patches, aes(x=pxcor, y=pycor, fill=factor(pcolor))) +
  geom_point(data=results_unnest_turtles, aes(x = pxcor, y = pycor, color = breed), size=1) +
  #scale_fill_manual(breaks=c("35", "55"), values = c("35" = "#D9AF6B", "55" = "#68855C")) +
  #scale_color_manual(breaks=c("sheep", "wolves"), values = c("sheep" = "beige", "wolves" = "black")) +
  guides(fill=guide_legend(title="LandCover")) +
  theme_minimal() +
  ggtitle("Output maps of each 10th simulation tick")




# Split tibble into turtles and patches tibbles:
results_unnest_turtles <- results_unnest %>%
  dplyr::filter(agent == "turtles")
results_unnest_patches <- results_unnest %>%
  dplyr::filter(agent == "patches")

# Create an animated plot, using the step column as animation variable
p1 <- ggplot() +
  geom_tile(data=results_unnest_patches, aes(x=pxcor, y=pycor, fill=factor(pcolor))) +
  geom_point(data=results_unnest_turtles, aes(x = pxcor, y = pycor, group=who, color = breed), size=2) +
 # scale_fill_manual(breaks=c("35", "55"), values = c("35" = "#D9AF6B", "55" = "#68855C")) +
#  scale_color_manual(breaks=c("sheep", "wolves"), values = c("sheep" = "beige", "wolves" = "black")) +
  guides(fill=guide_legend(title="LandCover")) +
  transition_time(`[step]`) +
  coord_equal() +
  labs(title = 'Step: {frame_time}') +
  theme_void()

# Animate the plot and use 1 frame for each step of the model simulations
gganimate::animate(p1, nframes = length(unique(results_unnest_patches$`[step]`)), width=400, height=400, fps=4)
anim_save("FMD.gif")