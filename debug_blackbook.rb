require 'blackbook'

aol = Blackbook.get :username => 'mondragonmichael@aol.com', :password => '123aol0'
puts "===== aol #{aol.inspect}"

unless aol.detect{|c| c[:name].downcase == 'Dave Myron'.downcase && c[:email] == 'dave.myron@contentfree.com'}
  puts "AOL not working"
  exit 1
end

