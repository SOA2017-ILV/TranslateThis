# frozen_string_literal: true

folders = %w[config domain infrastructure application workers]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
