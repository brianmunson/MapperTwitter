# tweetsWordcloud workbook.

# starting with a data frame tweets_df = parseTweets(tweets), where
# tweets is the output of filterStream from streamR.

require(streamR)
require(wordcloud) # loads RColorBrewer
require(tm) # for wordcloud
require(NLP) # for wordcloud
require(memoise) # do i need this?

# for R Shiny, to make wordcloud consistent within a session:
# wordcloud_rep <- repeatable(wordcloud)

tweets_df <- parseTweets(tweets)
tweets_r <- readTweets(tweets)
hashtags_list <- lapply(tweets_r, function(x){ x$entities$hashtags })
hashtags <- sapply(hashtags_list, function(x){ hashtagsToChar(x) })
hashtags_string <- paste(hashtags, sep=" ", collapse = "")
# creates a text on which we can do a frequency analysis.
wordcloud::wordcloud(hashtags_string, min.freq = 50, colors =)
# makes a basic wordcloud.
