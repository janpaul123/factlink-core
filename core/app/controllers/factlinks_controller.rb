class FactlinksController < ApplicationController

  # before_filter :authenticate_admin!
  
  layout "client"

  def factlinks_for_url
    url = params[:url]
    site = Site.first(:conditions => { :url => url })
    
    @factlinks = if site
                 then site.factlinks
                 else []
                 end

    # Render the result with callback, 
    # so JSONP can be used (for Internet Explorer)
    render :json => @factlinks.to_json( :only => [:_id, :displaystring] ), 
                                        :callback => params[:callback]  
  end

  def show
    @factlink = Factlink.find(params[:id])
  end
  
  def new
    @factlink = Factlink.new
  end
  
  def edit
    @factlink = Factlink.find(params[:id])
  end
  
  # Prepare for create
  def prepare
    render :template => 'factlink_tops/prepare', :layout => nil
  end
  
  # Prepare for create
  def intermediate
    # TODO: Sanitize for XSS
    @url = params[:url]
    @passage = params[:passage]
    @fact = params[:fact]
    
    case params[:the_action]
    when "prepare"
      @path = "factlink_prepare_path"
    when "show"
      @path = "factlink_show_path(%x)" % :id
    else
      @path = ""
    end

    render :template => 'factlink_tops/intermediate', :layout => nil
  end

  def create
    # Creating a Factlink requires a url and fact ( > displaystring )
    # TODO: Refactor 'fact' to 'displaystring' for internal consistency
    
    # Get or create the website on which the Fact is located
    site = Site.find_or_create_by(:url => params[:url])


    # TODO: This can be changed to use only displaystring when the above
    # refactor is done.
    if params[:fact]
      displaystring = params[:fact]
    else
      displaystring = params[:factlink][:displaystring]
    end
    
    # Create the Factlink
    @factlink = Factlink.create!(:displaystring => displaystring, 
                                    :created_by => current_user,
                                    :site => site)

    # Redirect to edit action
    redirect_to :action => "edit", :id => @factlink.id
  end
  
  
  def create_as_source
    parent_id = params[:factlink][:parent_id]

    # Cleaner way for doing this?
    # Cannot create! the object with paramgs[:factlink],
    # since we have to add the current_user as well.
    # 
    # Adding current_user after create and saving again
    # is one unneeded save extra.
    displaystring = params[:factlink][:displaystring]
    url = params[:factlink][:url]
    content = params[:factlink][:content]

    # Create the Factlink
    @factlink = Factlink.create!(:displaystring => displaystring,
                                    :url => url,
                                    :content => content,
                                    :created_by => current_user)

    # Set the correct parent
    @factlink.set_parent parent_id
  end
  
  def update
    @factlink = Factlink.find(params[:id])

    respond_to do |format|
      if @factlink.update_attributes(params[:factlink])
        format.html { redirect_to(@factlink, 
                      :notice => 'Factlink top was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def believe
    @factlink = Factlink.find(params[:id])
    @factlink.add_believer current_user
    
    @class = "believe"
    render "update_source_li"
  end
  
  def doubt
    @factlink = Factlink.find(params[:id])
    @factlink.add_doubter current_user
    
    @class = "doubt"
    render "update_source_li"
  end
  
  def disbelieve
    @factlink = Factlink.find(params[:id])
    @factlink.add_disbeliever current_user
    
    @class = "disbelieve"
    render "update_source_li"
  end

end