# encoding: utf-8

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
INVALID_MAIN_REG_NUMBER = '82379'
VALID_MAIN_REG_NUMBER = FactoryGirl.attributes_for(:valid_bank)[:main_reg_number]

describe Bank do

  before :each do
    DatabaseCleaner.clean
  end

  describe '.bic_to_int_code' do

    it 'should return correct value' do   # Unneeded, already tested in RusBank
      Bank.bic_to_int_code(VALID_BIC).should eq(VALID_INT_CODE)
    end

    it 'saves new bank to database' do
      expect{
        Bank.bic_to_int_code(VALID_BIC)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", internal_code: INVALID_INT_CODE)
      Bank.bic_to_int_code(VALID_BIC).should eq INVALID_INT_CODE
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        Bank.bic_to_int_code(old_db_entry.bic)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.bic_to_int_code(old_db_entry.bic)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

    it 'should touch updated_at even if data is not changed' do
      FactoryGirl.create(:valid_bank, updated_at: (Time.now - 1.month))
      old_updated_at = Bank.find_by_bic(VALID_BIC).updated_at
      Bank.bic_to_int_code(VALID_BIC)
      expect(Bank.find_by_bic(VALID_BIC).updated_at).to be > old_updated_at
    end

    it 'merge attributes from different sources into one record' do
      Bank.bic_to_int_code(VALID_BIC)
      expect(Bank.find_by_bic(VALID_BIC).internal_code).to_not be nil
      expect(Bank.find_by_bic(VALID_BIC).reg_number).to_not be nil
      expect(Bank.find_by_bic(VALID_BIC).org_name).to_not be nil
    end

    it 'deletes bank from database if bank not found in api' do
      old_db_entry = FactoryGirl.create(:valid_bank, bic: '111111111', internal_code: '89899999', updated_at: (Time.now - 1.month))
      expect{
        Bank.bic_to_int_code(old_db_entry.bic)
      }.to change{Bank.all.count}.by(-1)
    end
  end

  describe ".reg_num_to_int_code" do

    it 'should return correct value' do
      Bank.reg_num_to_int_code(VALID_REG_NUMBER).should eq(VALID_INT_CODE)
    end

    it 'should return nil if value incorrect' do
      Bank.reg_num_to_int_code(INVALID_REG_NUMBER).should be_nil
      #expect{ Bank.reg_num_to_int_code(INVALID_REG_NUMBER) }.to raise_error Savon::SOAPFault
    end

    it 'saves new bank to database' do
      expect{
        Bank.reg_num_to_int_code(VALID_REG_NUMBER)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", internal_code: INVALID_INT_CODE)
      Bank.reg_num_to_int_code(VALID_REG_NUMBER).should eq INVALID_INT_CODE
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        Bank.reg_num_to_int_code(old_db_entry.reg_number)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.reg_num_to_int_code(old_db_entry.reg_number)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".int_code_to_reg_number" do

    it 'should return correct value' do
      Bank.int_code_to_reg_number(VALID_INT_CODE).should eq(VALID_REG_NUMBER)
    end

    it 'should return nil if value incorrect' do
      Bank.int_code_to_reg_number(INVALID_INT_CODE).should be_nil
    end

    it 'saves new bank to database' do
      expect{
        Bank.int_code_to_reg_number(VALID_INT_CODE)
      }.to change{Bank.all.count}.by(1)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database", reg_number: INVALID_REG_NUMBER)
      Bank.int_code_to_reg_number(VALID_INT_CODE).should eq INVALID_REG_NUMBER
    end

    it 'should not dublicate db-entry if bank already exist and not expire' do
      old_db_entry = FactoryGirl.create(:valid_bank)
      expect{
        Bank.int_code_to_reg_number(old_db_entry.internal_code)
      }.to change{Bank.all.count}.by(0)
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.int_code_to_reg_number(old_db_entry.internal_code)
      Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".get_licences_as_array_of_hashes" do

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

  describe ".is_active?" do

    it 'should return true if bank has licences and positive org_status' do
      not_active = FactoryGirl.create(:valid_bank, org_name: "Bank in Database", org_status: "лицензия отозвана", licences: [])
      active = FactoryGirl.create(:valid_bank, org_name: "Bank in Database", org_status: "норм.", licences: [{:l_code=>"3", :lt=>"Лицензия 4", :l_date=>"2007-12-20T00:00:00+04:00"}])
      expect(not_active.is_active?).to be false
      expect(active.is_active?).to be true
    end

  end

  describe ".search_by_name" do

    it 'should return correct value' do
      expect( Bank.search_by_name(VALID_ORG_NAME).length ).to be(1)
      expect( Bank.search_by_name(VALID_ORG_NAME).first.org_name ).to eq(VALID_ORG_NAME)
    end

    it 'should return nil if find nothing' do
      Bank.search_by_name(INVALID_ORG_NAME).should be_nil
    end

    it 'should return bank if bank with no bic' do
      Bank.search_by_name('МОСБИЗНЕСБАНК').first.org_status.should eq "ликвидирована"
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database")
      expect( Bank.search_by_name(VALID_ORG_NAME).first.org_name ).to eq("Bank in Database")
    end

    it 'should return array of banks' do
      Bank.search_by_name("Московский").length.should be > 1
    end

  end

  describe ".search_by_region_code" do

    # "Тяжелый" метод, пришлось подбирать регион "попроще"
    # 54 - Удмуртская Республика.

    it 'should return correct value' do
      expect( Bank.search_by_region_code(54).collect{|b| b.org_name} ).to include("УДМУРТПРОМСТРОЙБАНК")
    end

  end

  describe ".search_by_bic" do

    it 'should return correct value' do
      expect( Bank.search_by_bic(VALID_BIC).org_name ).to eq(VALID_ORG_NAME)
    end

    it 'should return nil if bank not found' do
      expect( Bank.search_by_bic(INVALID_MAIN_REG_NUMBER)).to be_nil
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database")
      Bank.search_by_bic(VALID_BIC).org_name.should eq "Bank in Database"
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.search_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".search_by_reg_number" do

    it 'should return correct value' do
      expect( Bank.search_by_reg_number(VALID_REG_NUMBER).org_name ).to eq(VALID_ORG_NAME)
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database")
      Bank.search_by_reg_number(VALID_REG_NUMBER).org_name.should eq "Bank in Database"
    end

    it 'should return nil if bank not found' do
      expect( Bank.search_by_reg_number(INVALID_REG_NUMBER)).to be_nil
    end

    it 'should return bank if bank with no bic' do
      Bank.search_by_reg_number('999').org_status.should eq "ликвидирована"
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.search_by_reg_number(old_db_entry.reg_number).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".search_by_main_reg_number" do

    it 'should return correct value' do
      expect( Bank.search_by_main_reg_number(VALID_MAIN_REG_NUMBER).org_name ).to eq(VALID_ORG_NAME)
    end

    it 'should return nil if bank not found' do
      expect( Bank.search_by_main_reg_number(INVALID_MAIN_REG_NUMBER)).to be_nil
    end

    it 'should return db-entry if entry not expire' do
      FactoryGirl.create(:valid_bank, org_name: "Bank in Database")
      Bank.search_by_main_reg_number(VALID_MAIN_REG_NUMBER).org_name.should eq "Bank in Database"
    end

    it 'should update bank in database if entry expires' do
      old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
      Bank.search_by_main_reg_number(old_db_entry.main_reg_number).org_name.should eq VALID_ORG_NAME
    end

  end

  describe ".get_offices" do
    # Нет необходимости тестировать данный метод, т.к. вызов делегируется к RusBank
  end

  describe ".get_offices_by_region" do
    # Нет необходимости тестировать данный метод, т.к. вызов делегируется к RusBank
  end

  describe ".regions_enum" do
    # Нет необходимости тестировать данный метод, т.к. вызов делегируется к RusBank
  end

  describe ".enum_bic" do

    # Ресурсоемкие тесты
    #it 'should update bank in database if entry expires' do
    #  old_db_entry = FactoryGirl.create(:valid_bank, org_name: "Old name", updated_at: (Time.now - 1.month))
    #  Bank.enum_bic
    #  Bank.find_by_bic(old_db_entry.bic).org_name.should eq VALID_ORG_NAME
    #end

    #it 'should return db-entry if entry not expire' do
    #  FactoryGirl.create(:valid_bank, org_name: "Bank in Database")
    #  expect( Bank.enum_bic.collect{|b| b.org_name} ).to include("Bank in Database")
    #end

  end

end
