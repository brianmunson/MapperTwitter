densMapperVec <- function(mapper_object, filter){
    return(sapply(seq(1:mapper_object$num_vertices),
                  function(x) { mean(filter[mapper_object$points_in_vertex[[x]]]) }))
}
# A function for returning the mean filter value of points in each
# vertex of a mapper object
# Args: 
#   mapper object: output of mapper1D, mapper2D, or mapper from TDAmapper
#   filter: a filter such as that used to create the mapper object.
#   must have length equal to number of data points
# Returns:
#   a vector of length equal to the number of vertices in the mapper
#   object whose ith value is the mean filter value at the ith vertex
#   when filter is a vector of 0/1s, gives proportion of 1s.

# old code
# densMapperVec <- function(mapper.object,filter){
#     points.in.vertex <- mapper.object$points_in_vertex
#     density.vector <- rep(0, length(points.in.vertex))
#     for(i in 1:length(points.in.vertex)){
#         temp.vector <- rep(0, length(points.in.vertex[[i]]))
#         for(j in 1:length(points.in.vertex[[i]])){
#             temp.vector[j] <- filter[points.in.vertex[[i]][j]]
#         }
#         density.vector[i] <- sum(temp.vector)/length(points.in.vertex[[i]])
#     }
#     return(density.vector)
# }