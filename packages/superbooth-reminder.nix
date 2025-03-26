{
  pkgs,
  ...
}:

let
  # Create a wrapped Python environment with all dependencies
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      slack-sdk
      requests
      urllib3
    ]
  );
in
pkgs.writeScriptBin "superbooth-reminder" ''
  #!${pythonEnv}/bin/python
  import os
  import time
  from datetime import datetime, date
  import requests
  from slack_sdk import WebClient
  from slack_sdk.errors import SlackApiError

  # Get Slack API token from environment variable
  SLACK_TOKEN = os.environ.get("SLACK_TOKEN")
  CHANNEL = "#henrik"

  client = WebClient(token=SLACK_TOKEN)

  def calculate_days_until_superbooth():
      today = date.today()

      # Target date (May 8th, 2025)
      target_date = date(2025, 5, 8)

      # Calculate days difference
      days_diff = (target_date - today).days
      return days_diff

  def send_message():
      days = calculate_days_until_superbooth()
      message = f"Days till Superbooth: {days} 🎉"

      try:
          response = client.chat_postMessage(
              channel=CHANNEL,
              text=message
          )
          print(f"Message sent: {message}")
      except SlackApiError as e:
          print(f"Error sending message: {e.response['error']}")

  def should_run():
      # Only run until May 8th, 2025
      today = date.today()
      target_date = date(2025, 5, 8)
      return today <= target_date

  if __name__ == "__main__":
      if not SLACK_TOKEN:
          print("Error: SLACK_TOKEN environment variable not set")
          exit(1)

      if should_run():
          send_message()
      else:
          print("Past May 8th, 2025. Script will not send messages.")
''
