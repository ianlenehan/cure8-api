User.destroy_all
me = User.create(first_name: 'Ian', last_name: 'Lenehan', phone: '0410872627', email: 'ianlenehan@gmail.com')

5.times do |n|
  User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: Faker::Number.number(10))
end

Tag.destroy_all
Tag.create(name: 'football')
Tag.create(name: 'politics')
Tag.create(name: 'cats')
