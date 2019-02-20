# frozen_string_literal: true

# Smart requirer:
current_dir = Dir.pwd
folders = %w[exceptions helpers models utils]

folders.each{|folder| Dir["#{current_dir}/lib/#{folder}/*.rb"].each(&method(:require))
}
