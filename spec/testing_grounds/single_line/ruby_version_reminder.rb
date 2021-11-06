# This should produce valid + condition met reminder (we are using that ruby version)
# REMIND_ME: { ruby_version: '2.3.1', condition: :eq, message: 'Message 1'}

# This should produce valid + condition met reminder (we are using that ruby version)
# REMIND_ME: { ruby_version: '2.3.1', condition: 'eq', message: 'Message 2'}

# This should produce valid + condition met reminder (we are using that ruby version - condition is missing, defaults to eq)
# REMIND_ME: { ruby_version: '2.3.1', message: 'Message 3'}

# This should produce valid + condition met reminder (we are using lower ruby version)
# REMIND_ME: { ruby_version: '2.4', 'condition' => 'lte', message: 'Message 4'}

# This should produce valid + condition met reminder (we are using that ruby version)
# REMIND_ME: { ruby_version: '2.3.1', 'condition' => 'lte', message: 'Message 5'}

# This should produce valid + condition NOT met reminder (we are using ruby version greater than that)
# REMIND_ME: { ruby_version: '2.0', 'condition' => 'lte', message: 'Message 6'}

# This should produce valid + condition NOT met reminder (we are using that ruby version lower than that)
# REMIND_ME: { ruby_version: '2.4', condition: :gte, message: 'Message 7'}

# This should produce valid + condition met reminder (we are using that ruby version equal to or greater than that)
# REMIND_ME: { ruby_version: '2.3.1', condition: :gte, message: 'Message 8'}

# This should produce valid + condition met reminder (we are using that ruby version greater than that)
# REMIND_ME: { ruby_version: '2.0', condition: :gte, message: 'Message 9'}

# This should produce valid + condition met reminder (we are using ruby version lower than that)
# REMIND_ME: { ruby_version: '2.4', condition: :lt, message: 'Message 10'}

# This should produce valid + condition NOT met reminder (we are using that exact ruby version)
# REMIND_ME: { ruby_version: '2.3.1', condition: :lt, message: 'Message 11'}

# This should produce valid + condition NOT met reminder (we are using greater ruby version)
# REMIND_ME: { ruby_version: '2.0', condition: :lt, message: 'Message 12'}

# This should produce valid + condition NOT met reminder (we are using lower ruby version)
# REMIND_ME: { ruby_version: '2.4', 'condition' => 'gt', message: 'Message 13'}

# This should produce valid + condition NOT met reminder (we are using lower ruby version)
# REMIND_ME: { ruby_version: '2.3.1', 'condition' => 'gt', message: 'Message 14'}

# This should produce valid + condition met reminder (we are using greater ruby version)
# REMIND_ME: { ruby_version: '2.0', 'condition' => 'gt', message: 'Message 15'}

# This should NOT produce valid reminder (parsing error)
# REMIND_ME: {{ ruby_version: '2.0', 'condition' => 'gt', message: 'Message 16' }

# This should NOT produce valid reminder (not a hash, but we are also not doing `eval`)
# REMIND_ME: exit 1

# This should produce valid + condition not met reminder (message missing, default will be used)
# REMIND_ME: { ruby_version: '2.0', 'condition' => 'gt' }

# This should NOT produce valid reminder (bad condition)
# REMIND_ME: { ruby_version: '2.0', condition: :bla, message: 'Message 17' }