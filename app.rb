# -*- coding: utf-8 -*-
require 'pp'
require 'yaml'
require 'bundler'
Bundler.require

config = YAML.load_file('config.yml')

Pushover.configure do |pushover_config|
  pushover_config.user   = config["user_token"]
  pushover_config.token  = config["app_token"]
  pushover_config.device = config["device"]
end

SOUND    = config["sound"]
PRIORITY = config["priority"]

EventMachine::run do
   userstream = {
    :host => "userstream.twitter.com", 
    :path => "/2/user.json?include_followings_activity=true",
    :ssl => true, 
    :oauth => {
      :consumer_key    => config["consumer_key"],
      :consumer_secret => config["consumer_secret"],
      :access_key      => config["access_token"],
      :access_secret   => config["access_secret"]
    }
  }

  stream = Twitter::JSONStream.connect(userstream)

  stream.each_item do |item|
    data = Yajl::Parser.parse(item)
    # pp data
    if data["event"]
      source = data["source"]
      target = data["target"]
      object = data["target_object"]
      case data["event"]
        when "favorite"
          puts "@%s (→☆) @%s: %s" % [source["screen_name"], object["user"]["screen_name"], object["text"]]

        Pushover.notification(
                              message:  "@%s (→☆) @%s: %s" % [source["screen_name"], object["user"]["screen_name"], object["text"]],
                              title:    "kosenconf080tokyo",
                              url:      '',
                              sound:    SOUND,
                              priority: PRIORITY,
                              )

      end
    end
  end

  stream.on_error do |message|
    exit
  end
end



