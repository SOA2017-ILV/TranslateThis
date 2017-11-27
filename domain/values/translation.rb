# frozen_string_literal: true

module TranslateThis
  TranslationResult = Struct.new :label_text, :translated_text,
                                 :target_lang_code, :target_lang, :img_link
end
