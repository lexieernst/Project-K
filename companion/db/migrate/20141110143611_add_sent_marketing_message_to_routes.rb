class AddSentMarketingMessageToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :sent_marketing_message, :boolean, null: false, default: false
  end
end
