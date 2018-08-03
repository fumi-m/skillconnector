class CreateBusinesses < ActiveRecord::Migration[5.2]
  def change
    create_table :businesses, comment: "事業所" do |t|
      t.string :name, null:false, comment: "事業所名称"
      t.string :name_kana, null:false, comment: "事業所読み仮名"
      t.string :long_name, null:false, comment: "事業所正式名称"
      t.string :long_name_kana, null:false, comment: "事業所正式名称読み仮名"
      t.references :parent, foreign_key: {to_table: :businesses},comment: "上位事業所"
      t.references :business_type, foreign_key: true, comment: "事業所種別"
      t.references :primary_address, foreign_key: {to_table: :adresses}, comment: "代表住所"
      t.references :primary_contact, foreign_key: {to_table: :contacts}, comment: "代表連絡先"
      t.references :business_status, comment: "事業所契約状態"
      t.date :enable_date, default: -> {'CURRENT_DATE'}, comment: "利用開始日"
      t.date :end_date, default: '9999-12-31', comment: "休止日"
      t.date :expire_schedule, default: '9999-12-31', comment: "データ削除予定日"

      t.timestamps
    end
  end
end
