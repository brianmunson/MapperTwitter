require(TDAmapper)
require(igraph)
require(shinythemes)
require(networkD3)
# require(colorRamps) #necessary?
# require(RColorBrewer) #necessary?


source("nodeSizer.R")
source("densMapperVec.R")
source("colorPaletteList.R")
source("vertexSelector.R")
source("chebyFilter.R")
source("mapperigraphToD3.R") #currently not implemented; something not working

data <- read.csv("cc_samp_norm.csv", header = TRUE, as.is = TRUE)

# Define server logic
shinyServer(function(input, output) {
    distMat <- reactive({
        dist_obj <- dist(data, method = input$metric)
    })
    
    filterObj <- reactive({
        if(input$filter %in% colnames(data)){
            filter_obj <- data[,input$filter]
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
        mapper_d3$links <- mapper_d3$links - 1
        # change to zero indexing
        mapper_d3$nodes$name <- as.factor(seq(from = 0, by = 1,
                                              length.out = length(mapper_d3$nodes$name)))
        # change to zero indexing; name is stored as a factor in original object
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
    
    # OLD NON-INTERACTIVE METHOD:
    # output$mapper_graph <- renderPlot({
    #     dist_obj <- dist(data, method = input$metric)
    #     if(input$filter %in% colnames(data)){
    #         filter_obj <- data[,input$filter]
    #     }
    #     else{
    #         filter_obj <- chebyFilter(dist_obj)
    #     }
    #     mapper_object <- mapper1D(distance_matrix = dist_obj,
    #                               filter_value = filter_obj,
    #                               num_intervals = input$num_intervals,
    #                               percent_overlap = input$percent_overlap,
    #                               num_bins_when_clustering = input$num_bins_when_clustering)
    #     mapper_graph <- graph.adjacency(mapper_object$adjacency, mode = "undirected")
    #     
        # if(input$color_filter %in% colnames(data)){
        #     dens_vec <- densMapperVec(mapper_object, data[,input$color_filter])
        # }
        # else{
        #     cheby_filter <- chebyFilter(dist_obj)
        #     dens_vec <- densMapperVec(mapper_object, cheby_filter)
        # }
        # color_vec <- densColorVec(dens_vec, input$num_colors, "Spectral")
        # node_sizes <- nodeSizer(mapper_object$points_in_vertex, "concave down")
        # V(mapper_graph)$size <- node_sizes
        # V(mapper_graph)$color <- color_vec
        # plot(mapper_graph, vertex.label=NA)
        
   # })

    
})

# see http://shiny.rstudio.com/gallery/file-upload.html for file
# upload option.
# think about allowing user to save the image. saveNetwork in the 
# networkd3 package may be of use.