framework 'AddressBook'

class PlusI18n
  attr_reader :default_country_code

  def initialize(default_country_code)
    @default_country_code = default_country_code
    @country_codes = [
      '44',
      '49'
    ]
    @formats = {
      '44' => [
          [/^0?2[0-9]/, /^0?(2[0-9])([0-9]{4})([0-9]{4})$/],
          [/^0?7[0-9]{3}/, /^0?(7[0-9]{3})([0-9]{6})$/]
        ]
    }
  end

  def multivalue_enum(multivalue)
    (0..(multivalue.count - 1)).collect do |i|
      [multivalue.labelAtIndex(i), multivalue.valueAtIndex(i)]
    end
  end

  def run
    ab = ABAddressBook.sharedAddressBook
    ab.people.each do |person|
      existing_phone_numbers = person.valueForProperty('Phone')
      if existing_phone_numbers
        new_phone_numbers = ABMutableMultiValue.new
        multivalue_enum(existing_phone_numbers).each do |label, value|
          new_phone_numbers.addValue(process_number(value), withLabel: label)
        end
        pi_index = existing_phone_numbers.indexForIdentifier(existing_phone_numbers.primaryIdentifier)
        new_phone_numbers.setPrimaryIdentifier(new_phone_numbers.identifierAtIndex(pi_index))
        person.setValue(new_phone_numbers, forProperty: 'Phone')
      end
    end
    ab.save
  end

  def extract_country_code(number)
    if cc = @country_codes.find { |cc| number.match(/^\+#{cc}/) }
      number.match(/^\+(#{cc})(.+)/)[1,2]
    end
  end

  def process_number(original_number)
    number = remove_spaces(original_number)
    if has_country_code?(number)
      country_code, number = extract_country_code(number)
    else
      country_code = default_country_code
    end
    if @formats[country_code]
      matcher, format = @formats[country_code].find { |matcher, format| number.match(matcher) }
      if matcher
        formatted = number.match(format)
        return "+#{country_code} " + formatted.captures().join(" ") if formatted
      end
    end
    original_number
  end

  def remove_spaces(number)
    number.tr(' ', '')
  end

  def has_country_code?(number)
    number[0] == '+'
  end
end
