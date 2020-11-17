
require 'yaml'
require_relative('methods.rb')

test_git_ssh_access

# Global Variable for all the projects and environments for each project
# Initialize that array
$projects_and_environments = {}
get_projects_and_environments()


# The first argument is the project name
project = ARGV.shift

# TODO
# Insert interactive code that prompts user for project and environment....
# TODO


# Pluck the enviornments off of the ARGV aray
environments = []
until ARGV.empty?
	environments.append(ARGV.shift)
end

# If there are no environments provided by the user...
if environments.length == 0
	show_usage()
	validate_environment(project,"") unless project == nil
	exit
end

# pre-validate each environment  before trying to tag the repo
environments.each do |environment|
	validate_environment(project, environment)
end


# Tag for each environment that we're deploying
environments.each do |environment|
	tag_repo(project, environment)
end
