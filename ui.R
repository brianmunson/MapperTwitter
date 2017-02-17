require(shiny)
# require(TDAmapper)
# require(igraph)
# require(RColorBrewer)
require(viridis)
require(shinythemes)
require(networkD3)
require(ggplot2)
require(markdown)
require(aws.s3)

# can you do this in the ui?
bucket <- get_bucket(bucket = Sys.getenv("AWS_TWITTER_BUCKET"), key = Sys.getenv("AWS_ACCESS_KEY_ID"), secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"))
bucket_files <- sapply(seq(1:length(bucket)), function(x){ bucket[x]$Contents$Key })
bucket_files_list <- as.list(bucket_files)
names(bucket_files_list) <- bucket_files

navbarPage("twitterMapper",
           navbarMenu("About",
                      tabPanel("App",
                               includeMarkdown("aboutapp.md")
                               ),
                      tabPanel("Math",
                               includeMarkdown("aboutmath.md")
                               ),
                      tabPanel("Author",
                               includeMarkdown("aboutauthor.md")
                               ),
                      tabPanel("Election 2016",
                               includeMarkdown("aboutelection.md")
                               )
                      ),
           
           tabPanel("Graph",
                  # sidebarLayout(
                      sidebarPanel(
                          tabsetPanel(tabPanel("Data",
                                               h4("Data, metric, and filter"),
                                               selectInput("dataset", "Choose a dataset:", 
                                                           choices = bucket_files_list
# 
#                                                             choices = c("Election 2016" = "Election2016",
#                                                                         "Inauguration 2017" = "Inauguration2017",
#                                                                         "Women's March 2017" = "WomensMarch2017"),
#                                                             selected = "Election2016"
                                                           ),
                                               # uiOutput("choose_dataset"),
                                               # h4("Metric"),
                                               tags$div(title="The metric determines the distance between tweets by the hashtags they share.",
                                                        selectInput("metric", "Metric", 
                                                                    c("2-dist" = "twoDist", "2-dist-alt" = "twoDistAlt", "2-multidist" = "twoMultiDist",
                                                                      "Jaccard" = "jacDist"))
                                               ),
                                               # h4("Filter"),
                                               tags$div(title="The filter function determines initial groupings of the data before they are clustered into the nodes in the graph. Similar filter values (eg. friends) tends to put data points into the same groupings.",
                                                        selectInput("filter", "Filter function", 
                                                                    c("friends" = "friends_count", "followers" = "followers_count",
                                                                      "favorites" = "favourites_count"))
                                               )),
                                      tabPanel("Mapper",
                                               h4("Mapper parameters"),
                                               tags$div(title="The number of initial groupings, grouped by the filter function.",
                                                        sliderInput("num_intervals", "Number of intervals",
                                                                    min = 2, max = 50, value = 18, step = 2)
                                               ),
                                               tags$div(title="The percent overlap between the groupings. Higher numbers tend to create graphs with more edges.",
                                                        sliderInput("percent_overlap", "Percent overlap of intervals",
                                                                    min = 10, max = 50, value = 50, step = 5)
                                               ),
                                               tags$div(title="Once grouped, the data points are clustered. This number helps determine a partial clustering. Higher numbers tend to produce more clusters.",
                                                        sliderInput("num_bins_when_clustering", "Number of bins for clustering",
                                                                    min = 2, max = 30, value = 10, step = 2),
                                                        actionButton("mapper_button", "Create graph")
                                               )
                                      ),
                                      tabPanel("Nodes",
                                               h4("Node attributes"),
                                               tags$div(title="Nodes sized by number of tweets they contain. Larger means more tweets, except for 'uniform', where all nodes have the same size.",
                                                        selectInput("node_size", "Node sizing method",
                                                                    c("uniform", "unscaled", "linear", "logarithmic", "square root"),
                                                                    selected = "unscaled")
                                               ),
                                               tags$div(title="Nodes colored by average of selected attribute by tweeters (eg. friends). Lower in spectrum means fewer, higher means more.",
                                                        selectInput("color_filter", "Color filter",
                                                                    c("friends" = "friends_count", "followers" = "followers_count",
                                                                      "favorites" = "favourites_count"))
                                               ),
                                               tags$div(title="Choose a palette you find pleasing",
                                                        selectInput("coloring", "Color palette", 
                                                                    c("Spectral", "Viridis", "Magma", "Hot", "Cool",
                                                                      "Blues", "Easter", "Grayscale"))
                                               )
                                      ), selected="Nodes"),
                          
                                   
                                   # ),
                          # tags$head(tags$style("#graph{height:100vh !important;}")),
                          # for getting the plot to take up more of the page.
                         
                          
                          
                          
                          
                         
                          
                          
                                   
                          width = 3
                          
                      ),
                      
                      mainPanel(
                          tags$head(tags$style("#graph{height:100vh !important;}")),
                          # does the above affect performance? it seems a little sluggish
                          forceNetworkOutput("graph")
                      )
                          # forceNetworkOutput("graph")
                          # )
                      ),
         tabPanel("Hashtag wordcloud",
                  plotOutput("hashcloud", height = 500, width = 1000),
                  fluidRow(
                      column(12,align = "center",
                             sliderInput("freq", "Minimum proportion %",
                                         min = 0.5, max = 20, value = 2, step = 0.5))
                  )
                  
                  # sidebarLayout(
                  #     sidebarPanel(
                  #         h4("Hashtag proportion"),
                  #         sliderInput("freq","Minimum proportion %",
                  #                     min = 1, max = 20, value = 3, step = 1)
                  #         ),
                  #     mainPanel(
                  #         plotOutput("hashcloud")
                  #     )
                  # )
                  ),
         tabPanel("K-medioids clustering",
                  plotOutput("clusterplot", height=500, width=1000),
                  fluidRow(
                      column(12,align = "center",
                             sliderInput("num_clusters", "Number of clusters",
                                         min = 2, max = 20, value = 10, step = 1), 
                             actionButton("go_clust", "Create plot"))
                  )
         ),
         # tabPanel("Election 2016 data",
         #          includeMarkdown("electiondata.md")),
         # tabPanel("About the author",
         #          includeMarkdown("authorabout.md")),
         
         theme = "bootstrap.css")

# pre-Navbar setup
# shinyUI(fluidPage(theme = "bootstrap.css",
#     # does not seem to work when choosing colourScale
#     titlePanel("twitterMapper"),
#     
#     sidebarLayout(
#         sidebarPanel(
#             tags$head(tags$style("#graph{height:100vh !important;}")),
#             # for getting the plot to take up more of the page.
#             h4("Data Set"),
#             uiOutput("choose_dataset"),
#             h4("Node attributes"),
#             selectInput("node_size", "Node sizing method",
#                         c("uniform", "unscaled", "linear", "logarithmic", "square root"),
#                         selected = "linear"),
#             selectInput("color_filter", "Color filter",
#                         c("friends" = "friends_count", "followers" = "followers_count",
#                           "favorites" = "favourites_count")),
#             selectInput("coloring", "Color palette", 
#                         c("Spectral", "Hot", "Cool", "Blue-Red",
#                           "Blues", "Magenta-Green", "Easter")),
#             h4("Metric and filter"),
#             selectInput("metric", "Metric", 
#                         c("2-dist" = "twoDist", "2-dist-alt" = "twoDistAlt", "2-multidist" = "twoMultiDist",
#                           "Jaccard" = "jacDist")),
#             selectInput("filter", "Filter", 
#                         c("friends" = "friends_count", "followers" = "followers_count",
#                           "favorites" = "favourites_count")),
#             h4("Mapper parameters"),
#             sliderInput("num_intervals", "Number of Intervals",
#                         min = 2, max = 50, value = 20, step = 2),
#             sliderInput("percent_overlap", "Percent overlap of intervals",
#                         min = 10, max = 50, value = 50, step = 5),
#             sliderInput("num_bins_when_clustering", "Number of bins for clustering",
#                         min = 2, max = 30, value = 10, step = 2),
#             width = 3
#             
#         ),
#         # Show a plot of the generated distribution
#         mainPanel(
#             tabsetPanel(
#                 tabPanel("About","twitterMapper is an exploratory data mining tool for streaming Twitter data. It produces a graph using the Mapper algorithm designed by Carlsson, Mémoli, and Singh.\n\n
# 
#                          Nodes in the graph represent sets of tweets by various users, and edges indicate nodes share one or more tweets. Hovering over a node will show the list of hashtags used by tweets in that node.\n\n
#                          
#                          Following the graph from node to node along the edges gives a sense of the continuum of hashtag use in Twitter.\n\n
#                          
#                          Roughly speaking, the tweets are first gathered into overlapping groups based on a filter, such as number of followers. Next in each grouping a clustering algorithm is performed according to a notion of distance between tweets in that grouping. In this case, the notion of distance is “hashtag” distance."), 
#                 tabPanel("Graph", forceNetworkOutput("graph"))
#                 # tabPanel("Table", tableOutput("table"))
#             )
#             # forceNetworkOutput("graph")
#         )
#     )
# ))
    

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