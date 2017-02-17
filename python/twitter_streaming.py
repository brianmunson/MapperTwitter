# twitter streaming listener
# modified from adilmoujahid.com

import tweepy as ty
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import StreamListener
import os
from dotenv import load_dotenv, find_dotenv


load_dotenv(find_dotenv())
consumer_key = os.environ.get("TW_CONSUMER")
consumer_secret = os.environ.get("TW_CONSUMER_SECRET")
access_token = os.environ.get("TW_ACCESS")
access_token_secret = os.environ.get("TW_ACCESS_SECRET")
auth = ty.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

# class StdOutListener(StreamListener):

#     def on_data(self, data):
#         try:
#             print(data)
#         except:
#             pass #ignore printing errors to console

#         return True

#     def on_error(self, status):
#         print("Error with code: %s", status)
#         return True

#     def on_timeout(self):
#         print("Timeout...")
#         return True

class StdOutListener(StreamListener):

    def __init__(self, api=None):
        super(StdOutListener, self).__init__()
        self.num_tweets = 0

    def on_data(self, data):
        if self.num_tweets < 10000:
            try:
                print(data)
                self.num_tweets += 1
                return True
            except:
                pass
                return True

    def on_error(self, status):
        print("Error with code: %s", status)
        return True

    def on_timeout(self):
        print("Timeout...")
        return True

if __name__ == '__main__':

    l = StdOutListener()
    stream = ty.Stream(auth, l)

    stream.filter(track=["InternetFriendsDay", "GalentinesDay"])

    # stream.filter(track=["string1", "string2"])
    # filters to track by string1, string2. can enter a longer list as well.
    # stop program with Ctrl-C
    # to run, from command line: python file_name.py > twitter_data.text
    # here file_name is the name of the file containing this listener
