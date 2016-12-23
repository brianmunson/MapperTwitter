library(shiny)
require(TDAmapper)
require(igraph)
require(RColorBrewer)
require(shinythemes)
require(networkD3)
require(colorRamps)

# source(script and location) for sourcing custom scripts called 
# upon here.

setwd("~/Documents/R/Shiny/App-1")
data <- read.csv("cc_samp_norm.csv", header = TRUE, as.is = TRUE)
color_func_spec <- colorRampPalette(c("red", "orange", "yellow", "green", "blue", "purple"))
color_func_hot <- colorRampPalette(c("red", "orange", "yellow"))
color_func_cool <- colorRampPalette(c("green", "blue", "purple"))
color_func_blrd <- colorRampPalette(c("blue", "red"))
color_func_blues <- colorRampPalette(c("light blue1", "sky blue1", "royal blue1", "blue1", "dark blue"))
color_func_mggr <- colorRampPalette(c("magenta", "green"))
color_func_easter <- colorRampPalette(c("indian red1", "light salmon1", "khaki1", "pale green1", "light blue1", "orchid1"))
color_list <- list(color_func_spec, color_func_hot, color_func_cool, 
                   color_func_blrd, color_func_blues, color_func_mggr,
                   color_func_easter)
names(color_list) <- c("Spectral", "Hot", "Cool", "Blue-Red",
                       "Blues", "Magenta-Green", "Easter")
# probably should just write a short script for this to be sourced.

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    output$mapper_graph <- renderForceNetwork({
        dist_obj <- dist(data, method = input$metric)
        if(input$filter %in% colnames(data)){
            filter_obj <- data[,input$filter]
        }
        else{
            filter_obj <- chebyFilter(dist_obj)
        }
        mapper_object <- mapper1D(distance_matrix = dist_obj,
                                  filter_value = filter_obj,
                                  num_intervals = input$num_intervals,
                                  percent_overlap = input$percent_overlap,
                                  num_bins_when_clustering = input$num_bins_when_clustering)
        mapper_graph <- graph.adjacency(mapper_object$adjacency, mode = "undirected")
        wc <- cluster_walktrap(mapper_graph)
        members <- membership(wc)
        mapper_d3 <- igraph_to_networkD3(mapper_graph, group = members)
        mapper_d3$links <- mapper_d3$links - 1
        # change to zero indexing
        mapper_d3$nodes$name <- as.factor(seq(from = 0, by = 1, 
                                              length.out = length(mapper_d3$nodes$name)))
        # change to zero indexing; name is stored as a factor in original object
        node_sizes <- nodeSizer(mapper_object, "linear")
        mapper_d3$nodes['size'] = node_sizes
        # node sizing. make optional with selectInput box
        if(input$color_filter %in% colnames(data)){
            density_vec <- densMapperVec(mapper_object, data[,input$color_filter])
        }
        else{
            cheby_filter <- chebyFilter(dist_obj)
            density_vec <- densMapperVec(mapper_object, cheby_filter)
        }
        # density_trans <- sapply(density_vec, function(x) { (100/(max(dens_vec) - min(dens_vec)))*(x-min(dens_vec)) })
        color_function <- color_list[input$coloring] #colorRampPalette(c("red", "orange", "yellow", "green", "blue", "purple"))
        colors <- color_function(mapper_object$num_vertices)
        colors <- paste0("'", paste(colors, collapse = "', '"), "'")
        # color_vec <- filterToPalette(dens_vec, 100, reverse=FALSE)
        # colors <- paste0("'", paste(color_vec, collapse = "', '"), "'")
        mapper_d3$nodes['density'] <- density_vec
        # colorings. density determines color.
        forceNetwork(Links = mapper_d3$links, Nodes = mapper_d3$nodes, 
                     Source = 'source', Target = 'target', 
                     NodeID = 'name', Group = 'density',
                     charge = -400, linkDistance = 15, legend = TRUE,
                     Nodesize = 'size', opacity = 0.85, fontSize = 12, 
                     colourScale = networkD3::JS(paste0('d3.scale.ordinal().domain([0,', mapper_object$num_vertices, ']).range([', colors, '])')))
                     # colourScale = JS("d3.scale.ordinal().domain([0,9]).range(['#FFFFCC', '#FFEDA0', '#FED976', '#FEB24C', '#FD8D3C', '#FC4E2A', '#E31A1C', '#BD0026', '#800026'])"))
                     # colourScale = JS("d3.scale.category20c()"))
        
    })
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