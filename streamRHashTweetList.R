streamRHashTweetList <- function(parsedTweets, index){
    hashList <- regmatches(parsedTweets$text[index],gregexpr("#(\\d|\\w)+", parsedTweets$text[index]))
    return(hashList)
}
# Computes list of hashtages from a tweet parsed by parseTweets.
# Args: 
#     parsedTweets (data frame, from parseTweets function)
#     index (an integer, row index in data frame)
# Returns:
#     A list of length 1 of hashtags tweeted

# older version uses regex "#(\\d|\\w)+", which may actually be better.
# another suggestion: "#(\\S+)","Hello! #London is gr8. #Wow")