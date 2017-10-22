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
      _(visions.count).must_equal CORRECT_VI["labels"].count

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
    it 'HAPPY: should return translation in Chinese for given image' do
    end
  end
end
