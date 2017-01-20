import requests
import os
import tweepy as ty
from tweepy.streaming import StreamListener
import yweather
import pandas as pd
import time
import datetime
import geocoder

from dotenv import find_dotenv, load_dotenv
load_dotenv(find_dotenv())
consumer_key = os.environ.get("TW_CONSUMER")
consumer_secret = os.environ.get("TW_CONSUMER_SECRET")
access_token = os.environ.get("TW_ACCESS")
access_token_secret = os.environ.get("TW_ACCESS_SECRET")

def get_US_Twitter_trends():
	auth = ty.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = ty.API(auth)
    available = api.trends_available()
    return(api.trends_place(23424977))

###### yweather get WOEID function. No API keys required. Only used in a version where user
# can ask for trends in a specific location. current application is US trends only.

def get_WOEID(location):
    client = yweather.Client()
    return(client.fetch_woeid(location))

###### get twitter trends by location.

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

    # if get_WOEID(location):
    #     return(api.trends_place(int(get_WOEID(location))), location)
    # else:
    #     return(api.trends_place(1), "worldwide (invalid location entered)")

    #
    # if get_WOEID(location) in [dict['woeid'] for dict in available]:
    #     return(api.trends_place(int(get_WOEID(location))), location)
    # elif get_WOEID(location):
    #     g = geocoder.google(location)
    #     closest_trends = api.trends_closest(g.latlng[0], g.latlng[1])
    #     return(api.trends_place(closest_trends[0]['woeid'], closest_trends[0]['name']))
    #     # get nearest trends. not crazy about two api calls to get it.
    #     # would be nice if easy way to convert woeid to lat/long
    # else:
    #     return(api.trends_place(1), "location invalid, showing Worldwide")

###### Process Twitter trends output. argument is [0] of output of get_Twitter_trends
# function defined above
# it is possible to have a valid WOEID but for the trends not to exist (maybe
# Twitter consider the location too small or something. A better way to go might
# be to do a "closest" trends instead.

def trends_to_df(trends):
    when_trends = trends[0]['as_of']
    when_datetime = datetime.datetime.strptime(when_trends, "%Y-%m-%dT%H:%M:%SZ")
    when = when_datetime.ctime() + " UTC"
    where = trends[0]['locations'][0]['name']
    # returns date in nice format as string
    trends_name_vol_df = pd.DataFrame(trends[0]['trends'],
    columns = ['name', 'tweet_volume' ])
    return( {'when' : when, 'where' : where, 'trends' : trends_name_vol_df } )
    # only take the name of the trend and its tweet volume
    # return( { "when" : when, "where" : where, "trends" : trends_name_vol_df.dropna() } )
    # drops NaN values for volume; only going to graph those with volume counts
    # alternate version

class StdOutListener(StreamListener):

    def on_data(self, data):
        try:
            print(data)
        except:
            pass #ignore printing errors to console

        return True

    def on_error(self, status):
        print("Error with code: %s", status)
        return True

    def on_timeout(self):
        print("Timeout...")
        return True


# a program to clean up old .csv file. BE CAERFUL!!
# to be run from director of the app, which has a subdirectory "data" which needs periodic
# cleaning

# basic outline: get a list of files satisfying creteria: ends in .csv AND created before 
# a certain time. then delete. this should provide some mild protections against deleting 
# non .csv files.

def data_cleaner():
    # to delete .csv files more than 24 hours old. logs deletions/exceptions in a file_removal.log file.
    now = time.time() # get current time
    files_csv = [item for item in os.listdir("data") if item.endswith(".csv")]
    files_to_delete = [item for item in files_csv if (now - os.path.getctime("data/"+item)) > 3600*48]
    # on the chopping block if more than 48 hours old.
    # this can all be done in one list comprehension but i feel safer filtering for .csv first
    with open("data/file_removal.log","w") as f:
    for item in files_to_delete:
        try:
            os.remove("data/"+item)
        except Exception as e:
            f.write("! The file {} could not be removed:\n".format(item)+
                    "-->{}\n".format(e))
        else:
            f.write("The file {} was removed successfully\n".format(item))
     



if __name__ == '__main__':
	trends = get_US_Twitter_trends()
	trends_list = [trends[0]['trends'][i]['name'] for i in range(len(trends[0]['trends']))]
	l = StdOutListener()
    stream = ty.Stream(auth, l)
    # need to add conditions to StreamListener to make it stop.
    stream.filter(track=trends_list)
    # ADD: process, write to file.
    data_cleaner()
    # repeat. call main() again?

    # ADD
    # get trends.
    # create and open stream tracking such trends
    # process data, write to .csv
    # delete .csv files more than 24 hours old.
    # repeat (unsure how to implement the recursion here. a call to main() again?)
	
