$deployTagPrefix="start-component-build"


def show_usage()
	puts "\nUsage: ./build.sh <component(s)>\n"
	puts "Valid components:"
	$components.each do |component|
		puts "\t#{component}"
	end
end

def get_components()
	components = YAML.load_file("components.yaml")
	components.map { |k,v| k }
end

def validate_component(component)
	if $components.include?(component)
		return true
	end
	puts
	puts "Invalid Component --> #{component}"
	puts
	exit
end

def tag_repo(component)

	tagTimestamp = Time.now.strftime("%Y-%m-%dT%H%M%S")

	unts = "#{tagTimestamp}-#{ENV['HOST_USER']}"

	tag = "#{$deployTagPrefix}/#{component}/#{$buildType}/#{unts}"

	puts "Tagging repo with #{tag}"

	# Check if user has repo access
	success = system("git pull")
	if not success
		puts "\n\nError: Could not pull from repo."
		puts "Make sure this repo origin is set to use SSH (git@github.com:...)"
		puts "rather than HTTPS (https://<user>@github.com/...)"
		system("ssh git@github.com")
		exit
	end

	# Check for unpushed commits
	current_branch=`git rev-parse --abbrev-ref HEAD`
	unpushed_commits=`git log origin/#{current_branch.gsub("\n", "")}..HEAD --pretty=format:'%H'`
	if unpushed_commits.length > 0
		puts "Error: Some commits are unpushed. Please push these commits before tagging"
		exit
	end

	# system("git push origin ':#{tag}'")
	# system("git tag -l '#{$deployTagPrefix}/*' | xargs git tag -d")
	system("git fetch")
	system("git tag -a #{tag} -m 'Generated by deploy.rb'")
	system("git push --tags")
	system("git fetch --prune --tags")

end
