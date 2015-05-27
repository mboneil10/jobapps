class ApplicationTemplatesController < ApplicationController

  before_action :find_template, except: :new
  
  def new
    params.require :position_id
    template = ApplicationTemplate.create position_id: params[:position_id]
    redirect_to edit_template_path(template)
  end

  def edit
  end

  def show
    permit_student_access
  end

  private

  def find_template
    params.require :id
    @template = ApplicationTemplate.find params[:id]
  end

end
