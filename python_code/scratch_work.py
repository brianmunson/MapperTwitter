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
