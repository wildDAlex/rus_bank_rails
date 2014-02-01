require 'spec_helper'
require 'factories'

VALID_BIC = FactoryGirl.attributes_for(:valid_bank)[:bic]
INVALID_BIC = '0445852169999'
VALID_INT_CODE = 450000650
INVALID_INT_CODE = 450000650999999
VALID_REG_NUMBER = '316'
INVALID_REG_NUMBER = '289375237580009'
VALID_REGION = '16'
INVALID_REGION = '999'
INVALID_ORG_NAME = 'djhgsjdlksl'
VALID_ORG_NAME = 'ХКФ БАНК'

describe Bank do

  describe '.BicToIntCode' do
    before :each do
      DatabaseCleaner.clean
      @bank = Bank.new
    end

    it 'should return correct value' do   # Unneeded, already tested in RusBank
      @bank.BicToIntCode(VALID_BIC).should eq(VALID_INT_CODE)
    end

    it 'saves new bank to database' do
      expect{
        @bank.BicToIntCode(VALID_BIC)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", internal_code: INVALID_INT_CODE)
      @bank.BicToIntCode(FactoryGirl.attributes_for(:valid_bank)[:bic]).should eq INVALID_INT_CODE
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        @bank.BicToIntCode(old_db_entry.bic)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      @bank.BicToIntCode(old_db_entry.bic)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq FactoryGirl.attributes_for(:valid_bank)[:org_name]
    end

    it 'should touch updated_at even if data is not changed' do
      FactoryGirl.create(:valid_bank, updated_at: (Time.now - 1.month))
      old_updated_at = Bank.find_by_bic(VALID_BIC).updated_at
      @bank.BicToIntCode(VALID_BIC)
      expect(Bank.find_by_bic(VALID_BIC).updated_at).to be > old_updated_at
    end

    it 'merge attributes from different sources into one record' do
      @bank.BicToIntCode(VALID_BIC)
      expect(Bank.find_by_bic(VALID_BIC).internal_code).to_not be nil
      expect(Bank.find_by_bic(VALID_BIC).reg_number).to_not be nil
      expect(Bank.find_by_bic(VALID_BIC).org_name).to_not be nil
    end
  end
end