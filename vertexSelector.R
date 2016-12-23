vertexSelector <- function(mapper_object, vertices){
    return(Reduce(union, mapper_object$points_in_vertex[vertices]))
}
# A simple function for returning the data points in a set of
# vertices in a mapper graph.
# Args: 
#   mapper_object: ouutput of mapper1D, mapper2D, or mapper
#   vertices: a vector enumerating those vertices from which to
#   select points in data set
# Returns:
#   a vector whose entries are the rows (i.e. labels for data points)
#   in original data frame. can easily be used to subset the 
#   original data frame for further analysis.

# df[vertexSelector(mapper_object, vertices),] 
# will select all columns of the vertices

# another idea for a script: input is points_in_vertex object, 
# threshold between 0 and 1, and density vector. script would select
# those vertices whose density is above/below a certain threshold
# (maybe need another input: <= or >=) and take their union.

# old code (unnecessarily complicated):
# vertexSelector <- function(points_in_vertex, vec){
#   vertex_list <- rep(0, length(vec))
#   for(i in 1:length(vec)){
#     vertex_list[i] <- points_in_vertex[vec[i]]
#   }
#   vertex_union <- Reduce(union, vertex_list)
#   return(vertex_union)
# }
#
# another idea for a script: input is points_in_vertex object, 
# threshold between 0 and 1, and density vector. script would select
# those vertices whose density is above/below a certain threshold
# (maybe need another input: <= or >=) and take their union.