require_relative 'application_controller'

class CommentsController < ApplicationController
  def create
    fact_id = get_fact_id_param
    @comment = interactor :"comments/create", fact_id, params[:opinion], params[:content]

    render 'comments/create'
  end

  def destroy
    comment_id = get_comment_id_param
    interactor :"comments/delete", comment_id

    render :json => {}, :status => :ok
  end

  def index
    fact_id = get_fact_id_param
    opinion = params[:opinion].to_s

    @comments = interactor :"comments/index", fact_id, opinion

    render 'comments/index'
  end

  private
    def get_fact_id_param
      id_string = params[:id]
      if id_string == nil
        raise 'No Fact id is supplied.'
      end

      id = id_string.to_i
      if id == 0
        raise 'No valid Fact id is supplied.'
      end

      id
    end

    def get_comment_id_param
      id_string = params[:id]
      if id_string == nil
        raise 'No Comment id is supplied.'
      end

      id_string
    end
end
