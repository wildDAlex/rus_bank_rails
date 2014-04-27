# encoding: utf-8

FactoryGirl.define do
  factory :valid_bank, :class => Bank do |f|
    f.reg_number 316
    f.internal_code 450000650
    f.bic '044585216'
    f.org_name 'ХКФ БАНК'
    f.org_full_name nil
    f.phones nil
    f.date_kgr_registration nil
    f.main_reg_number '1027700280937'
    f.main_date_reg nil
    f.ustav_adr nil
    f.fact_adr nil
    f.director nil
    f.ust_money nil
    f.org_status "норм."
    f.reg_code 16
    f.ssv_date nil
    f.licences nil
  end

  factory :valid_region, :class => BankRegion do |f|
    f.reg_code 16
    f.cname 'Москва'
  end
end