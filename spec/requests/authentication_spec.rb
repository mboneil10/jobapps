require 'rails_helper'

# Request specs don't include session data,
# equivalent to not being authenticated.
describe 'Authentication' do
  context 'unauthenticated user' do
    it 'redirects to unauthenticated session path' do
      get '/dashboard/staff'
      expect(response).to redirect_to unauthenticated_session_path
    end
  end
end
