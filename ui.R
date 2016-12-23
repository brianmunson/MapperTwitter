require(shiny)
# require(TDAmapper)
# require(igraph)
# require(RColorBrewer)
require(shinythemes)
require(networkD3)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    #theme = shinytheme("slate"),
    # does not seem to work when choosing colourScale
    titlePanel("Mapper Explorer"),
    
    forceNetworkOutput("graph"),
    
    hr(),
    
    fluidRow(
        
        column(3,
               h3("Hashtags"),
               textInput("hashtags", "Enter a comma-separated list
                         of hashtags (e.g. #this, #that, #theother)")
               ),
        column(3,
               h3("Metric"),
               selectInput("metric", "Choose a metric", 
                           c("Euclidean" = "euclidean", "Manhattan" = "manhattan"))
               ),
        column(3,
               h3("Node attributes"),
               selectInput("node_size", "Select node sizing method",
                          c("uniform", "unscaled", "linear", "logarithmic", "square root"),
                          selected = "linear"),
               selectInput("color_filter", "Choose a color filter",
                           c("PC1" = "V1", "PC2" = "V2", "Amount", "Chebyshev", "Fraud" = "Class")),
               selectInput("coloring", "Choose a coloring style", 
                           c("Spectral", "Hot", "Cool", "Blue-Red",
                             "Blues", "Magenta-Green", "Easter"))
               
               ),
        column(3,
               h3("Mapper options"),
               sliderInput("num_intervals", "Number of Intervals",
                           min = 2, max = 50, value = 20, step = 2),
               sliderInput("percent_overlap", "Percent overlap of intervals",
                           min = 10, max = 50, value = 50, step = 5),
               sliderInput("num_bins_when_clustering", "Number of bins for clustering",
                           min = 2, max = 30, value = 10, step = 2),
               selectInput("filter", "Choose a filter", 
                           c("PC1" = "V1", "PC2" = "V2", "Amount", "Chebyshev"))
               )
    )
    
    
))

# see http://shiny.rstudio.com/gallery/file-upload.html for file
# upload option.