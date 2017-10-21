# frozen_string_literal: true

require_relative 'spec_helper.rb'

describe 'Tests Translation library only' do
  API_CRED = '../config/translate-api.json'
  FAKE_CRED = '../config/googleapikey.json.example'
  Test_strings = ['This is a test sequence',
                  'The quick brown fox jumped over the lazy dog',
                  'Table',
                  'Fan',
                  'Lamp'].freeze
  STRINGS = YAML.safe_load(File.read('../config/translatetextstrings.yml'))
  # VCR configs
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<TRANS_TOKEN>') { API_CRED }
    c.filter_sensitive_data('<TRANS_TOKEN_ESC>') { CGI.escape(API_CRED) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  describe 'Translate information' do
    it 'HAPPY: should return Google Cloud Translate Objects' do
      chinese_translator = TextTranslate::Translate.new(API_CRED, 'zh-TW')
      STRINGS[0].map do |string|
        result = chinese_translator.translate_text(string)
        _(result).must_be_instance_of Google::Cloud::Translate::Translation
      end
    end

    it 'HAPPY: should translate text strings so wont match initial' do
      chinese_translator = TextTranslate::Translate.new(API_CRED, 'zh-TW')
      STRINGS[0].map do |string|
        result = chinese_translator.translate_text(string)
        _(result.text).wont_match string
      end
    end

    it 'HAPPY: should translate text strings and match expected output' do
      chinese_translator = TextTranslate::Translate.new(API_CRED, 'zh-TW')
      STRINGS[0].map.with_index do |string, index|
        result = chinese_translator.translate_text(string)
        _(result).must_match STRINGS[1][index]
      end
    end

    # TODO: need some means of authetication checks
    # it 'SAD: should die on incorrect security credentials' do
    #   chinese_translator = TextTranslate::Translate.new(FAKE_CRED, 'zh-TW')
    #   Test_strings.map do |string|
    #     result = chinese_translator.translate_text(string)
    #     _(result).must_be_instance_of Google::Cloud::Translate::Translation
    #   end
    # end

    it 'SAD: translate text to same language...WHY U DO THIS!!' do
      english_translator = TextTranslate::Translate.new(API_CRED, 'zh-TW')
      # Test_strings.map do |string|
      STRINGS[1].map.with_index do |string, index|
        eng_result = english_translator.translate_text(string)
        _(eng_result.origin).must_match STRINGS[1][index]
      end
    end
  end
end
