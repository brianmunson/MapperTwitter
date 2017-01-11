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
source("twoMultiDist.R")
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
data <- twitter_df[hashSelected[[2]], ]
# subsets the original data frame so that it may be used by mapper.
hashVecList <- hashSelected[[1]]

# gives a list vectors of hashtags of length number of rows in data,
# entries are the hashtags associated with a given tweet, filtered.

# except for the reading of the .csv, most (all?) of the above processing
# should be done outside of this app. for example, even though
# hashSelector takes a method argument, you could still allow the user
# to utilize it by doing all possible computations ahead of time
# and then allowing them to choose between already computed data.
# for instance, for the topnhashes, you could add another data frame
# to load in which simply has the hashtags and their frequencies.
# this could be easily filtered. In fact, the hashTopNList basically
# does this already.

# Define server logic
shinyServer(function(input, output) {
    distMat <- reactive({
        dist_obj <- distMatrix(get(input$metric), hashVecList)
    })
    
    filterObj <- reactive({
        if(input$filter %in% colnames(data)){
            filter_obj <- log(data[,input$filter] + 1)
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
            # currently unimplemented
        }
        color_function <- colorPaletteList(input$coloring)
        colors <- color_function(mapperObj()$num_vertices)
        colors <- paste0("'", paste(colors, collapse = "', '"), "'")
        mapper_d3$nodes['density'] <- density_vec
        # colorings. density determines color.
        hashtags_in_vertex <- lapply(mapperObj()$points_in_vertex, function(v) { unique(unlist(hashVecList[v])) })
        hashtag_vec <- sapply(sapply(hashtags_in_vertex, as.character), paste0, collapse=", ")
        hashtags <- paste0("V", 1:mapperObj()$num_vertices, ": ", hashtag_vec)
        mapper_d3$nodes['hashtags'] = hashtags
        # hashtags to appear on hover.
        forceNetwork(Links = mapper_d3$links, Nodes = mapper_d3$nodes, 
                     Source = 'source', Target = 'target', 
                     NodeID = 'hashtags', Group = 'density',
                     charge = -200, linkDistance = 10, legend = FALSE,
                     Nodesize = 'size', opacity = 0.85, fontSize = 12, 
                     colourScale = networkD3::JS(paste0('d3.scale.ordinal().domain([0,', mapperObj()$num_vertices, ']).range([', colors, '])')))
                     
    })
})

# try to cut down amount of code in renderForceNetwork
# something is weird about the legend for the colors. it looks like
# it always has a 0 to number of vertices as part of the lowest color
# band. may have to investigate the javascript a bit closer for this.