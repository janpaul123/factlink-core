class FactsController < ApplicationController
  include FactHelper

  layout "client"

  before_filter :set_layout, :only => [:new, :create]

  respond_to :json, :html

  before_filter :parse_pagination_parameters,
    only: [:believers, :disbelievers, :doubters]

  before_filter :load_fact,
    :only => [
      :show,
      :extended_show,
      :destroy,
      :update,
      :opinion,
      :evidence_search,
      ]

  around_filter :allowed_type,
    :only => [:set_opinion ]

  def show
    authorize! :show, @fact

    @modal = true

    respond_to do |format|
      format.html do
        render inline:'', layout: 'client'
      end
      format.json do
        render json: Facts::Fact.for(fact: @fact, view: view_context)
      end
    end
  end

  def extended_show
    authorize! :show, @fact
    render_backbone_page
  end

  def believers
    fact_id = params[:id].to_i
    data = interactor :fact_believers, fact_id, @skip, @take

    render_interactions data
  end

  def disbelievers
    fact_id = params[:id].to_i
    data = interactor :fact_disbelievers, fact_id, @skip, @take

    render_interactions data
  end

  def doubters
    fact_id = params[:id].to_i
    data = interactor :fact_doubters, fact_id, @skip, @take

    render_interactions data
  end

  def intermediate
    render layout: nil
  end

  def new
    authorize! :new, Fact

    if current_user
      render inline:'', layout: 'client'
      track "Modal: Open prepare"
    else
      session[:return_to] = new_fact_path(layout: @layout, title: params[:title], fact: params[:fact], url: params[:url])
      redirect_to user_session_path(layout: 'client')
    end
  end

  def create
    # support both old names, and names which correspond to json in show
    fact_text = (params[:fact] || params[:displaystring]).to_s
    url = (params[:url] || params[:fact_url]).to_s
    title = (params[:title] || params[:fact_title]).to_s

    unless current_user
      session[:return_to] = new_fact_path(layout: @layout, title: title, fact: fact_text, url: url)
      redirect_to user_session_path(layout: @layout)
      return
    end

    authorize! :create, Fact


    @fact = Fact.build_with_data(url, fact_text, title, current_graph_user)
    @site = @fact.site


    respond_to do |format|
      if @fact.data.save and @fact.save

        track "Factlink: Created"

        #TODO switch the following two if blocks if possible
        if @fact and (params[:opinion] and [:beliefs, :believes, :doubts, :disbeliefs, :disbelieves].include?(params[:opinion].to_sym))
          @fact.add_opinion(params[:opinion].to_sym, current_user.graph_user)
          Activity::Subject.activity(current_user.graph_user, Opinion.real_for(params[:opinion]), @fact)

          @fact.calculate_opinion(1)
        end

        if params[:channels]
          params[:channels].each do |channel_id|
            channel = Channel[channel_id]
            if channel # in case the channel got deleted between opening the add-fact dialog, and submitting
              interactor :"channels/add_fact", @fact, channel
            end
          end
        end

        format.html do
          track "Modal: Create"
          redirect_to fact_path(@fact.id, just_added: true, guided: params[:guided])
        end
        decorated_fact = Facts::Fact.for(fact: @fact,view: view_context)
        format.json { render json: decorated_fact}
      else
        format.html { render :new }
        format.json { render json: @fact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! :destroy, @fact

    @fact_id = @fact.id
    @fact.delete

    respond_with(@fact)
  end

  # This update now only supports setting the title, for use in Backbone Views
  def update
    authorize! :update, @fact

    @fact.data.title = params[:title]

    if @fact.data.save
      render :json => {}, :status => :ok
    else
      render :json => @fact.errors, :status => :unprocessable_entity
    end
  end

  def opinion
    render :json => {"opinions" => @fact.get_opinion(3).as_percentages}, :callback => params[:callback], :content_type => "text/javascript"
  end

  def set_opinion
    type = params[:type].to_sym
    @basefact = Basefact[params[:id]]

    authorize! :opinionate, @basefact

    @basefact.add_opinion(type, current_user.graph_user)
    Activity::Subject.activity(current_user.graph_user, Opinion.real_for(type), @basefact)

    @basefact.calculate_opinion(2)

    render 'facts/_fact_wheel', format: :json, locals: {fact: @basefact}
  end

  def remove_opinions
    @basefact = Basefact[params[:id]]

    authorize! :opinionate, @basefact

    @basefact.remove_opinions(current_user.graph_user)
    Activity::Subject.activity(current_user.graph_user,:removed_opinions,@basefact)
    @basefact.calculate_opinion(2)

    render 'facts/_fact_wheel', format: :json, locals: {fact: @basefact}
  end

  # TODO: This search is way to simple now, we need to make sure already
  # evidenced Factlinks are not shown in search results and therefore we need
  # to move this search to the evidence_controller, to make sure it's
  # type-specific
  def evidence_search
    authorize! :index, Fact
    search_for = params[:s]

    results = interactor :search_evidence, search_for, @fact.id

    facts = results.map { |result| Facts::FactBubble.for(fact: result.fact, view: view_context) }

    render json: facts
  end

  private
    def load_fact
      id = params[:fact_id] || params[:id]

      @fact = Fact[id] || raise_404
    end

    def allowed_type
      allowed_types = [:beliefs, :doubts, :disbeliefs,:believes, :disbelieves]
      type = params[:type].to_sym
      if allowed_types.include?(type)
        yield
      else
        render :json => {"error" => "type not allowed"}, :status => 500
        false
      end
    end

    def parse_pagination_parameters
      params[:skip] ||= '0'
      @skip = params[:skip].to_i

      params[:take] ||= '3'
      @take = params[:take].to_i
    end

    def render_interactions data
      @users = data[:users]
      @total = data[:total]

      render 'facts/interactions', format: 'json'
    end
end
