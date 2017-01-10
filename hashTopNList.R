hashTopNList <- function(hashTweetsList, numberHashes){
    hashTable <- table(unlist(hashTweetsList))
    topHashTable <- sort(hashTable, decreasing=TRUE)[1:numberHashes]
    topHashNames <- names(topHashTable)
    topHashList <- list(topHashNames, topHashTable)
    return(topHashList)
}
# Computes a list of top hashes names and table of their frequencies
# Args:
#   A list of hash tweets, a number of hashes to pick
# Returns:
#   A list of length 2 consisting of a character vector of hash names
#   and a table of the names and their frequencies