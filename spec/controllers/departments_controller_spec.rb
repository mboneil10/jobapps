require 'rails_helper'

describe DepartmentsController do
  describe 'POST #create' do
    before :each do
      @department = attributes_for :department
    end
    let :submit do
      post :create, department: @department
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
          @department = {name: ''}
        end
        it 'shows errors' do
          expect_redirect_to_back{submit}
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'saves the department' do
          expect{submit}.to change{Department.count}.by 1
        end
        it 'displays a flash message' do
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

  describe 'DELETE #destroy' do
    before :each do
      @department = create :department 
    end
    let :submit do
      delete :destroy, id: @department.id
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
     it 'destroys the department' do
       expect{submit}.to change{Department.count}.by -1
     end
     it 'flashes a confirmation message' do
       submit
       expect(flash.keys).to include 'message'
     end
     it 'redirects to staff dashboard' do
       submit
       expect(response).to redirect_to staff_dashboard_path
     end
    end
  end

  describe 'GET #edit' do
    before :each do
      @department = create :department
    end
    let :submit do
      get :edit, id: @department.id
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
      it 'renders the template' do
        submit
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'GET #new' do
    let :submit do
      get :new
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
      it 'renders the template' do
        submit
        expect(response).to render_template 'new'
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @department = create :department
      @changes = {name: 'Operations'}
    end
    let :submit do
      put :update, {id: @department.id, department: @changes}
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
      it 'updates the department' do
        submit
        expect(@department.reload.name).to eql 'Operations'
      end
      it 'flashes a confirmation message' do
        submit
        expect(flash.keys).to include 'message'
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
      context 'invalid input' do
        before :each do
          @changes = {name: ''}
        end
        it 'flashes an error message' do
          expect_redirect_to_back{submit}
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end
end