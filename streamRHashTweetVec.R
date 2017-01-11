streamRHashTweetVec <- function(parsedTweets){
    hashList <- sapply(seq(1:nrow(parsedTweets)), function(x) { streamRHashTweetList(parsedTweets,x) })
    # hashList <- lapply(hashList, function(x){ paste(x, sep="", collapse=" ") })
    # unnecessary. this pastes all hastags into one character. not what we want
    return(hashList)
}
# Args: 
#   A data frame of parsed tweets, the output of streamR's
#   parseTweets function.
# Returns:
#   A list of length equal to the number of tweets whose elements
#   are a vector of the hashtags used in that tweet, possibly empty

########## confusion over proper function
# streamRHashTweetList <- function(parsedTweets, index){
#     hashList <- regmatches(parsedTweets$text[index],gregexpr("#(\\d|\\w)+", parsedTweets$text[index]))
#     return(hashList)
# }
# # Computes list of hashtages from a tweet parsed by parseTweets.
# # Args: 
# #     parsedTweets (data frame, from parseTweets function)
# #     index (an integer, row index in data frame)
# # Returns:
# #     A list of length 1 of hashtags tweeted
# 
# streamRHashTweetVec <- function(parsedTweets){
#     hashList <- sapply(seq(1:nrow(parsedTweets)), function(x) { streamRHashTweetList(parsedTweets,x) })
#     # hashList <- lapply(hashList, function(x){ paste(x, sep="", collapse=" ") })
#     # unnecessary. this pastes all hastags into one character. not what we want
#     return(hashList)
# }
# # Computes a list of vectors of hashtags, one for each user
# # Args:
# #    parsedTweets (a data frame, usually result of parseTweets
# #    but also possibly result of aggregate on result of parseTweets)
# # Returns:
# #    List whose elements are character vectors of hashtags
