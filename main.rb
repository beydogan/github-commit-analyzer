require 'github_api'

puts "START -" + Time.new.to_s

$file_types = {
    '.rb' => 'Ruby',
    '.js' => 'Javascript',
    '.html' => 'HTML',
    '.cpp' => 'C++'
}

$github = Github.new do |config|
  config.client_id = "CLIENT_ID"
  config.client_secret = "CLIENT_SECRET"
  config.per_page = 100
end

username = 'beydogan'

user_files = []
user_repos = $github.repos.list user: username
user_orgs = $github.orgs.list user: username


def get_user_files_from_repo(username, repo_name, repo_owner)
  repo_files = []
  commits = $github.repos.commits.list repo_owner, repo_name, :author => username #Get all commits

  commits.each do |commit|

    commit_details = $github.repos.commits.get repo_owner, repo_name, commit.sha #Get commit details
    files = commit_details.body.files #Get committed files
    repo_files.concat(files) #Add files to results

  end

  repo_files #return
end

def analyze_file(file) #returns file type and additions, deletions, changes counts
  type = File.extname(file['filename'])
  return {
      :file_type =>  type,
      :additions => file['additions'],
      :deletions => file['deletions'],
      :changes => file['changes']
  }
end

def analyze_files(files)
  points = {
  }

  files.each do |file|
    file_info = analyze_file(file)

    if points[file_info[:file_type].to_sym]
      points[file_info[:file_type].to_sym] +=  1
    else
      points.merge!({ file_info[:file_type].to_sym => 1 })
    end

  end

  points
end

def get_language(file_type)
  $file_types[file_type]
end

all_points = {}
user_repos.each do |repo|
  name = repo.name
  owner = repo.owner.login
  files = get_user_files_from_repo(username, name, owner)
  all_points.merge!(analyze_files(files))
end

puts all_points


puts "END # -" + Time.new.to_s
