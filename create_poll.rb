print "\n\nCreate poll script"
print "\n=================="

print "\n\nPoll name (internal, used to refer to in your views):"
poll_name = gets.chop

print "\n\nPoll is multiple option? (y/n)"
multiple_str = gets.chop

max_multiple = 1
if multiple_str.upcase == 'Y'
  multiple = true
  max_multiple_str = nil
  #Capture max_multple options
  until max_multiple_str =~ /\d+/
    print "\n\nWhich is the maximum number of posible selected options (default = 1):"
    max_multiple_str = gets.chop
  end
  
  #Convert string to integer
  if max_multiple_str =~ /\d+/
    max_multiple = max_multiple_str.to_i
  end
else
  multiple = false
end


#Helper method to capture dates
def capture_date(capture_text)
  date_str = nil
  until date_str =~ /(\d{4})-(\d{2})-(\d{2})/ || date_str == ''
    print capture_text
    date_str= gets.chop
    unless date_str =~ /(\d{4})-(\d{2})-(\d{2})/ || date_str == ''
      print "\n\nIncorrect date format."
    end
  end

  #create an appropiate date
  date = nil
  unless date_str == ''
    date = Date.new($1.to_i, $2.to_i, $3.to_i)
  end
end

start_date = capture_date("\n\nEnter poll start date (YYYY-MM-DD) or press ENTER to skip:")
end_date = capture_date("\n\nEnter poll end date (YYYY-MM-DD) or press ENTER to skip:")

print "\n\nPoll question: "
question = gets.chop

i = 1
answers = []

answer = nil

until answer == ''
  print "\n\nPoll answer no. #{i} (press ENTER to finish): "
  answer = gets.chop
  print "\n"
  i += 1
  answers.push answer unless answer == ''
end

#Define Target for the poll
target = nil
until target =~ /\d/
  print "\n\nWho can vote:"
  print "\n\n\t1 - Logged User"
  print "\n\n\t2 - Anonymous only"
  print "\n\n\t3 - Both (defualt)"
  print "\n\n\tPress the desired option (ENTER takes the default configuration): "
  target = gets.chop
end

print "\n\nSAVE POLL? (y/n)"
ans = gets.chop

exit unless ans.upcase == 'Y'

#Save the poll data in the database
Poll.transaction do
  ar_question = Poll.new :name => poll_name, :description => question
  ar_question.start_date = start_date unless start_date.blank?
  ar_question.end_date = end_date unless end_date.blank?
  ar_question.multiple = multiple
  ar_question.max_multiple = max_multiple
  ar_question.target = target
  ar_question.save!
  
  answers.each { |answer|
    ar_answer = PollOption.new(:description => answer)
    ar_answer.poll = ar_question
    ar_answer.save!
  }
end

print "\n\nPoll #{poll_name} created."
