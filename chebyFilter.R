chebyFilter <- function(dist){
  distMat <- as.matrix(dist)
  return(apply(distMat, 2, max))
}
# Function which creates L^infty centrality filter for use with
# TDAmapper
# Args:
#   dist object (or matrix of distances)
# Returns:
#   vector whose ith entry is the max distance between the ith point
#   and another point in the data set.