require(ROAuth)
require(twitteR) # to get trends
require(httr)
require(streamR) # to access streaming api
require(stringr)

# get trends, stream tweets, process into data frame to write to .csv
# for use in app.

### 1. defining functions

hashtagsToChar <- function(hashtagList){
    charVec <- sapply(hashtagList, function(x){ unlist(x$text) })
    chars <- paste(charVec, sep="", collapse=" ")
    return(chars)
}
# Args:
#   A list of hashtags: items of this list are lists of length 2
#   consisting of a hashtag ($text) and its indices ($indices).
# Returns:
#   A string of hashtags separated by spaces.
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

### 2. get trends. stream trends. process and write to a .csv.

consumerKey <- "XXXXXXXXXXXX"
consumerSecret <- "YYYYYYYYYYYYYYYYYYY"
accessToken <- "XXXXXXXXXXXX"
accessSecret <- "YYYYYYYYYYYYYYYYYYY"
# last two also required for twitteR to use getTrends function

# for twitteR, which will be used to getTrends
setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)

# for streamR
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "http://api.twitter.com/oauth/authorize"
# consumerKey <- "XXXXXXXXXXXXX"
# consumerSecret <- "YYYYYYYYYYYYYYYY"
my_oauth <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret, requestURL=requestURL, accessURL=accessURL, authURL=authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
# problem! this step requires a login to Twitter with my credentials
# and for me to then enter a pin to authorize this app. how to avoid?

# twitteR
trends <- getTrends(woeid = "23424977")
# gets trends for U.S.A. gives top 40.

# streamR, using trends from twitteR getTrends call.
tweets <- filterStream(file.name = "", track=trends$name, tweets=100000, oauth = my_oauth)

# tweets <- filterStream(file.name = "", track=trends$name, tweets=20000, oauth = my_oauth)
# Connection to Twitter stream was closed after 204 seconds with up to 9960 tweets downloaded.

# processing tweets into more usable format

tweets_df <- parseTweets(tweets)
# Warning message:
#     In vect[notnulls] <- unlist(lapply(lst[notnulls], function(x) x[[field[1]]][[field[2]]][[as.numeric(field[3])]][[field[4]]])) :
#     number of items to replace is not a multiple of replacement length

# now to add the hashtags to the data frame above.
tweets_r <- readTweets(tweets)
hashtags_list <- lapply(tweets_r, function(x){ x$entities$hashtags })
hashtags <- sapply(hashtags_list, function(x){ hashtagsToChar(x) })
tweets_df$hashtags <- hashtags
tweets_df <- tweets_df[tweets_df$hashtags != ""] #filter those without hashtags

# hashtags_as_list <- sapply(hashtags, function(x){ strsplit(x, split = " ") })
# convertes it to a list of vectors, for use with other functions

# cleaning "data" subdirectory of older files.
now = format(Sys.time(), "%d-%m-%y--%H-%M-%S")
write.csv(tweets_df, file=sprintf("data/%s_tweets.csv", now), row.names = FALSE)

# cleaning out older files
csv_files <- dir("data/", pattern = ".csv") # gets the csv files from the data director
files_info <- sapply(csv_files, function(x) { file.info(file=paste("data/", x, sep="")) })
# creates a matrix with info on the files, including creation times
time_diff <- sapply(files_info["mtime", ], function(x){ Sys.time() - x })
# returns a vector with entries time differences in hours
# between modified time and now, named by the files 
# "created" is not system-independent; unix doesn't keep track of this
files_to_delete <- names(time_diff[time_diff > 48])
# returns a list of files to be deleted.
file.remove(file=paste("data/", files_to_delete, sep=""))
# gets rid of files which were modified more than two days ago.

