# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Tests TranslateThis API' do
  before do
    VCR.insert_cassette API_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'API WEB Tests' do
    it 'HAPPY: should provide a 200 on root directory, we working' do
      get ''
      _(last_response.status).must_equal 200
    end
    it 'SAD: should raise exception on POST without paremeters' do
      post "#{API_VER}/translate"
      _(last_response.status).must_equal 404
      body = JSON.parse last_response.body
      _(body.keys).must_include 'error'
    end
  end

  describe 'Translation Requests!' do
    it 'HAPPY: recieves translation request and provides translated labels' do
      # pic = File.open(IMAGE)
      req_params = {}
      req_params['img'] = { tempfile: IMAGE, content_type: 'image/jpeg',
                            filename: 'testimage.jpg' }
      req_params['target_lang'] = 'zh-TW'
      serv_result = TranslateThis::TranslateImage.new.call(
        config: app.config,
        routing: req_params
      )
      _(serv_result.success?).must_equal true
    end

    it 'SAD:' do
    end

    it 'BAD:' do
    end
  end

  describe 'query available languages.' do
    it 'HAPPY: returns all my supported languages' do
      languages = TranslateThis::Repository::
      For[TranslateThis::Entity::Language].all
      languages_json = TranslateThis::LanguagesRepresenter
                       .new(TranslateThis::Languages.new(languages)).to_json
      lang_result = TranslateThis::Result.new(:ok, languages_json)
      _(languages.size).must_equal 104
      _(lang_result.message).must_equal LANGUAGES_JSON.to_json
    end

    it 'HAPPY: provide valid return on get' do
      get "#{API_VER}/language"
      _(last_response.status).must_equal 200
    end
  end
end
