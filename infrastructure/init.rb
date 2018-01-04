# frozen_string_literal: false

folders = %w[google imgur messaging database/orm database/seeds]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
