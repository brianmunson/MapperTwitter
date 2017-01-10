hashTweetList <- function(userTimeline, tweet){
    hashList <- regmatches(userTimeline[[tweet]]$text,gregexpr("#(\\d|\\w)+", userTimeline[[tweet]]$text))
    return(hashList)
}
# Computes list of hashtages from a tweet.
# Args: 
#     userTimeline (from userTimeline function)
#     tweet (an integer)
# Returns:
#     A list of length 1 of hastags tweet