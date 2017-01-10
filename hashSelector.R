# vector of T/F for whether list item contains
# any elements of a given set
hashSelector <- function(hashTweetsList, hashVec, method="intersect"){
    if(method=="intersect"){
        boolHashSelect <- sapply(hashTweetsList, function(x){ length(intersect(x,hashVec)) !=0 })
        hashTweetsTrue <- hashTweetsList[boolHashSelect]
        # alternately: hashTweetsTrue <- Filter(function(x){ length(intersect(x,hashVec)) !=0 }, hashTweetsList)
    }
    if(method=="subset"){
        boolHashSelect <- sapply(hashTweetsList, function(x){ all(x %in% hashVec) && length(x) != 0})
        hashTweetsTrue <- hashTweetsList[boolHashSelect]
    }
    hashTweetsSelected <- list(hashTweetsTrue, boolHashSelect)
    return(hashTweetsSelected)
}
# Constructs a sub-list of those list elements of a list which
# have non-trivial intersection with a given vector
# Args:
#   A list, a vector, method.
#   method = "intersect" gives TRUE if list item has non-empty
#   intersection with hashVec and FALSE otherwise
#   method="subset" gives TRUE if list item is contained in
#   hashVec and FALSE otherwise
# Returns:
#   A list, first item is sublist of original list, second is Boolean
#   vector which created it.
# Obvious intended use: list of hashtags whose entries are character
# vectors, vector of hashtags of interest (e.g. top 10, etc.). Use
# Boolean vector to subset other filters.

# More restrictive "subset" version: require the hashtags in a tweet list item
# to be a nonempty subset of hashVec. in this case change anonymous function to
# all(x %in% hashVec) && length(x) != 0