# frozen_string_literal: false

folders = %w[google imgur database/orm database/seeds]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
