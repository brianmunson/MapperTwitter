require(ROAuth)
require(twitteR) # to get trends
require(httr)
require(streamR) # to access streaming api
require(stringr)
require(aws.s3) # for dealing with s3 buckets

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
# will want to store these as environmental variables probably

# for twitteR, which will be used to getTrends
setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)

# for streamR
requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "http://api.twitter.com/oauth/authorize"
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
# this will need to be modified to write to the s3 bucket

# cleaning out older files
csv_files <- dir("data/", pattern = ".csv") # gets the csv files from the data director
# this will need to be modified to the s3 bucket where the files will live
files_info <- sapply(csv_files, function(x) { file.info(file=paste("data/", x, sep="")) })
# creates a matrix with info on the files, including creation times
time_diff <- sapply(files_info["mtime", ], function(x){ Sys.time() - x })
# returns a vector with entries time differences in hours
# between modified time and now, named by the files 
# "created" is not system-independent; unix doesn't keep track of this
# NOTE: your vm running this code might be in a different time zone each time
# the code is run; probably going to want to fix a time zone above rather than
# use Sys.time()
files_to_delete <- names(time_diff[time_diff > 48])
# returns a list of files to be deleted.
file.remove(file=paste("data/", files_to_delete, sep=""))
# gets rid of files which were modified more than two days ago.

###### s3 stuff: reading bucket files, etc.
# in an .Renviron file are some keys, loaded below
aws_access_key_id <- Sys.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
aws_twitter_bucket <- Sys.getenv("AWS_TWITTER_BUCKET")

bucket <- get_bucket(bucket = aws_twitter_bucket, key = aws_access_key_id, secret = aws_secret_access_key)
# gets the bucket "my-bucket" and its contents, which can be accessed like so:
length(bucket)
# gives number of files in the bucket
bucket[1]
# the first file in the bucket
bucket[1]$Contents$Key
# gives the file name as a string.
bucket_files <- sapply(seq(1:length(bucket)), function(i){ bucket[i]$Contents$Key })
# returns exactly what we want: a vector of filenames, which can be fed to the ui
# of our app with as.list(bucket_files)
file_raw <- get_object(bucket_files[1], bucket = aws_twitter_bucket, key = aws_access_key_id, secret = aws_secret_access_key)
# loading the first file as binary
file_df <- read.csv(text=rawToChar(file_raw), header=TRUE, as.is = TRUE, fileEncoding = "latin1")
# this seems to work, at least locally
files_raw <- lapply(bucket_files, function(x){ get_object(x, bucket = aws_twitter_bucket, key = aws_access_key_id, secret = aws_secret_access_key) })
files_df <- lapply(files_raw, function(x){ read.csv(text=rawToChar(x), header=TRUE, as.is = TRUE, fileEncoding = "latin1") })

