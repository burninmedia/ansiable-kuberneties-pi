#! /usr/local/bin/ruby


require 'json'
require 'net/http'

circle_ci_url = ENV['CIRCLE_BUILD_URL']

webhook_url   = ENV['SLACK_WEBHOOK_URL']
commit_comment=`git log -1 --pretty=%B | echo $(cat $1)`
commit_hash   =`git rev-parse --verify HEAD| cut -c1-8`
channel       = ARGV[0] || "devops_platform"
component     = ARGV[1] || "Unknown"
repository    = ARGV[2] || "Unknown"
version       = ARGV[3] || "Unknown"
status        = (ARGV[4] || "pass").to_s.downcase
passed        = (status == 'pass')

color         = passed ? "good" : "danger"
title         = passed ? ":yes: #{component}: Build successful" : ":no: #{component}: Build failed"

content = {
    "channel": channel,
    "attachments": [
        {
            "mrkdwn_in": ["text"],
            "color": color,
            "title": title,
            "text": "----",
            "fields": [
              {
                "title": "Commit Comment",
                "value": commit_comment
              },
              {
                "type": "mrkdwn",
                "title": "Repository",
                "value": "#{repository}",
                "short": true
              },
              {
                "title": "Commit Hash",
                "value": commit_hash,
                "short": true
              },
              {
                "title": "Component",
                "value": component,
                "short": true
              },
              {
                "title": "Build Version",
                "value": version,
                "short": true
              },
              {
                "type": "mrkdwn",
                "value": "<#{circle_ci_url}|View in CircleCI>",
              }
            ]
        }
    ]
}

payload = "payload=#{content.to_json}"

system('curl', '-s', '-S', '--data-urlencode', payload, webhook_url)
