require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_templates/show.haml' do
  before :each do
    @record = create :application_record
  end
  context 'current user is student' do
    before :each do
      when_current_user_is :student, view: true 
    end
    it 'contains a form to submit the application' do
      render
      action_path = application_template_path @record
      expect(rendered).to have_form action_path, :post
    end
  end  
  context 'current user is staff' do
    before :each do
      when_current_user_is :staff, view: true
    end
    it 'shows the application form with no submit button'
  end
end
