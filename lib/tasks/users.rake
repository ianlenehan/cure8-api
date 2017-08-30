namespace :users do
  task :remove_unused_numbers => :environment do
    unused_accounts = User.where("created_at < ?", 2.days.ago).where(first_name: nil)
    count = unused_accounts.count
    if unused_accounts.destroy_all
      puts "#{count} accounts destroyed"
    end
  end
end
