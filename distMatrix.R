distMatrix <- function(metric, hashVecList){
    n <- length(hashVecList)
    distMat <- matrix(,nrow=n, ncol=n)
    # could do matrix(0,nrow=n, ncol=n) to initialize matrix of zeroes
    # but this may not be what you want
    for(i in 1:n){
        for(j in 1: i){
            distMat[i,j] <- metric(hashVecList[[i]],hashVecList[[j]])
            distMat[j,i] <- distMat[i,j]
        }
    }
    diag(distMat) <- 0
    # some of our "metrics" push equal things apart to avoid clustering errors
    return(distMat)
}
# Computes distance matrix for a list under a given metric
# Args:
#   list of vectors
#   metric
# Returns:
#   Pairwise distance matrix under given metric
# Notes to self: would be easier to use R's much faster dist function
# but it has limited built-in metrics.
# See the proxy package for possibly eliminating this in part. 
# Maybe it has functionality for custom "metrics" (?).