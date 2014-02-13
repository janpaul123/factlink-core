class SubCommentsController < ApplicationController
  pavlov_action :index, Interactors::SubComments::IndexForComment

  def create
    sub_comment = interactor(:'sub_comments/create_for_comment',
                                  comment_id: comment_id, content: params[:content])
    render json: sub_comment
  rescue Pavlov::ValidationError
    render text: 'something went wrong', status: 400
  end

  def destroy
    @sub_comment = interactor(:'sub_comments/destroy', id: params[:sub_comment_id])
    render json: {}, status: :ok
  end

  def comment_id
    params[:comment_id]
  end
end
