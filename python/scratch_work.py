# twitter notebook
# meant as a place to keep scratch work without any other logical place
import geocoder # for translating
import tweepy as ty# for working with Twitter API
import requests # for making requests over the internet
import yweather # for getting WOEIDs
from dotenv import load_dotenv, find_dotenv # for handling environmental variables
import re # for processing Twitter data
import datetime # for working with dates/times
import pandas as pd # data processing/analysis tools

#### for obtaining credentials, presumably stored on Heroku, locally in a .env file
from dotenv import find_dotenv, load_dotenv
load_dotenv(find_dotenv())
consumer_key = os.environ.get("TW_CONSUMER")
consumer_secret = os.environ.get("TW_CONSUMER_SECRET")
access_token = os.environ.get("TW_ACCESS")
access_token_secret = os.environ.get("TW_ACCESS_SECRET")
auth = ty.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = ty.API(auth)

#### yweather get WOEID function. No API keys required.
#### Useful for working with trends by location, which requires WOEID
#### Countries have WOEIDs as well. U.S. : 23424977

def get_WOEID(location):
    client = yweather.Client()
    return(client.fetch_woeid(location))

###### Twitter trends based on location
# basic request we're after:
# GET https://api.twitter.com/1.1/trends/place.json?id=XXXX
# where XXXX = output of woeid fetch call above as an integer.
# used in heroku app for milestone project
# this function may be a little cumbersome: each time it is called it makes an API
# call to get available. Presumably this doesn't change much, so it might be best
# to update this list less frequently.

def get_Twitter_trends(location, api_key_dict = None):
    # for use with openAPI_Key function and dictionary of keys; old
    # consumer_key = api_key_dict["Twitter Consumer"]
    # consumer_secret = api_key_dict["Twitter Consumer Secret"]
    # access_token = api_key_dict["Twitter Access Token"]
    # access_token_secret = api_key_dict["Twitter Access Token Secret"]
    auth = ty.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = ty.API(auth)
    available = api.trends_available()
    if get_WOEID(location):
        if get_WOEID(location) in [item['woeid'] for item in available]:
            return(api.trends_place(int(get_WOEID(location))), location)
        else:
            g = geocoder.google(location)
            if g.latlng:
                closest_trends = api.trends_closest(g.latlng[0], g.latlng[1])
                return(api.trends_place(closest_trends[0]['woeid']), closest_trends[0]['name'])
            else:
                return(api.trends_place(1), "worldwide (invalid location entered)")
    else:
        return(api.trends_place(1), "worldwide (invalid location entered)")

# example
US_trends = get_Twitter_trends("United States")
# returns a tuple of length 2, second item is "United States"
# US_trends[0] is list of length 1
# US_trends[0][0] is dictionary with keys 'locations', 'trends', 'created_at', 'as_of'
US_trends_list = US_trends[0][0]['trends']
# in this case a list of dicts of length 50
# each dict has keys 'tweet_volume', 'url', 'query', 'name', 'promoted_content'
US_trends_df = pd.DataFrame(US_trends_list)
# a pandas dataframe with
US_trends_df.columns
# returns 'name', 'promoted_content', 'query', 'tweet_volume', 'url'
idx = US_trends_df.name.str.contains('^#.*', regex=True)
# gets True/False list for each row, asking if US_trends_df['name'] has a string
# starting with # and ending with anything.
US_hashtags_df = US_trends_df[idx]
# subsetting the trends dataframe
US_hashtags_df_sorted = US_hashtags_df[['name', 'tweet_volume']].sort_values(by=["tweet_volume"],
ascending = False)
# sorts according to tweet volume.

#### getting streaming API stuff set up. pythoncentral.io helped here.
# i still don't totally understand classes though.


from tweepy.streaming import StreamListener

class StdOutListener(StreamListener):

    def on_data(self, data):
        print(data)
        return True

    def on_error(self, status):
        print(status)

if __name__ == '__main__':

    l = StdOutListener()
    consumer_key = os.environ.get("TW_CONSUMER")
    consumer_secret = os.environ.get("TW_CONSUMER_SECRET")
    access_token = os.environ.get("TW_ACCESS")
    access_token_secret = os.environ.get("TW_ACCESS_SECRET")
    auth = ty.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    stream = ty.Stream(auth, l)

    stream.filter(track=["string1", "string2"])
    # filters to track by string1, string2. can enter a longer list as well.
    # stop program with Ctrl-C
    # to run, from command line: python file_name.py > twitter_data.text
    # here file_name is the name of the file containing this listener




# a slightly more complex listener
class StdOutListener(StreamListener):
    """ handles data received from the stream """
    def __init__(self, api=None):
        super(StdOutListener, self).__init__()
        self.num_tweets = 0

    def on_status(self, status):
        # prints text of tweet
        try:
            print("Tweet text "+ status.text)
            print('\n %s %s via %s\n', (status.author.screen_name, status.created_at,
            status.source))
            self.num_tweets += 1
        except:
            # ignore printing errors to console
            pass

        # for hashtag in status.entries['hashtags']:
        #     # prints content of hashtag
        #     print(hashtag['text'])
        # not sure about this. I think I should wait until I get the tweets to process

        return True

    def on_error(self, status_code):
        print("Error with status code %s ", status_code)
        return True # continues listening

    def on_timeout(self):
        print("Timeout...")
        return True # continues listening

def main():
    # credentialing
    consumer_key = os.environ.get("TW_CONSUMER")
    consumer_secret = os.environ.get("TW_CONSUMER_SECRET")
    access_token = os.environ.get("TW_ACCESS")
    access_token_secret = os.environ.get("TW_ACCESS_SECRET")
    auth = ty.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    stream = ty.Stream(auth, StreamWatcherListener(), timeout = None)
    stream.sample() # i think i want to use stream.filter and enter a list of
    # strings to track

if __name__ == '__main__':
    listener = StdOutListener()
    auth = ty.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    stream = Stream(auth, listener)
    stream.filter(track=["string1", "string2"])
    # tracks various strings. here is a good place to feed a list of trends
    # you've gotten from getting those trends.

####
