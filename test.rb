require 'minitest/autorun'
require './plus_i18n.rb'


describe PlusI18n do
  before do
    @processor = PlusI18n.new('44')
  end
  
  describe "extracting country codes" do
    {
      '+442077778' => ['44', '2077778']
    }.each do |input, expected|
      it "should match #{input} to #{expected}" do
        @processor.extract_country_code(input).must_equal expected
      end
    end
  end

  describe "processing numbers" do
    {
      '+442077778888' => '+44 20 7777 8888',
      '02077778888' => '+44 20 7777 8888',
      '+44 20 7777 8888' => '+44 20 7777 8888',
      '+447717123456' => '+44 7717 123456',
      '07717123456' => '+44 7717 123456'
    }.each do |input, expected|
      it "should turn #{input} into #{expected}" do
        @processor.process_number(input).must_equal expected
      end
    end
  end

  it "passes unrecognised numbers through unharmed" do
    @processor.process_number('+441215555555').must_equal '+441215555555'
  end
end
