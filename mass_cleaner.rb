require 'csv'    

print "What's the number of the column you want to de-dupe?: "
column = gets.chomp.to_i - 1

written = Array.new
mega_csv = CSV.open("full_cleaned_engagements.csv", "wb") 
duplicates = 0

print "Working..."

Dir.foreach('.') do |file|
	if file == '.' or file == '..' or file == 'mass_cleaner.rb'
		next
	end

#	CSV.foreach(File.path(file), :encoding => 'ISO-8859-1', quote_char: "\x00") do |col|
	CSV.foreach(File.path(file), :encoding => 'ISO-8859-1') do |col|
		next if col.include? "\n"
		begin
			if ((col[column] != nil) && (written.include?(col[column])))
				duplicates += 1
				next
			else
				mega_csv << col.each { |i| [i].to_csv }
				written.push(col[column])
			end
		rescue CSV::MalformedCSVError
			next
		else
			print '.'
		end
	end
end

mega_csv.close
new_csv = CSV.open("split_0.csv", "wb") 

puts "\nOkay, done de-duping. Cleaned up #{duplicates} duplicates."
sleep 1
puts "Splitting mega CSV into rows of 2000..."

division = 2000
counter = 0
headers = false

CSV.foreach(File.path('full_cleaned_engagements.csv'), headers: true) do |row|
	counter += 1

	if (counter % division == 0)
		headers = false
		new_csv.close
		new_csv = CSV.open("split_#{counter / division}.csv", "wb") 
	end

	unless headers
		new_csv << row.headers
		headers = true
	end

	new_csv << row.each do |i| [i.to_s] end
end	
