# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests TranslateThis library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<VISION_TOKEN>') { VISION_TOKEN }
    c.filter_sensitive_data('<VISION_TOKEN_ESC>') { CGI.escape(VISION_TOKEN) }
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

  describe 'Vision information' do
    it 'HAPPY: should identify labels' do
      visions = GoogleVisionModule::VisionAPI.new(VISION_TOKEN).labels(IMAGE)
      _(visions.count).must_equal CORRECT_VI['labels'].count

      descriptions = visions.map(&:description)
      correct_descriptions = CORRECT_VI['labels'].map { |l| l['description'] }
      _(descriptions).must_equal correct_descriptions

      scores = visions.map(&:score)
      correct_scores = CORRECT_VI['labels'].map { |l| l['score'] }
      _(scores).must_equal correct_scores
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        GoogleVisionModule::VisionAPI.new('bad_token').labels(IMAGE)
      end.must_raise GoogleVisionModule::Errors::NotValid
    end

    it 'SAD should raise file not found error' do
      proc do
        GoogleVisionModule::VisionAPI.new(VISION_TOKEN).labels('bad_image.jpg')
      end.must_raise Errno::ENOENT
    end
  end

  describe 'Translate information' do
    it 'HAPPY: should return Google Cloud Translate Objects' do
      chinese_translator = TextTranslate::Translate.new(TRANS_TOKEN, 'zh-TW')
      STRINGS[0].map do |string|
        result = chinese_translator.translate_text(string)
        _(result).must_be_instance_of Google::Cloud::Translate::Translation
      end
    end

    it 'HAPPY: should translate text strings so wont match initial' do
      chinese_translator = TextTranslate::Translate.new(TRANS_TOKEN, 'zh-TW')
      STRINGS[0].map do |string|
        result = chinese_translator.translate_text(string)
        _(result.text).wont_match string
      end
    end

    it 'HAPPY: should translate text strings and match expected output' do
      chinese_translator = TextTranslate::Translate.new(TRANS_TOKEN, 'zh-TW')
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
      english_translator = TextTranslate::Translate.new(TRANS_TOKEN, 'zh-TW')
      # Test_strings.map do |string|
      STRINGS[1].map.with_index do |string, index|
        eng_result = english_translator.translate_text(string)
        _(eng_result.origin).must_match STRINGS[1][index]
      end
    end
  end
end
