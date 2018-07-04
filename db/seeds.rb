# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

CmnPropertyType.find_or_create_by(
		title:'住所・郵便番号',
		description: '都道府県、住所、郵便番号はaddressモデルからの取得とする',
		property_datatype: :class_id,
		data_class: 'address'
)

CmnPropertyType.find_or_create_by(
		title:'生年月日',
		description: '誕生日の場合、年については0000',
		property_datatype: :date
)
