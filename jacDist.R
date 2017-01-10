jacDist <- function(a,b){
    if(length(union(a,b))==0){
        distance <- 0
    }
    else{
        distance <- 1-length(intersect(a,b))/length(union(a,b))
    }
    return(distance)
}
# Computes Jaccard distance.
# Args:
#   two vectors
# Returns:
#   numeric between 0 and 1 