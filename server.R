require(TDAmapper)
require(igraph)
require(shinythemes)
require(networkD3)
# require(colorRamps) #necessary?
# require(RColorBrewer) #necessary?
require(ROAuth)
require(twitteR) # may not need
require(httr)
require(streamR)
require(stringr) # may not need
# for twitter and parsing strings

source("nodeSizer.R")
source("densMapperVec.R")
source("colorPaletteList.R")
source("vertexSelector.R")
source("chebyFilter.R")
source("jacDist.R")
source("twoDist.R")
source("distMatrix.R")
source("hashSelector.R") # has a "subset" "intersect" option, implement for user?
source("streamRHashTweetVec.R")
source("streamRHashTweetList.R")
source("hashTweetList.R")
source("hashTopNList.R")

twitter_df <- read.csv("twitter_sample.csv", header = TRUE, 
                       as.is = TRUE, fileEncoding="latin1")
# will be a sample of tweetsAConcat from twitterHashProject
# will have to write separate code to ingest and process it to 
# a nice csv which will read in as a data frame.
# fileEncoding = "latin1" seems to help prevent 
# "invalid multibyte string" errors.
tweetsHashList <- streamRHashTweetVec(twitter_df)
topHashes <- hashTopNList(tweetsHashList, 20)
hashSelected <- hashSelector(tweetsHashList, topHashes[[1]], method = "subset")


# except for the reading of the .csv, most (all?) of the above processing
# should be done outside of this app. for example, even though
# hashSelector takes a method argument, you could still allow the user
# to utilize it by doing all possible computations ahead of time
# and then allowing them to choose between already computed data.
# for instance, for the topnhashes, you could add another data frame
# to load in which simply has the hashtags and their frequencies.
# this could be easily filtered. In fact, the hashTopNList basically
# does this already.


# is this the right function, or is it streamRHashTweetList?
hashVecList <- ???????????????
# needs to be processed

# Define server logic
shinyServer(function(input, output) {
    distMat <- reactive({
        dist_obj <- distMatrix(input$metric, hashVecList)
        # hashVecList needs to be processed from the data
    })
    
    filterObj <- reactive({
        if(input$filter %in% colnames(data)){
            filter_obj <- data[,input$filter]
            # perhaps variance normalize?
        }
        else{
            filter_obj <- chebyFilter(dist_obj)
        }
    })
    
    mapperObj <- reactive({
        mapper_object <- mapper1D(distance_matrix = distMat(),
                                  filter_value = filterObj(),
                                  num_intervals = input$num_intervals,
                                  percent_overlap = input$percent_overlap,
                                  num_bins_when_clustering = input$num_bins_when_clustering)
    })
    
    # d3GraphObj <- reactive({
    #     mapper_graph <- mapperigraphToD3(mapperObj())
    # })
    # currently not working
    
    output$graph <- renderForceNetwork({
        mapper_graph <- graph.adjacency(mapperObj()$adjacency, mode = "undirected")
        wc <- cluster_walktrap(mapper_graph)
        members <- membership(wc)
        mapper_d3 <- igraph_to_networkD3(mapper_graph, group = members)
        # mapper_d3$links <- mapper_d3$links - 1
        # # change to zero indexing
        # mapper_d3$nodes$name <- as.factor(seq(from = 0, by = 1,
        #                                       length.out = length(mapper_d3$nodes$name)))
        # # change to zero indexing; name is stored as a factor in original object
        node_sizes <- nodeSizer(mapperObj(), input$node_size)
        mapper_d3$nodes['size'] = node_sizes
        # node sizing. make optional with selectInput box
        if(input$color_filter %in% colnames(data)){
            density_vec <- densMapperVec(mapperObj(), data[,input$color_filter])
        }
        else{
            cheby_filter <- chebyFilter(distMat())
            density_vec <- densMapperVec(mapperObj(), cheby_filter)
        }
        color_function <- colorPaletteList(input$coloring) #colorRampPalette(c("red", "orange", "yellow", "green", "blue", "purple"))
        colors <- color_function(mapperObj()$num_vertices)
        colors <- paste0("'", paste(colors, collapse = "', '"), "'")
        mapper_d3$nodes['density'] <- density_vec
        # colorings. density determines color.
        forceNetwork(Links = mapper_d3$links, Nodes = mapper_d3$nodes, 
                     Source = 'source', Target = 'target', 
                     NodeID = 'name', Group = 'density',
                     charge = -400, linkDistance = 15, legend = TRUE,
                     Nodesize = 'size', opacity = 0.85, fontSize = 12, 
                     colourScale = networkD3::JS(paste0('d3.scale.ordinal().domain([0,', mapperObj()$num_vertices, ']).range([', colors, '])')))
                     
    })
    # try to cut down amount of code in renderForceNetwork