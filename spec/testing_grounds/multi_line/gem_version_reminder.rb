=begin
  This should produce valid + condition met reminder (we are using that gem with that version)
  REMIND_ME: { gem: 'parser', version: '3.0.2.0', condition: :eq, message: 'Message 1'}
=end
=begin
  This should produce valid + condition met reminder (we are using that gem with that version - condition is missing, defaults to eq)
  REMIND_ME: { 'gem' => 'parser', version: '3.0.2.0', message: 'Message 2'}
=end
=begin
  This should NOT reminder (version is missing and default value is not available for it)
  REMIND_ME: { gem: 'parser', message: 'Message 3'}
=end
=begin
  This should produce valid + condition met reminder (we are using that gem + lte)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', 'condition' => 'lte', message: 'Message 4'}
=end
=begin
  This should produce valid + condition met reminder (we are using that gem + gte)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', condition: :gte, message: 'Message 5'}
=end
=begin
  This should produce valid + condition not met reminder (we are using that gem but condition is lt)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', condition: :lt, message: 'Message 6'}
=end
=begin
  This should produce valid + condition not met reminder (we are using that gem + gt)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', 'condition' => 'gt', message: 'Message 7'}
=end
=begin
  This should NOT produce valid reminder (parsing error)
  REMIND_ME: {{ gem: 'parser',  version: '3.0.2.0', 'condition' => 'gt', message: 'Message 8'}
=end
=begin
  This should NOT produce valid reminder (not a hash, but we are also not doing eval!)
  REMIND_ME: exit 1
=end
=begin
  This should NOT produce valid reminder (gem value is not a string or symbol)
  REMIND_ME: { gem: parser,  version: '3.0.2.0', 'condition' => 'gt'}
=end
=begin
  This should NOT produce valid reminder (gem value is blank)
  REMIND_ME: { gem: '',  version: '3.0.2.0', 'condition' => 'gt'}
=end
=begin
  This should NOT produce valid reminder (gem value is nil)
  REMIND_ME: { gem: nil,  version: '3.0.2.0', 'condition' => 'gt'}
=end
=begin
  This should produce valid + condition not met reminder (with default message)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', 'condition' => 'gte'}
=end
=begin
  This should NOT produce valid reminder (bad condition)
  REMIND_ME: { gem: 'parser',  version: '3.0.2.0', 'condition' => :bla, message: 'Message 9'}
=end