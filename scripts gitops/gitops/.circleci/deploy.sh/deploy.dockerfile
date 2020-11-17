FROM quay.io/wowzaprivate/wowza-builder:1.0.4

WORKDIR /project

ENTRYPOINT  ["ruby", ".circleci/deploy.sh/deploy.rb"]