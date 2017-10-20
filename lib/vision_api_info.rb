# frozen_string_literal: true

require 'http'
require 'yaml'
require 'base64'

config = YAML.safe_load(File.read('config/secrets.yml'))
image_path = 'spec/fixtures/demo-image.jpg'
API_URI = 'https://vision.googleapis.com/v1/'

def vision_api_path(path, config)
  API_URI + path + '?key=' + config['vision_api_token']
end

def image_request(image_path)
  begin
    content = Base64.encode64(open(image_path).to_a.join)
    requests = [{ image: { content: content }, features: [{ type: 'LABEL_DETECTION' }]}]
    { requests: requests }
  rescue Errno::ENOENT
    print 'Error'
  end
end

def call_vision_url(url, image_url)
  HTTP.post(url, json: image_request(image_url))
end

vision_response = {}
vision_results = {}

## GOOD REPO (HAPPY)
repo_url = vision_api_path('images:annotate', config)
vision_response[repo_url] = call_vision_url(repo_url, image_path)
images_annotation = vision_response[repo_url].parse
vision_results['labels'] = images_annotation['responses'][0]['labelAnnotations']
## BAD REPO (SAD)
bad_image_path = 'foobar.jpg'
bad_url = vision_api_path('images:annotate', config)
vision_response[bad_url] = call_vision_url(bad_url, bad_image_path)

File.write('spec/fixtures/vision_response.yml', vision_response.to_yaml)
File.write('spec/fixtures/vision_results.yml', vision_results.to_yaml)
