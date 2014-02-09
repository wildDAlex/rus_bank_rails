require 'spec_helper'
require 'factories'

VALID_BIC = FactoryGirl.attributes_for(:valid_bank)[:bic]
INVALID_BIC = '0445852169999'
VALID_INT_CODE = FactoryGirl.attributes_for(:valid_bank)[:internal_code]
INVALID_INT_CODE = 450000650999999
VALID_REG_NUMBER = FactoryGirl.attributes_for(:valid_bank)[:reg_number]
INVALID_REG_NUMBER = 289375237580009
VALID_REGION = FactoryGirl.attributes_for(:valid_bank)[:reg_code]
INVALID_REGION = '999'
INVALID_ORG_NAME = 'djhgsjdlksl'
VALID_ORG_NAME = FactoryGirl.attributes_for(:valid_bank)[:org_name]

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
      @bank.BicToIntCode(VALID_BIC).should eq INVALID_INT_CODE
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
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
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

    it 'deletes bank from database if bank not found in api' do
      old_db_entry = FactoryGirl.create(:valid_bank, bic: '111111111', updated_at: (Time.now - 1.month))
      expect{
        @bank.BicToIntCode(old_db_entry.bic)
      }.to change{Bank.all.count}.by(-1)
    end
  end

  describe ".RegNumToIntCode" do

    before :each do
      DatabaseCleaner.clean
      @bank = Bank.new
    end

    it 'should return correct value' do
      @bank.RegNumToIntCode(VALID_REG_NUMBER).should eq(VALID_INT_CODE)
    end

    it 'should return nil if value incorrect' do
      @bank.RegNumToIntCode(INVALID_REG_NUMBER).should be_nil
    end

    it 'saves new bank to database' do
      expect{
        @bank.RegNumToIntCode(VALID_REG_NUMBER)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", internal_code: INVALID_INT_CODE)
      @bank.RegNumToIntCode(VALID_REG_NUMBER).should eq INVALID_INT_CODE
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        @bank.RegNumToIntCode(old_db_entry.reg_number)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      @bank.RegNumToIntCode(old_db_entry.reg_number)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".IntCodeToRegNum" do

    before :each do
      DatabaseCleaner.clean
      @bank = Bank.new
    end

    it 'should return correct value' do
      @bank.IntCodeToRegNum(VALID_INT_CODE).should eq(VALID_REG_NUMBER)
    end

    it 'should return nil if value incorrect' do
      @bank.IntCodeToRegNum(INVALID_INT_CODE).should be_nil
    end

    it 'saves new bank to database' do
      expect{
        @bank.IntCodeToRegNum(VALID_INT_CODE)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", reg_number: INVALID_REG_NUMBER)
      @bank.IntCodeToRegNum(VALID_INT_CODE).should eq INVALID_REG_NUMBER
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        @bank.IntCodeToRegNum(old_db_entry.internal_code)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      @bank.IntCodeToRegNum(old_db_entry.internal_code)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".get_licences_as_array_of_hashes" do

    before :each do
      DatabaseCleaner.clean
      @bank = Bank.new
    end

    it 'should return empty array for bank with no licence' do
      entry = FactoryGirl.create(:valid_bank, org_name: "Bank in Database", licences: [])
      expect(entry.get_licences_as_array_of_hashes).to eq([])
    end

    it 'should return array of one element for bank with one licence' do
      entry = FactoryGirl.create(:valid_bank, org_name: "Bank in Database", licences: [{:l_code=>"7", :lt=>"Лицензия 1", :l_date=>"2012-09-10T00:00:00+04:00"}])
      expect(entry.get_licences_as_array_of_hashes.size).to eq(1)
      expect(entry.get_licences_as_array_of_hashes.first[:lt]).to eq("Лицензия 1")
    end

    it 'should return array of multiple element for bank with no multiple licences' do
      entry = FactoryGirl.create(:valid_bank, org_name: "Bank in Database", licences: [{:l_code=>"3", :lt=>"Лицензия 2", :l_date=>"2007-12-20T00:00:00+04:00"}, {:l_code=>"7", :lt=>"Лицензия 3", :l_date=>"2012-03-23T00:00:00+04:00"}])
      expect(entry.get_licences_as_array_of_hashes.size).to eq(2)
      expect(entry.get_licences_as_array_of_hashes.first[:lt]).to eq("Лицензия 2")
      expect(entry.get_licences_as_array_of_hashes.last[:lt]).to eq("Лицензия 3")
    end

  end
end
