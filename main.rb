require './plus_i18n.rb'

default_country = ARGV[0] || '44'

PlusI18n.new(default_country).run
