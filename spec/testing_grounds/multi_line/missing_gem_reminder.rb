=begin
   This should produce valid + condition met reminder (we are not using that gem)
   REMIND_ME: { missing_gem: 'non_existing_gem', message: 'Message 1'}
=end
=begin
   This should produce valid + condition not met reminder (we are using that gem)
   REMIND_ME: { missing_gem: :parser, 'message' => "Message 2" }
=end
=begin
   This should NOT produce valid reminder (parsing error)
   REMIND_ME: {{ missing_gem: 'parser', message: 'Message 3'}
=end
=begin
   This should NOT produce valid reminder (not a hash, but we are also not doing eval!)
   REMIND_ME: exit(1)
=end
=begin
   This should NOT produce valid reminder (message missing)
   REMIND_ME: { missing_gem: 'parser' }
=end
