# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests TranslateThis library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<GOOGLE_TOKEN>') { GOOGLE_TOKEN }
    c.filter_sensitive_data('<GOOGLE_TOKEN_ESC>') { CGI.escape(GOOGLE_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Vision information' do
    it 'HAPPY: should identify labels' do
      visions = TranslateThis::GoogleVision::Api.new(GOOGLE_TOKEN).labels_data(IMAGE)
      _(visions.count).must_equal CORRECT_VI['labels'].count

      descriptions = visions.map(&:description)
      correct_descriptions = CORRECT_VI['labels'].map { |l| l['description'] }
      _(descriptions).must_equal correct_descriptions
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        GoogleVisionModule::VisionAPI.new('bad_token').labels(IMAGE)
      end.must_raise GoogleVisionModule::Errors::NotValid
    end

    it 'SAD should raise file not found error' do
      proc do
        GoogleVisionModule::VisionAPI.new(GOOGLE_TOKEN).labels('bad_image.jpg')
      end.must_raise Errno::ENOENT
    end
  end

  describe 'Translate information' do
    it 'HAPPY: should translate text to chinese' do
      trans_api = GoogleTranslationModule::TranslationAPI.new(GOOGLE_TOKEN)
      translation = trans_api.translate(['Hello world'], 'zh-TW')
      correct_tr = CORRECT_TR['data']['translations'][0]['translatedText']
      _(translation.translated_text).must_equal correct_tr
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        trans_api = GoogleTranslationModule::TranslationAPI.new('bad_token')
        trans_api.translate(['Hello world'], 'zh-TW')
      end.must_raise GoogleTranslationModule::Errors::NotValid
    end

    # #TODO: Will we give error if translating o same language?
    # it 'SAD: translate text to same language' do
    #   english_translator = TextTranslate::Translate.new(GOOGLE_TOKEN, 'zh-TW')
    #   # Test_strings.map do |string|
    #   STRINGS[1].map.with_index do |string, index|
    #     eng_result = english_translator.translate_text(string)
    #     _(eng_result.origin).must_match STRINGS[1][index]
    #   end
    # end
  end
end
