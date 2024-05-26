require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'Time'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(code)
  code.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'
puts

path = '/Users/ongks/Documents/The_Odin_Project/12_event_manager/event_attendees.csv'
erb_template = '/Users/ongks/Documents/The_Odin_Project/12_event_manager/form_letter.erb'

template_letter = File.read(erb_template)
erb_template = ERB.new template_letter

contents = CSV.open(path, headers: true, header_converters: :symbol)

# Iteration 0 - 4
contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

# Assignment: Clean phone number
def tidy_contact(contact)
  status = (contact.length < 10) || ((contact.length == 11) && (contact[0] != 1)) || (contact.length > 11)

  if status
    'Bad Number'
  elsif (contact.length == 11) && (contact[0] == 1)
    contact = contact[1..]
    "#{contact[0..2]}-#{contact[3..5]}-#{contact[6..]}"
  else
    "#{contact[0..2]}-#{contact[3..5]}-#{contact[6..]}"
  end
end

contents.each do |row|
  contact = row[:homephone].gsub(/[()-.\s]/, '')
  contact = tidy_contact(contact)

  puts contact
end

# Assignment: Time targeting & Day of the Week
contents.each do |row|
  reg_date = row[:regdate]

  dt = Time.strptime(reg_date, '%m/%d/%y %H:%M')

  puts dt.hour
  puts dt.strftime('%A')
end
