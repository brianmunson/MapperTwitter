nodeSizer <- function(mapper_object, method = "linear"){
    node_size_vec <- sapply(mapper_object$points_in_vertex, length)
    uniform <- function(x) { 5 }
    no_scale <- function(x) { x }
    lin_scale <- function(x) { x/min(node_size_vec) }
    log_scale <- function(x) { 4*log(x+1) }
    sqrt_scale <- function(x) { sqrt(x) }
    func_list <- list(uniform, no_scale, lin_scale, log_scale, sqrt_scale)
    names(func_list) <- c("uniform", "unscaled", "linear", "logarithmic", "square root")
    return(sapply(node_size_vec, function(x) { func_list[[method]](x) }))
}
# Creates a vector of node sizes, one for each vertex in mapper object.
# Args:
#   mapper_object: output of mapper1D, mapper2D, or mapper
#   method: how to scale, default is linear, options are
#   "uniform", "unscaled", "linear", "logarithmic", "square root"
# Rewritten from old version below to use with networkD3

# old version, may be better for using with igraph and oridnary plot:

# input mapper.object$points_in_vertex, scale
# output vector of scaled number of points in each vector

# ideas for improvement: based on range of number of data points
# in a given vertex, automatically scale. trouble: how to pick scaling
# function. linear? exponential? logarithmic? all can be good for
# different purposes. would be nice to have a method to choose. that
# could be another parameter

# offer three different methods. linear (fair), logarithmic (good
# at distinguishing small, bad at large), logarithmic (good for 
# distinguishing large, bad for small)

# let m = max of length(points_in_vertex). v num vertices in vertex
# linear formula (fairest in that scaling is linear):
# s(v) = (42/(M-.9))*(v-1) + 1
# logarithmic (good for differentiating between vertices of small size)
# s(v) = 3*log(v) + 3
# logarithmic good for distinguising larger vertices, bad for small
# s(v) = .3*log(v)^2 + .5*log(v) + 1
# needs tweaking to avoid vertices that are too large

# nodeSizer <- function(points_in_vertex, method = "linear"){
#   node_size_vector <- rep(0, length(points_in_vertex))
#   node_size_scaled <- rep(0,length(points_in_vertex))
#   for(i in 1:length(points_in_vertex)){
#     node_size_vector[i] <- length(points_in_vertex[[i]])
#   }
#   M <- max(node_size_vector)
#   if(method=="linear"){
#     for(i in 1:length(points_in_vertex)){
#       node_size_scaled[i] <- ((20/(M-.9))*(node_size_vector[i]-1)+1)
#     }
#   }
#   else if(method=="concave down"){
#     for(i in 1:length(points_in_vertex)){
#       node_size_scaled[i] <- min((3*log(node_size_vector[i])+3),30)
#     }
#   }
#   else if(method=="concave up"){
#     for(i in 1:length(points_in_vertex)){
#       node_size_scaled[i] <- min((.0005*log(node_size_vector[i])^4 + .001*log(node_size_vector[i])^3 + .01*log(node_size_vector[i])^2 + .1*log(node_size_vector[i]) + 1),42)
#     }
#   }
#   return(node_size_scaled)
# }