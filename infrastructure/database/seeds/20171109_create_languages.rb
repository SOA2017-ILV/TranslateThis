# frozen_string_literal: true

require 'sequel/extensions/seed'

Sequel.seed(:development, :test, :production) do
  def run
    puts 'Seeding languages'
    create_languages
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ALL_LANGUAGES = YAML.load_file("#{DIR}/language_seed.yml")

def create_languages
  language_orm = TranslateThis::Database::LanguageOrm
  ALL_LANGUAGES.each do |language_data|
    language_orm.create(language: language_data['language'],
                        code: language_data['code'])
  end
end
