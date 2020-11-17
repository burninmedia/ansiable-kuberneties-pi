
require 'yaml'
require_relative('methods.rb')

puts
puts

# Global Variable for all the projects and environments for each project
# Initialize that array
# $projects_and_environments = {}
# get_projects_and_environments()

$components = get_components()

# TODO , make this dynamic
$buildType = "release"

# TODO
# Insert interactive code that prompts user for project and environment....
# TODO


# Pluck the enviornments off of the ARGV aray
components = []
until ARGV.empty?
	components.append(ARGV.shift)
end

# If there are no components provided by the user...
if components.length == 0
	show_usage()
	exit
end


# pre-validate each component  before trying to tag the repo
components.each do |component|
	validate_component(component)
end


# Tag for each component that we're deploying
components.each do |component|
	tag_repo(component)
end