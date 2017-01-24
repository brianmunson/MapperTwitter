tweetsData <- function(twitter_df){
    tweetsHashList <- streamRHashTweetVec(twitter_df)
    topHashes <- hashTopNList(tweetsHashList, 20)
    hashSelected <- hashSelector(tweetsHashList, topHashes[[1]], method = "subset")
    data <- twitter_df[hashSelected[[2]], ]
    # subsets the original data frame so that it may be used by mapper.
    hashVecList <- hashSelected[[1]]
    return(list(df=data, tophash=topHashes[[2]], hashvec=hashVecList))
    
}
# Packages a subset of the data frame along with its top hashtags.
# Args: 
#   A twitter data frame, the output of parseTweets from streamR
# Returns:
#   A list consisting of a subset of the original data frame with
#   only tweets which have top 20 hashtags, a table of the top hashtags
#   and their frequencies, and a list of the hashtags for use in other function
#   in the mapper Shiny app.