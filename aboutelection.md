# 2016 Presidential Election Data

To give a sense of how you might use this app, I'd like to tell youre a story
about what motivated me to publish it in the first place. It is a good
demonstration of how Mapper can be used as a data mining tool.

Duing the 2016 U.S. Presidential Election, I took streaming data from Twitter
filtered by words related to the election. I pulled about 75,000 tweets over
the course of four hours, and processed them into a graph to visualize this
rather unstructured data. The original goal was to find finer structure in
supporters of one candidate or the other besides "Democrat" or "Republican".
Instead, I found something I think is much more interesting: a spambot network
based in Russia.

This isn't a story of looking for spambots, but one of finding a needle
in a haystack by baling the hay into a few small piles, sitting on them, and
waiting for a pin prick. If you'd like to follow how I found it, you can
recreate the same graph I did by reloading the app and then continuing to read.

One way to use Mapper to identify features of interest in the data set is to
look for "tendrils" in the graph. With the "Spectral" coloring choice, this
particular  graph has several emanating from one largish green node in the main
"body" of the graph. One tendril with two branches stands ou

If you hover over these nodes, you'll see the same three hashtags: #SoundCloud,
#TrumpTrain, and #Trump2016. This is strange: the nodes represent tweets which
are a mix of advertising and political support. Since the nodes are in the
blue-purple spectrum, they also represent tweeters with few friends. Now change the
color filter to followers, and find the same nodes. They are in a similar color
spectrum, which means that they also have few followers. I found it odd that
there should be tweets with the same unusual mix of political and advertising
content, but from users who have very few friends or followers - it seemed
likely they were related in some way.

They probably are related, sort of: I believe they are all bots
created using the same program. They were easy to identify, because it
is possible to filter the data by hashtags to separate it, pull profiles on
those users using Twitter's REST API, and then do a more detailed analysis.
This is easy to do thanks to Paul Pearson's TDAmapper package for R, which
helped create these visualizations.
