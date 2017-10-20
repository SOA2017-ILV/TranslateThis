# frozen_string_literal: true

require_relative 'spec_helper.rb'

describe 'Tests Translation library only' do
  API_CRED = '../config/translate-api.json'
  Test_strings = ['This is a test sequence',
                  'The quick brown fox jumped over the lazy dog',
                  'Table',
                  'Fan',
                  'Lamp'].freeze
  # VCR configs
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<TRANS_TOKEN>') { API_CRED }
    c.filter_sensitive_data('<TRANS_TOKEN_ESC>') { CGI.escape(API_CRED) }
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
    it 'HAPPY: should return Google Cloud Translate Objects' do
      chinese_translator = TextTranslate::Translate.new(API_CRED, 'zh-TW')
      Test_strings.map do |string|
        result = chinese_translator.translate_text(string)
        _(result).must_be_instance_of Google::Cloud::Translate::Translation
      end
    end

    it 'HAPPY: should produce translated text strings' do

    end

    it 'SAD: should die on incorrect security credentials' do

    end

    it 'SAD: ....' do
      
    end
  end
end
