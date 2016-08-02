class SubmissionsController < ApplicationController
  layout 'additional_details'

  def new
    @service = Service.find(params[:service_id])
    @questionnaire = @service.questionnaires.first
    @submission = Submission.new
    @submission.questionnaire_responses.build
  end

  def create
    @service = Service.find(params[:service_id])
    @submission = Submission.new(submission_params)
    if @submission.save
      redirect_to service_questionnaires_path(@service)
    else
      render :new
    end
  end

  private

  def submission_params
    params.require(:submission).permit!
  end
end
