# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests TranslateThis library' do
  before do
    VCR.insert_cassette GATEWAY_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Vision information' do
    it 'HAPPY: should identify labels' do
      label_mapper = TranslateThis::GoogleVision::LabelMapper
                     .new(app.config)
      label_entities = label_mapper.load_several(IMAGE)

      descriptions = label_entities.map(&:label_text)
      correct_descriptions = CORRECT_VI['labels'].map { |l| l['description'] }
      _(descriptions).must_equal correct_descriptions
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        sad_config = OpenStruct.new(google_token: 'sad_token')
        label_mapper = TranslateThis::GoogleVision::LabelMapper.new(sad_config)
        label_mapper.load_several(IMAGE)
      end.must_raise TranslateThis::GoogleVision::Api::Errors::NotValid
    end

    it 'SAD should raise file not found error' do
      proc do
        label_mapper = TranslateThis::GoogleVision::LabelMapper
                       .new(app.config)
        label_mapper.load_several('bad_img.jpg')
      end.must_raise Errno::ENOENT
    end
  end

  describe 'Translate information' do
    it 'HAPPY: should translate text to chinese' do
      language_class = TranslateThis::Entity::Language
      stored_lang = TranslateThis::Repository::For[language_class]
                    .find_language_code('en')
      label_entity = TranslateThis::Entity::Label.new(
        id: nil,
        label_text: 'Hello world',
        origin_language: stored_lang
      )
      trans_mapper = TranslateThis::GoogleTranslation::TranslationMapper
                     .new(app.config)
      translation = trans_mapper.load(label_entity,
                                      'zh-TW')
      correct_tr = CORRECT_TR['data']['translations'][0]['translatedText']
      _(translation.translated_text).must_equal correct_tr
    end

    it 'SAD: should raise exception invalid TOKEN' do
      proc do
        language_class = TranslateThis::Entity::Language
        stored_lang = TranslateThis::Repository::For[language_class]
                      .find_language_code('en')
        label_entity = TranslateThis::Entity::Label.new(
          id: nil,
          label_text: 'Hello world',
          origin_language: stored_lang
        )
        sad_config = OpenStruct.new(google_token: 'sad_token')
        trans_mapper = TranslateThis::GoogleTranslation::TranslationMapper
                       .new(sad_config)
        trans_mapper.load(label_entity, 'zh-TW')
      end.must_raise TranslateThis::GoogleTranslation::Api::Errors::NotValid
    end
  end
end
