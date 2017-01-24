# 2016 Presidential Election Data

To give a sense of how you might use this app, I'll relate a story 
about what motivated me to publish it in the first place. It is a good 
demonstration of how Mapper can be used as a data mining tool.

Duing the 2016 U.S. Presidential Election, I took streaming data from Twitter 
filtered by words related to the election. I pulled about 75,000 tweets over 
the course of four hours, and processed them into a graph to visualize this 
rather unstructured data. The original goal was to find finer structure in 
supporters of one candidate or the other besides "Democrat" or "Republican". 
Instead, I found something I think is much more interesting: a spambot network 
based in Russia.

This isn't a story of looking for spambots, but rather one of finding a needle 
in a haystack by baling the hay into a few small piles, sitting on them, and 
waiting for a pin prick. If you'd like to follow how I found it, you can 
recreate the same graph I did by reloading the app and then continuing to read.

One way to use Mapper to identify features of interest in the data set is to 
look for "tendrils" in the graph. This particular  graph has several emanating 
from one largish yellow node in the main "body" of the graph. One tendril stands 
out because its nodes are a bit larger than those in other similar tendrils, 
indicating they represent more tweets.

If you hover over these nodes, you'll see the same three hashtags: #SoundCloud, 
#TrumpTrain, and #Trump2016. This is strange, the nodes represent tweets which 
are a mix of advertising and political support. Since the nodes are in the 
orange spectrum, they also represent tweeters with few friends. Now change the 
color filter to followers, and find the same nodes. They are in a similar color 
spectrum, which means that they also have few followers. I found it odd that 
there should be tweets with the same unusual mix of political and advertising 
content, but from users who have very few friends or followers. I thought it 
pretty unlikely that they knew one another. 

As it turns out, they probably do know one another, sor of: they are all bots 
created using the same program. The spambots were easy to identify, because it 
is possible to select the data from the original data set represented by any 
node to separate it out and then analyze it directly. While that's not yet 
possible with the web app, it's easy to do working locally with the TDAmapper 
package in R which helped create these visualizations.
