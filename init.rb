# frozen_string_literal: true

folders = %w[config domain infrastructure application]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
