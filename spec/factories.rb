FactoryGirl.define do
  factory :valid_bank, :class => Bank do |f|
    f.reg_number 316
    f.internal_code 450000650
    f.bic '044585216'
    f.org_name 'ХКФ БАНК'
    f.org_full_name nil
    f.phones nil
    f.date_kgr_registration nil
    f.main_reg_number nil
    f.main_date_reg nil
    f.ustav_adr nil
    f.fact_adr nil
    f.director nil
    f.ust_money nil
    f.org_status nil
    f.reg_code nil
    f.ssv_date nil
    f.l_code nil
    f.lt nil
    f.l_date nil
  end
end