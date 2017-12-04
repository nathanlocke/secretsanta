require 'mail'
require 'active_support/all'

class Santa
	attr_reader :name, :email, :address
	attr_accessor :match

	def initialize(nameIn, emailIn, addressIn)
		@name = nameIn
		@email = emailIn
		@address = addressIn
		#@match = nil
	end

	def to_s
		@name + " " + @email + " match:" + (@match.name || '' ) + "\n"
	end
end

def run()
	puts 'starting'

	A = Santa.new("A","Auseremail@email.com","A\n111 Address Dr\nCity, ST 11111")
	B = Santa.new("B", "Buseremail@email.com", "B\n222 Address Ct\nTown, ST 22222")
	C = Santa.new("C","Cuseremail@email.com","C\n333 Address Ave\nVillage, ST 33333")
	D = Santa.new("D", "Duseremail@email.com", "D\n444 Address Rd\nCity, ST 44444")
	E = Santa.new("E","Euseremail@email.com","E\n555 Address Blvd\nTown, ST 55555")
	F = Santa.new("F","Fuseremail@email.com","F\n666 Address St\nVillage, ST 66666")

	participants = [A,B,C,D,E,F]

	matchups = Array.new(participants)

	resultsUnique = false
	puts 'shuffling...'
	while not resultsUnique
		matchups.shuffle!
		#puts "match: " + matchups.to_s
		resultsUnique = checkUnique(participants,matchups)
	end #while

	counter = 0
	participants.each do |par|
		par.match = matchups[counter]
		counter+=1
	end

	#puts participants.to_s
	participants.each do |par|
		sendEmail(from: "<From Email>",
			to: par.email,
			subject: "Secret santa assignment",
			body: "The following person was assigned to you for secret santa: #{par.match.name}\n\n Their address is:\n#{par.match.address}" + 
			"\n\nReminder that gifts should be mailed no later than <DATE> so they arrive in a timely manner"
		)
	end

end#run

def checkUnique(partIn, matchIn)
	isunique = true
	counter=partIn.length-1
	while isunique and counter >= 0
		isunique = partIn[counter].name != matchIn[counter].name
		counter -= 1
	end
	isunique
end

def sendEmail(options={})
	domain = options[:domain] || "gmail.com"
	defaults = {
		subject: "An Error was generated from #{__FILE__}",
		to: "<developer email>",
		body: "The following error has occured: #{options[:error]}",
		from: ENV["COMPUTERNAME"] + "@" + domain,
		SMTP: "smtp.gmail.com"
	}
	
	options = options.reverse_merge(defaults) #mash up the options passed in parameters with defaults defined above

	begin	
		puts "begin"
	
		mailoptions = { 
			:address              => "smtp.gmail.com",
			:port 				  => 587,
			:user_name			  => '<gmail username>',
			:password             => '<gmail password>',
			:authentication       => 'plain',
			:enable_starttls_auto => true
		}
		 
		Mail.defaults do
			delivery_method :smtp, mailoptions
		end
		#puts email.to_s
		
		Mail.deliver do
			to options[:to]
			from options[:from]
			subject options[:subject]
			body options[:body]
			add_file options[:file] if options[:file] && File.exists?(options[:file])
		end
		puts "...sent to #{options[:to]}"
	rescue Exception => e
		puts "error sending email: #{options.to_a.to_s} : #{e} \n #{e.backtrace}"
	end
end


run()e