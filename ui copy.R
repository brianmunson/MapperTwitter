require(shiny)
# require(TDAmapper)
# require(igraph)
# require(RColorBrewer)
require(shinythemes)
require(networkD3)

shinyUI(fluidPage(theme = "bootstrap.css",
    # does not seem to work when choosing colourScale
    titlePanel("twitterMapper"),
    
    sidebarLayout(
        sidebarPanel(
            tags$head(tags$style("#graph{height:100vh !important;}")),
            # for getting the plot to take up more of the page.
            h4("Data Set"),
            uiOutput("choose_dataset"),
            h4("Node attributes"),
            selectInput("node_size", "Node sizing method",
                        c("uniform", "unscaled", "linear", "logarithmic", "square root"),
                        selected = "linear"),
            selectInput("color_filter", "Color filter",
                        c("friends" = "friends_count", "followers" = "followers_count",
                          "favorites" = "favourites_count")),
            selectInput("coloring", "Color palette", 
                        c("Spectral", "Hot", "Cool", "Blue-Red",
                          "Blues", "Magenta-Green", "Easter")),
            h4("Metric and filter"),
            selectInput("metric", "Metric", 
                        c("2-dist" = "twoDist", "2-dist-alt" = "twoDistAlt", "2-multidist" = "twoMultiDist",
                          "Jaccard" = "jacDist")),
            selectInput("filter", "Filter", 
                        c("friends" = "friends_count", "followers" = "followers_count",
                          "favorites" = "favourites_count")),
            h4("Mapper parameters"),
            sliderInput("num_intervals", "Number of Intervals",
                        min = 2, max = 50, value = 20, step = 2),
            sliderInput("percent_overlap", "Percent overlap of intervals",
                        min = 10, max = 50, value = 50, step = 5),
            sliderInput("num_bins_when_clustering", "Number of bins for clustering",
                        min = 2, max = 30, value = 10, step = 2),
            width = 3
            
        ),
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("About","twitterMapper is an exploratory data mining tool for streaming Twitter data. It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli, and Singh.\n\n

                         Nodes in the graph represent sets of tweets by various users, and edges indicate nodes share one or more tweets. Hovering over a node will show the list of hashtags used by tweets in that node.\n\n
                         
                         Following the graph from node to node along the edges gives a sense of the continuum of hashtag use in Twitter.\n\n
                         
                         Roughly speaking, the tweets are first gathered into overlapping groups based on a filter, such as number of followers. Next in each grouping a clustering algorithm is performed according to a notion of distance between tweets in that grouping. In this case, the notion of distance is “hashtag” distance."), 
                tabPanel("Graph", forceNetworkOutput("graph"))
                # tabPanel("Table", tableOutput("table"))
            )
            # forceNetworkOutput("graph")
        )
    )
))
    

# tags$style(type = "text/css", "#graph {height: calc(100vh - 80px) !important;}"),
#     
#     
#     forceNetworkOutput("graph"),
#     
#     hr(),
#     
#     fluidRow(
#         
#         # column(3,
#         #        h3("Hashtags"),
#         #        textInput("hashtags", "Enter a comma-separated list
#         #                  of hashtags (e.g. #this, #that, #theother)")
#         #        ),
#         # column(n, ): the sum over n must in one row must equal 12
#         
#         column(4,
#                h3("Node attributes"),
#                selectInput("node_size", "Select node sizing method",
#                            c("uniform", "unscaled", "linear", "logarithmic", "square root"),
#                            selected = "linear"),
#                selectInput("color_filter", "Choose a color filter",
#                            c("friends" = "friends_count", "followers" = "followers_count",
#                              "favorites" = "favourites_count")),
#                selectInput("coloring", "Choose a coloring style", 
#                            c("Spectral", "Hot", "Cool", "Blue-Red",
#                              "Blues", "Magenta-Green", "Easter"))
#                
#         ),
#         
#         column(4,
#                h3("Metric"),
#                selectInput("metric", "Choose a metric", 
#                            c("2-dist" = "twoDist", "Jaccard" = "jacDist")),
#                selectInput("filter", "Choose a filter", 
#                            c("friends" = "friends_count", "followers" = "followers_count",
#                              "favorites" = "favourites_count"))
#                ),
#         
#         column(4,
#                h3("Mapper parameters"),
#                sliderInput("num_intervals", "Number of Intervals",
#                            min = 2, max = 50, value = 20, step = 2),
#                sliderInput("percent_overlap", "Percent overlap of intervals",
#                            min = 10, max = 50, value = 50, step = 5),
#                sliderInput("num_bins_when_clustering", "Number of bins for clustering",
#                            min = 2, max = 30, value = 10, step = 2)
#                )
#     )
#     
#     
# ))
# 
# # see http://shiny.rstudio.com/gallery/file-upload.html for file
# # upload option.