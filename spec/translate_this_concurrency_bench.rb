# frozen_string_literal: false

ENV['RACK_ENV'] = 'test'
require 'benchmark'
require 'net/http/post/multipart'
require 'rack/test'
require_relative 'test_load_all'
require 'yaml'
load './Rakefile'

CORRECT_VI = YAML.safe_load(File.read('spec/fixtures/vision_results.yml'))
image_yaml = YAML.safe_load(File.read('spec/fixtures/bench_images.yml'))
imagelist = []
image_yaml['images'].map do |l|
  imagelist.push(l['location'])
end
##########################
# TODO: find out why this needs to run 3 times to properly work on database
def wipe_datastore
  Rake::Task['db:wipe_pg'].invoke
  Rake::Task['db:create_pg'].invoke
  sleep(0.5)
  Rake::Task['db:migrate'].invoke
  sleep(0.5)
  Rake::Task['db:seed'].invoke
end

def request_translation(imagelist)
  results = []
  imagelist.map do |pic|
    url = URI.parse('http://localhost:9292/api/v0.1/translate2')
    req_params = {}
    img = File.open(pic)
    req_params['img'] = UploadIO.new(img, 'image/jpeg', 'testimage.jpg')
    req_params['target_lang'] = 'es'
    result = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      req = Net::HTTP::Post::Multipart.new(url, req_params)
      http.request(req)
    end
    results.push(result)
  end
  wipe_datastore
  results
end
########################################
def request_translation_cuncurrent(imagelist)
  results = []
  imagelist.map do |pic|
    url = URI.parse('http://localhost:9292/api/v0.1/translate2')
    req_params = {}
    img = File.open(pic)
    req_params['img'] = UploadIO.new(img, 'image/jpeg', 'testimage.jpg')
    req_params['target_lang'] = 'es'
    result = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      req = Net::HTTP::Post::Multipart.new(url, req_params)
      http.request(req)
    end
    results.push(result)
  end
  wipe_datastore
  results
end
############# Crashes here for 2-3 atempts
wipe_datastore
wipe_datastore
wipe_datastore

Benchmark.bmbm(100) do |bench|
  bench.report('single') { request_translation(imagelist) }
  bench.report('concurrent') { request_translation_cuncurrent(imagelist) }
end
