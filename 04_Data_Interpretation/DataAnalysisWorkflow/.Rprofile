# Opens Start_Here.R when this folder is opened as a project in RStudio. Nothing else.
if (interactive() && requireNamespace("rstudioapi", quietly = TRUE))
  setHook("rstudio.sessionInit", function(newSession) {
    if (newSession && file.exists("Start_Here.R")) rstudioapi::navigateToFile("Start_Here.R")
  }, action = "append")
