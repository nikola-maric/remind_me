# This should produce valid + condition met reminder (we are using that gem with that version)
# REMIND_ME: { gem: 'ast', version: '2.4.2', condition: :eq, message: 'Message 1'}

# This should produce valid + condition met reminder (we are using that gem with that version - condition is missing, defaults to eq)
# REMIND_ME: { 'gem' => 'ast', version: '2.4.2', message: 'Message 2'}

# This should NOT reminder (version is missing and default value is not available for it)
# REMIND_ME: { gem: 'ast', message: 'Message 3'}

# This should produce valid + condition met reminder (we are using that gem + lte)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', 'condition' => 'lte', message: 'Message 4'}

# This should produce valid + condition met reminder (we are using that gem + gte)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', condition: :gte, message: 'Message 5'}
#
# This should produce valid + condition not met reminder (we are using that gem but condition is lt)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', condition: :lt, message: 'Message 6'}

# This should produce valid + condition not met reminder (we are using that gem + gt)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', 'condition' => 'gt', message: 'Message 7'}

# This should NOT produce valid reminder (parsing error)
# REMIND_ME: {{ gem: 'ast',  version: '2.4.2', 'condition' => 'gt', message: 'Message 8'}

# This should NOT produce valid reminder (not a hash, but we are also not doing eval!)
# REMIND_ME: exit 1

# This should NOT produce valid reminder (gem value is not a string or symbol)
# REMIND_ME: { gem: ast,  version: '2.4.2', 'condition' => 'gt'}

# This should NOT produce valid reminder (gem value is blank)
# REMIND_ME: { gem: '',  version: '2.4.2', 'condition' => 'gt'}

# This should NOT produce valid reminder (gem value is nil)
# REMIND_ME: { gem: nil,  version: '2.4.2', 'condition' => 'gt'}

# This should produce valid + condition not met reminder (with default message)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', 'condition' => 'gte'}

# This should NOT produce valid reminder (bad condition)
# REMIND_ME: { gem: 'ast',  version: '2.4.2', 'condition' => :bla, message: 'Message 9'}