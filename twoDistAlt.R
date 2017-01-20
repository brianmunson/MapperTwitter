twoDistAlt <- function(a, b, n=20){
    m <- max(length(a), length(b))
    i <- length(intersect(a,b))
    distance <- 1/2^i - 1/2^m + 1/2^n
    return(distance)
}
# Computes a similarity measure between two sets
# Args:
#   two vectors a and b, and a positive integer n. a and b represent
#   sets, and they are subsets of some larger set of cardinality n.
# Returns:
#   a measure of distance between a and b
# Not meant to be used to compute the distance between a point 
# and itself. This could be easily modified but the current use
# of this distance function is limited and this makes it not worth
# the time to beef it up in this way.
#
# for notes on some properties of a related distance function, see
# the related twoDist.R.
# 
# Use case: A tweet can be summarized as a vector of the hashtags
# used in that tweet. As we can actually distinguish between two
# tweets by other means even though the hashtags (or the tweet) may
# be identical, we don't wish to consider such tweets to be equal.
# So in this case a and b are vectors of hashtags, considered as sets.
# (repeats not counted). In the current application there is a finite
# set of hashtags used by the popultaion whose interpoint distances
# are being computed, and this is the parameter n.