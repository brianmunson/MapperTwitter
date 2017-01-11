twoMultiDist <- function(a,b){
    m <- max(length(a),length(b))
    I <- intersect(a,b)
    aOverI <- a[a %in% I]
    bOverI <- b[b %in% I]
    tablea <- table(aOverI)
    tableb <- table(bOverI)
    i <- sum(pmin(tablea,tableb))
    distance <- 1/2^i - 1/2^m
    return(distance)
}
# Computes a similarity measure between two sets
# Args:
#   two vectors a and b
# Returns:
#   distance between a and b

# handles multiple occurences of a value nicely.
# essentially a multi-set version of length of intersection
# is slow, however, and not clearly an upgrade over the simpler
# twoDist in functionality.
# aOverI: all values of a (including repeats) that appear in a.
# tablea: a table of the values of aOverI (elements of a in I
# and their multiplicities)
# 