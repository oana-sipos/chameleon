class AddFbUidToUsers < ActiveRecord::Migration
  def change
  	change_table 'users' do |t|
  		t.string :facebook_uid
  	end
  end
end
