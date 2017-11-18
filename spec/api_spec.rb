# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests TranslateThis library' do
  API_VER = 'api/v0.1'.freeze
  CASSETTE_FILE = 'translatethis_api'.freeze

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'API Tests' do
    it 'HAPPY: should provide a 200 on root directory, we working' do
      get ''
      _(last_response.status).must_equal 200
    end
    it 'SAD: should raise exception on POST without paremeters' do
      post "#{API_VER.to_s}/translate"
      _(last_response.status).must_equal 404
      body = JSON.parse last_response.body
      _(body.keys).must_include 'error'
    end
  end
end
