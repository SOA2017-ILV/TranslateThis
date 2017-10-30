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
      vision = TranslateThis::GoogleVision::Api.new(GOOGLE_TOKEN)
      label_mapper = TranslateThis::GoogleVision::LabelMapper
                     .new(vision)
      labels = label_mapper.load_several(IMAGE)
      descriptions = labels.map(&:description)
      correct_descriptions = CORRECT_VI['labels'].map { |l| l['description'] }
      _(descriptions).must_equal correct_descriptions
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        vision = TranslateThis::GoogleVision::Api.new('bad_token')
        TranslateThis::GoogleVision::LabelMapper.new(vision).load_several(IMAGE)
      end.must_raise TranslateThis::GoogleVision::Api::Errors::NotValid
    end

    it 'SAD should raise file not found error' do
      proc do
        vision = TranslateThis::GoogleVision::Api.new(GOOGLE_TOKEN)
        TranslateThis::GoogleVision::LabelMapper.new(vision)
                                                .load_several('bad_img.jpg')
      end.must_raise Errno::ENOENT
    end
  end

  describe 'Translate information' do
    it 'HAPPY: should translate text to chinese' do
      translation = TranslateThis::GoogleTranslation::Api
                    .new(GOOGLE_TOKEN)
      trans_mapper = TranslateThis::GoogleTranslation::TranslateMapper
                     .new(translation)
      translate = trans_mapper.load(['Hello world'], 'zh-TW')
      correct_tr = CORRECT_TR['data']['translations'][0]['translatedText']
      _(translate.translated_text).must_equal correct_tr
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        translation = TranslateThis::GoogleTranslation::Api
                      .new('bad_token')
        TranslateThis::GoogleTranslation::TranslateMapper
          .new(translation).load(['Hello world'], 'zh-TW')
      end.must_raise TranslateThis::GoogleTranslation::Api::Errors::NotValid
    end

    # #TODO: Will we give error if translating to same language?
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
