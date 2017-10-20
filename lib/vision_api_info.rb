# frozen_string_literal: true

require 'http'

# Imports the Google Cloud client library
require "google/cloud/vision"

# Your Google Cloud Platform project ID
project_id = "soa-translatethis"

# Instantiates a client
vision = Google::Cloud::Vision.new project: project_id

# The name of the image file to annotate
file_name = "./images/cat.jpg"

# Performs label detection on the image file
labels = vision.image(file_name).labels

puts "Labels:"
labels.each do |label|
  puts label.description
end
