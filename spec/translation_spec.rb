# frozen_string_literal: true

require_relative 'spec_helper.rb'

describe 'Tests Translation library only' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<TRANS_TOKEN>') { TRANS_TOKEN }
    c.filter_sensitive_data('<TRANS_TOKEN_ESC>') { CGI.escape(TRANS_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Translate information' do
    it 'HAPPY: should return translation in Chinese for given image' do
    end
  end
end
