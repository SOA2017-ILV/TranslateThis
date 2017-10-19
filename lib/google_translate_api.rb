# frozen_string_literal: true

require 'google/cloud/translate'
# google cloud platform project id

# text translate module connects to google
module TextTranslate
  # Text Translation class
  class Translate
    # TODO: impliment some form of translation cacheing
    # othewise we will always be translation stuff and killing our app
    # TODO: figure out if i can get my project id from the google token directly
    def initialize(translate_api_key, destination_lang)
      @token = translate_api_key
      @googleproject = 'translate-this-183316'
      @dest = destination_lang
    end

    def connect_google
      # TODO: impliment a try do thing to catch connect errors, because reasons
      translate_text = Google::Cloud::Translate.new project: @googleproject,
                                                    keyfile: @token
      translate_text
    end

    def translate_text(source_text)
      translator = connect_google
      translation = translator.translate source_text, to: @dest
      translation
    end
  end
end
