namespace :tokens do
  task :migrate_auth_tokens_to_token_table => :environment do
    User.all.each do |user|

      count = 1
      user.tokens_old.each do |token|
        user.tokens.create(token: token, token_type: 'auth') if token
        puts "#{count} tokens migrated for #{user.name}"
        count += 1
      end
      user.update(tokens_old: [])
    end
  end

  task :migrate_push_token => :environment do
    User.all.each do |user|
      user.tokens.create(token: user.push_token, token_type: 'push') if user.push_token
      puts "Push tokens migrated for #{user.name}"

      user.update(push_token: '')
    end
  end
end
