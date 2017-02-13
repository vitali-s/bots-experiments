import os
import time
from slackclient import SlackClient

SLACK_BOT_TOKEN = os.environ.get('SLACK_BOT_TOKEN')
BOT_ID = os.environ.get("SLACK_BOT_COMMON_ID")
AT_BOT = "<@" + BOT_ID + ">"

slack_client = SlackClient(SLACK_BOT_TOKEN)

def handle_command(command, channel):
    slack_client.api_call("chat.postMessage", channel=channel, text=dictionary(command), as_user = True)

def dictionary(phrase):
    return {
        "hi": "Hi there",
        'hello': "Hello Sir!",
    }.get(phrase, "Not sure... Is it correct *" + phrase + "* command?")

def parse_slack_output(slack_rtm_output):
    output_list = slack_rtm_output
    if output_list and len(output_list) > 0:
        for output in output_list:
            if output and 'text' in output and AT_BOT in output['text']:
                return output['text'].split(AT_BOT)[1].strip().lower(), output['channel']
    return None, None

if __name__ == "__main__":
    READ_WEBSOCKET_DELAY = 1

    if slack_client.rtm_connect():
        print("Bot is connected.")

        while True:
            command, channel = parse_slack_output(slack_client.rtm_read())
            if command and channel:
                handle_command(command, channel)
            time.sleep(READ_WEBSOCKET_DELAY)
    else:
        print("Connection failed. Invalid Slack token or bot ID?")


