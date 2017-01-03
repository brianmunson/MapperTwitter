# UNNECESSARY: it seems after all that igraph_to_networkD3 does in
# fact correctly do the indexing, although it is confusing reading
# the code and looking at the objects themselves.
mapperigraphToD3 <- function(mapper_object){
    require(igraph)
    require(networkD3)
    mapper_igraph <- graph.adjacency(mapper_object$adjacency, 
                                    mode = "undirected")
    wc <- cluster_walktrap(mapper_igraph)
    members <- membership(wc)
    mapper_d3 <- igraph_to_networkD3(mapper_igraph, group = members)
    mapper_d3$links <- mapper_d3$links - 1
    # change to zero indexing
    mapper_d3$nodes$name <- as.factor(seq(from = 0, by = 1,
                                          length.out = length(mapper_d3$nodes$name)))
    # change to zero indexing; name is stored as a factor in original object
    return(mapper_d3)
    
}
# Converts mapper_object$adjacency to networkD3 object
# Args: 
#   mapper_object, output of TDAmapper
# Returns:
#   networkD3 object
# to plot resulting network:
# 
