# require(TDAmapper) # omit until cluster_cutoff_at_first_empty_bin is fixed
require(cluster)
require(fastcluster)
require(igraph)
require(ggplot2)
require(shinythemes)
require(networkD3)
# require(colorRamps) #necessary?
require(RColorBrewer) #necessary?
require(ROAuth)
require(twitteR) # may not need
require(httr)
require(streamR)
require(stringr) # may not need
# for twitter and parsing strings
require(wordcloud)

source("mapper1D.R") #temp until TDAmapper updated
source("cluster_cutoff_at_first_empty_bin.R") # temp until TDAmapper updated. This function needed editing to fix an error.
#
source("nodeSizer.R")
source("densMapperVec.R")
source("colorPaletteList.R")
source("vertexSelector.R")
source("chebyFilter.R")
source("jacDist.R")
source("twoDist.R")
source("twoDistAlt.R")
source("twoMultiDist.R")
source("distMatrix.R")
source("hashSelector.R") # has a "subset" "intersect" option, implement for user?
source("streamRHashTweetVec.R")
source("streamRHashTweetList.R")
source("hashTweetList.R")
source("hashTopNList.R")
source("tweetsData.R")


### choosing a data set with a drop-down menu
#data_sets <- dir("data/", pattern = ".csv") # a list of .csv files available
# does not appear to work correctly.

### trying to get multiple datasets working
#
Elec2016 <- read.csv(file=file.path("data", "Election2016.csv"), header = TRUE,
                                                as.is = TRUE, fileEncoding="latin1")
Election2016 <- tweetsData(Elec2016)
Inaug2017 <- read.csv(file=file.path("data", "Inauguration2017.csv"), header = TRUE,
                                                    as.is = TRUE, fileEncoding="latin1")
Inauguration2017 <- tweetsData(Inaug2017)
WomMarch2017 <- read.csv(file=file.path("data", "WomensMarch2017.csv"), header = TRUE,
                                                as.is = TRUE, fileEncoding="latin1")
WomensMarch2017 <- tweetsData(WomMarch2017)
#
###

### when all else fails, this will produce the right thing
# it is the same as the next block, which uses a function to do this stuff.
#
# twitter_df <- read.csv(file=file.path("data", "Election2016.csv"), header = TRUE,
#                      as.is = TRUE, fileEncoding="latin1")
# 
# # all data will be in relative path.
# # above file is a sample of tweetsAConcat from twitterHashProject
# # fileEncoding = "latin1" to help prevent "invalid multibyte string" errors
# 
# tweetsHashList <- streamRHashTweetVec(twitter_df)
# topHashes <- hashTopNList(tweetsHashList, 20)
# hashSelected <- hashSelector(tweetsHashList, topHashes[[1]], method = "subset")
# data <- twitter_df[hashSelected[[2]], ]
# # subsets the original data frame so that it may be used by mapper.
# hashVecList <- hashSelected[[1]]
###

### trying out new tweetsData function which does the above steps (works)
# 
# twitter_df <- read.csv(file=file.path("data", "Election2016.csv"), header = TRUE,
#                      as.is = TRUE, fileEncoding="latin1")
# twitter_data <- tweetsData(twitter_df)
# data <- twitter_data$df
# hashVecList <- twitter_data$hashvec
# 
###

# except for the reading of the .csv, most (all?) of the above processing
# should be done outside of this app. for example, even though
# hashSelector takes a method argument, you could still allow the user
# to utilize it by doing all possible computations ahead of time
# and then allowing them to choose between already computed data. this would
# increase loading time but make the app faster once it loads.
# for instance, for the topnhashes, you could add another data frame
# to load in which simply has the hashtags and their frequencies.
# this could be easily filtered. In fact, the hashTopNList basically
# does this already.

# Define server logic
shinyServer(function(input, output) {
    
    # # # trying to get multiple data sets working

    twitterData <- reactive({
        twitter_data_list <- get(isolate(input$dataset))
    })

    data <- reactive({
        tweets_df <- twitterData()$df
    })

    hashVecList <- reactive({
        hash_vec_list <- twitterData()$hashvec
    })

    distMat <- reactive({
        dist_obj <- distMatrix(get(input$metric), hashVecList())
    })

    # # #
    
    distMat <- reactive({
        dist_obj <- distMatrix(get(isolate(input$metric)), hashVecList())
    })
    
    filterObj <- reactive({
        if(input$filter %in% colnames(data())){
            filter_obj <- log(data()[,isolate(input$filter)] + 1)
            # perhaps variance normalize?
        }
        else{
            filter_obj <- chebyFilter(distMat())
        }
    })
    
    mapperObj <- reactive({
        mapper_object <- mapper1D(distance_matrix = distMat(),
                                  filter_value = filterObj(),
                                  num_intervals = isolate(input$num_intervals),
                                  percent_overlap = isolate(input$percent_overlap),
                                  num_bins_when_clustering = isolate(input$num_bins_when_clustering))
    })
    
    output$graph <- renderForceNetwork({
        input$mapper_button
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
        if(input$color_filter %in% colnames(data())){
            density_vec <- densMapperVec(mapperObj(), data()[,input$color_filter])
        }
        else{
            cheby_filter <- chebyFilter(distMat())
            density_vec <- densMapperVec(mapperObj(), cheby_filter)
            # currently unimplemented
        }
        color_function <- colorPaletteList(input$coloring)
        colors <- color_function(mapperObj()$num_vertices) # vector of hex characters for 
        # colors, e.g. "#FF0000" "#FF1500" #FF2A00" ...
        colors <- paste0("'", paste(colors, collapse = "', '"), "'") # a string of the 
        # above, e.g. " '#FF000', '#FF1500', '#FF2A00', ... "
        mapper_d3$nodes['density'] <- density_vec
        # colorings. density determines color.
        hashtags_in_vertex <- lapply(mapperObj()$points_in_vertex, function(v) { unique(unlist(hashVecList()[v])) })
        hashtag_vec <- sapply(sapply(hashtags_in_vertex, as.character), paste0, collapse=", ")
        hashtags <- paste0("V", 1:mapperObj()$num_vertices, ": ", hashtag_vec)
        mapper_d3$nodes['hashtags'] = hashtags
        # hashtags to appear on hover.
        forceNetwork(Links = mapper_d3$links, Nodes = mapper_d3$nodes, 
                     Source = 'source', Target = 'target', 
                     NodeID = 'hashtags', Group = 'density',
                     charge = -150, linkDistance = 10, legend = FALSE,
                     Nodesize = 'size', opacity = 0.85, fontSize = 12, 
                     zoom = TRUE, 
                     colourScale = JS(paste0('d3.scale.ordinal().domain([0,', mapperObj()$num_vertices, ']).range([', colors, '])')))
                     
    })
    
    # wordcloud section
    # for making hashtag wordcloud
    wordcloud_rep <- repeatable(wordcloud)
    # makes wordcloud consistent throughout session
    
    # topHashDF <- reactive({
    #     as.data.frame(twitterData()$tophash)
    # })
    
    output$hashcloud <- renderPlot({
        hashtagcloud <- wordcloud_rep(words = names(twitterData()$tophash),
                                      freq = 100*twitterData()$tophash/sum(twitterData()$tophash),
                                      scale = c(5,1),
                                      min.freq = input$freq,
                                      colors = colorPaletteList("Skyblue")(8),
                                      random.color = FALSE)
    }, bg = "transparent")
    
    kmedioids <- eventReactive(input$go_clust, { 
        pam(distMat(), input$num_clusters, cluster.only = TRUE)
    })
    
    clusters <- reactive({
        factor(kmedioids(), levels=unique(kmedioids()))
    })
    
    output$clusterplot <- renderPlot({
        qplot(log(followers_count +1), log(friends_count + 1), data=data(), 
              color= clusters(), xlab="Followers (log-scaled)", ylab="Friends (log-scaled)",
              main="Tweets plotted by followers vs. friends\n Colored by cluster")
        
    })
    # finding right scale is difficult. too small and it's displeasing, but
    # too large and some words won't print because they are too large. is
    # there a way to auto-scale?
    

    
    # output$hashcloud <- reactive({
    #     renderPlot({
    #         hashtagcloud <- wordcloud_rep(words = names(twitterData()$tophash),
    #                       freq = 100*twitterData()$tophash/sum(twitterData()$tophash),
    #                       min.freq = input$freq,
    #                       colors = brewer.pal(8, "Dark2")
    #                       )
    #     })
    # })
    # renderPlot does not work in a reactive expression. Maybe it is automatically
    # reactive, like renderForceNetwork seems to be.
    
})

# try to cut down amount of code in renderForceNetwork
# something is weird about the legend for the colors. it looks like
# it always has a 0 to number of vertices as part of the lowest color
# band. may have to investigate the javascript a bit closer for this.