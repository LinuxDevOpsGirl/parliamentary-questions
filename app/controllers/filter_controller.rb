include ActionView::Helpers::TextHelper

class FilterController < ApplicationController
  before_filter :load_questions_service

  def index
  	@message = "Please pick a date to display items"
  	if params[:search] != nil

      @results = Array.new


      @questions = @questions_service.questions()


      @questions.each do |q|
      	@results.push(q) if	q['TabledDate']==params[:search]

      end

      @message = "#{pluralize(@results.count,'item')} tabled on #{Date.parse(params[:search]).strftime('%-d %b %Y').to_s}"

      render 'index'
    end
  end

  protected

  def load_questions_service(service = QuestionsService.new)
    @questions_service ||= service
  end

end
