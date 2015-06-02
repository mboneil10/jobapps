require 'rails_helper'

describe SiteTextsController do
  describe '#edit methods' do
    before :each do
      @site_text = create :site_text
    end
    context 'GET' do
      let :submit do
        get :edit, id: @site_text.id
      end
      context 'student' do
        it 'does not allow access' do
          set_current_user_to :student
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
      context 'staff' do
        before :each do
          set_current_user_to :staff
        end
        it 'renders the correct template' do
          submit
          expect(response).to render_template 'edit'
        end
      end
    end

    context 'POST' do
      before :each do
        @input = 'input'
      end
      let :submit do
        get :edit, id: @site_text.id, preview_input: @input
      end
      context 'student' do
        it 'does not allow access' do
          set_current_user_to :student
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
      context 'staff' do
        before :each do
          set_current_user_to :staff
        end
        it 'passes the preview input parameter through as an instance variable' do
          submit
          expect(assigns[:preview_input]).to eql @input
        end
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @site_text = create :site_text
      @changes = {text: 'new text'}
    end
    let :submit do
      put :update, id: @site_text.id, site_text: @changes
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      context 'invalid input' do
        before :each do
          @changes = {text: ''}
        end
        it 'redirects back with errors' do
          expect_redirect_to_back{submit}
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'updates the site text' do
          submit
          expect(@site_text.reload.text).to eql 'new text'
        end
        it 'includes a flash message' do
          submit
          expect(flash.keys).to include 'message'
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
    end
  end

  describe 'GET #request_new' do
    let :submit do
      get :request_new
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'request_new'
      end
    end
  end

  describe 'POST #request_new' do
    before :each do
      @location = 'requested location'
      @description = 'requested description'
    end
    let :submit do
      post :request_new, location: @location, description: @description
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      #TODO: Implement mailer method and mock here
      it 'sends IT an email'
      it 'includes a flash message' do
        submit
        expect(flash.keys).to include 'message'
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
    end
  end
end