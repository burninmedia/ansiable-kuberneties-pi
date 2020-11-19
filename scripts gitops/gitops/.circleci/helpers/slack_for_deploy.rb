#! /usr/local/bin/ruby


require 'json'
require 'net/http'

circle_ci_url = ENV['CIRCLE_BUILD_URL']

webhook_url   = ENV['SLACK_WEBHOOK_URL']
commit_comment=`git log -1 --pretty=%B | echo $(cat $1)`
commit_hash   =`git rev-parse --verify HEAD| cut -c1-8`
channel       = ARGV[0] || "devops_platform"
project       = ARGV[1] || "Unknown"
repository    = ARGV[2] || "Unknown"
environment   = ARGV[3] || "Unknown"
status        = (ARGV[4] || "pass").to_s.downcase
passed        = (status == 'pass')

rancher_url   = "https://rancher.wowza.com/"

color         = passed ? "good" : "danger"
title         = passed ? ":yes: #{project}: Deploy successful" : ":no: #{project}: Deploy failed"

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
                "title": "Project",
                "value": project,
                "short": true
              },
              {
                "title": "Environment",
                "value": environment,
                "short": true
              },
              {
                "type": "mrkdwn",
                "value": "<#{circle_ci_url}|View in CircleCI>",
              },
              {
                "type": "mrkdwn",
                "value": "<#{rancher_url}|View in Rancher>",
              }
            ]
        }
    ]
}

payload = "payload=#{content.to_json}"

system('curl', '-s', '-S', '--data-urlencode', payload, webhook_url)
