require 'rails_helper'

describe 'viewing the dashboard as a student' do
  let!(:student) { create :user, staff: false }
  before :each do
    when_current_user_is student, integration: true
  end
  context 'student has submitted an application' do
    context 'student got an interview' do
      let!(:interview) { create :interview, user: student }
      before :each do
        visit student_dashboard_url
      end
      it 'displays the date, time, and location of any interviews' do
        expect(page).to have_text interview.information
      end
      it 'contains a link to review the application' do
        click_link 'Review your application',
                   href: application_record_path(interview.application_record)
        expect(page.current_url)
          .to eql application_record_url(interview.application_record)
      end
    end # of student got an interview
    context 'student did not get an interview' do
      let!(:pending_application) do
        create :application_record,
               reviewed: false,
               user: student
      end
      let!(:denied_application) do
        create :application_record,
               reviewed: true,
               user: student,
               staff_note: 'No'
      end
      before :each do
        visit student_dashboard_url
      end
      context 'configured value notify of application denial reason is true' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return true
        end
        it 'contains a link to review the pending application' do
          click_link 'Review your application',
                     href: application_record_path(pending_application)
          expect(page.current_url)
            .to eql application_record_url(pending_application)
          expect(page).to have_text 'Your application is pending'
          expect(page).to have_text 'You will be notified'
          expect(page).to have_text 'when your application has been reviewed'
        end
        context 'configured value provide reason is set to false' do
          before :each do
            allow_any_instance_of(ApplicationConfiguration)
              .to receive :configured_value
            allow_any_instance_of(ApplicationConfiguration)
              .to receive(:configured_value)
              .with([:on_application_denial, :notify_of_reason], anything)
              .and_return false
          end
          it 'has link to see denied app, without text of denial reason' do
            click_link 'Review your application',
                       href: application_record_path(denied_application)
            expect(page.current_url)
              .to eql application_record_url(denied_application)
            expect(page).to have_text 'Your application has been denied.'
            expect(page).not_to have_text 'Reason: No'
          end
        end
        context 'configured value provide reason is set to true' do
          before :each do
            allow_any_instance_of(ApplicationConfiguration)
              .to receive :configured_value
            allow_any_instance_of(ApplicationConfiguration)
              .to receive(:configured_value)
              .with([:on_application_denial, :notify_of_reason], anything)
              .and_return true
          end
          it 'has link to see the denied app, with text of denial reason' do
            click_link 'Review your application',
                       href: application_record_path(denied_application)
            expect(page.current_url)
              .to eql application_record_url(denied_application)
            expect(page)
              .to have_text 'Your application has been denied. Reason: No'
            # reason is the staff note.
          end
        end
      end # of configured value true
      context 'configured value notify of application denial reason is false' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return false
        end
        it 'contains a link to review pending applications' do
          click_link 'Review your application',
                     href: application_record_path(pending_application)
          expect(page.current_url)
            .to eql application_record_url(pending_application)
          expect(page).to have_text 'Your application is pending'
        end
        it 'does not contain a link to review denied applications' do
          action_path = application_record_path(denied_application)
          expect page.has_no_link? 'Review your application',
                                   href: action_path
        end
      end # of configured value false
    end # of student did not get an interview
  end # of student has submitted an application
  context 'student has not yet submitted an application' do
    before :each do
      visit student_dashboard_url
    end
    context 'position exists, but applications have not been created' do
      let!(:positn_not_hiring) { create :position }
      context 'deactivated application text has been configured' do
        it 'displays the custom text for the position not hiring' do
          allow_any_instance_of(Position)
            .to receive(:configured_not_hiring_text)
          expect_any_instance_of(Position)
            .to receive(:configured_not_hiring_text)
            .and_return 'custom text'
          visit current_url
          expect(page).to have_text 'custom text'
        end
      end
      context 'deactivated application text has not been configured' do
        it 'displays the default not-hiring text' do
          expect(page)
            .to have_text
          "Applications are currently unavailable for #{positn_not_hiring.name}"
        end
      end
    end
    context 'applications have been created for a position, but are inactive' do
      let!(:inactive_app) do
        create :application_template,
               active: false
      end
      context 'deactivated application text has been configured' do
        it 'displays the custom text for the position not hiring' do
          allow_any_instance_of(Position)
            .to receive(:configured_not_hiring_text)
          expect_any_instance_of(Position)
            .to receive(:configured_not_hiring_text)
            .and_return 'custom text'
          visit current_url
          expect(page).to have_text 'custom text'
        end
      end
      context 'deactivated application text has not been configured' do
        it 'displays the default not-hiring text' do
          expect(page)
            .to have_text
          "We are not currently hiring for #{inactive_app.position.name}"
        end
      end
    end
    context 'applications are active for that position' do
      let!(:active_application) do
        create :application_template,
               active: true
      end
      it 'shows links to submit the application' do
        visit current_url
        # page must be reloaded, as we first visited the page before this
        # application was created
        click_link "Submit application for #{active_application.position.name}"
        expect(page.current_url).to eql application_url(active_application)
      end
    end
  end # of student has not yet submitted an application
end
