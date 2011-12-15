# Используя символ ':user', мы указываем Factory Girl на необходимость симулировать модель User.

Factory.define :user do |user|
  user.name  "Michael"
  user.email "mhart@example.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end


Factory.sequence :email do |n|
  "person-#{n}@example.com"
end
