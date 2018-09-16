class Engineer < ApplicationRecord
	has_one :engineer_registration_type
	has_one :engineer_status_type
	has_one :engineer_hiring, autosave: true
	has_one :office, through: :engineer_hiring
	belongs_to :person_info, autosave: true
	has_many :careers
	has_many :engineer_hope_businesses
	accepts_nested_attributes_for :engineer_hiring, :person_info
	accepts_nested_attributes_for :careers, :engineer_hope_businesses,
		allow_destroy: true
	after_initialize :set_default_value, if: :new_record?


	def self.parameters(param_hash,key)
		param_hash.require(key).permit(
			:eng_cd,:engineer_registration_type_id,
			:registration_memo,:engineer_status_type_id,
			:person_info_attributes => [
				:last_name,:first_name,:middle_name,
				:kana_last_name,:kana_first_name, :kana_middle_name
			],
			:engineer_hiring_attributes => [
				:office_id,:hiring_position,:hiring_division,
				:hiring_memo, :hiring_contact_id,
				:hired_from, :hired_until,:status
			],
			:careers_attributes => [

			],
			:engineer_hope_businesses_attribues => []
		)
	end

	private
	def set_default_value
		self.build_engineer_hiring(office: Office.first)
		self.build_person_info
		self.engineer_registration_type_id = EngineerRegistrationType.select(:id).first
		self.engineer_status_type_id = EngineerStatusType.select(:id).first
		self.careers.build
#		self.engineer_hope_businesses.build
	end
end
