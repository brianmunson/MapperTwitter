twoDist <- function(a,b){
    m <- max(length(a),length(b))
    i <- length(intersect(a,b))
    distance <- 1/2^i - 1/2^m
    return(distance)
}
    # Computes a similarity measure between two sets
    # Args:
    #   two vectors a and b
    # Returns:
    #   distance between a and b
# notes
# let d(a,b) denote this distance. d(a,b) = 0 implies a = b. 
# But a = b does not imply d(a,b) = 0. This reflects fact that
# intersect(c("a","a","b"), c("a","b")) is c("a","b")
# distance between an object and itself can be nonzero
# 0 <= d(a,b) < 1
# if a and b have non-empty intersection, d(a,b) < 1/2
# if a and b have empty intersection, not both empty, d(a,b) >= 1/2