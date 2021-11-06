
# This should produce valid + condition met reminder (we are not using that gem)
# REMIND_ME: { missing_gem: 'non_existing_gem', message: 'Message 1'}

# This should produce valid + condition not met reminder (we are using that gem)
# REMIND_ME: { missing_gem: :parser, 'message' => "Message 2" }

# This should NOT produce valid reminder (parsing error)
# REMIND_ME: {{ missing_gem: 'parser', message: 'Message 3'}

# This should NOT produce valid reminder (not a hash, but we are also not doing `eval`)
# REMIND_ME: exit(1)

# This should produce valid + condition not met reminder (we are using that gem) with default message
# REMIND_ME: { missing_gem: 'parser' }