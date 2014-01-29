require 'spec_helper'

describe Bank do
  before :each do
    @bank = Bank.new
  end

  describe 'BicToIntCode' do
    it 'should return correct value' do
      @bank.BicToIntCode("044585216").should eq(450000650)
    end
  end
end
