class FactlinksController < ApplicationController

  ##########
  # Retrieve the Factlinks for this URL
  # TODO: Will be replaced soon. URL matching is quick for development,
  # but we want to check Factlinks in the complete text on the website.
  def factlink_tops_for_url
    # TODO: Error handling when no url is given.
    @url = params[:url]
    
    # Should only give 0 or 1 result(s), 
    # since we are currently making an exact match on the URL.
    sites = Site.where(:url => @url)
    
    # Get the entries for the Site if found, else return an empty array
    if sites.count > 0 then @factlinks = sites[0].factlink_tops.entries else @factlinks = [] end
  
    render :json => @factlinks.to_json(:only => [:_id, :displaystring]) #}
  end
  
  
  ##########
  # Retrieve the FactlinkSubs for the submitted Factlink.
  def factlink_subs_for_factlink_id
    # TODO: Error handling when no ID is given.
    id = params[:factlink_top_id] #|| '4d6651f2c09808d296000001'
    
    factlink_top = FactlinkTop.find(id)
    @factlink_subs = factlink_top.factlink_subs.entries
    
    render :json => @factlink_subs
  end

# 
#   ##########
#   # GET /factlinks
#   # GET /factlinks.xml
#   def index
#     @factlinks = Factlink.all
# 
#     respond_to do |format|
#       format.html # index.html.erb
#       format.xml  { render :xml => @factlinks }
#     end
#   end
# 
#   # GET /factlinks/1
#   # GET /factlinks/1.xml
#   def show
#     @factlink = Factlink.find(params[:id])
# 
#     respond_to do |format|
#       format.html # show.html.erb
#       format.xml  { render :xml => @factlink }
#     end
#   end
# 
#   # GET /factlinks/new
#   # GET /factlinks/new.xml
#   def new
#     @factlink = Factlink.new
# 
#     respond_to do |format|
#       format.html # new.html.erb
#       format.xml  { render :xml => @factlink }
#     end
#   end
# 
#   # GET /factlinks/1/edit
#   def edit
#     @factlink = Factlink.find(params[:id])
#   end
# 
#   # POST /factlinks
#   # POST /factlinks.xml
#   def create
#     @factlink = Factlink.new(params[:factlink])
# 
#     respond_to do |format|
#       if @factlink.save
#         format.html { redirect_to(@factlink, :notice => 'Factlink was successfully created.') }
#         format.xml  { render :xml => @factlink, :status => :created, :location => @factlink }
#       else
#         format.html { render :action => "new" }
#         format.xml  { render :xml => @factlink.errors, :status => :unprocessable_entity }
#       end
#     end
#   end
# 
#   # PUT /factlinks/1
#   # PUT /factlinks/1.xml
#   def update
#     @factlink = Factlink.find(params[:id])
# 
#     respond_to do |format|
#       if @factlink.update_attributes(params[:factlink])
#         format.html { redirect_to(@factlink, :notice => 'Factlink was successfully updated.') }
#         format.xml  { head :ok }
#       else
#         format.html { render :action => "edit" }
#         format.xml  { render :xml => @factlink.errors, :status => :unprocessable_entity }
#       end
#     end
#   end
# 
#   # DELETE /factlinks/1
#   # DELETE /factlinks/1.xml
#   def destroy
#     @factlink = Factlink.find(params[:id])
#     @factlink.destroy
# 
#     respond_to do |format|
#       format.html { redirect_to(factlinks_url) }
#       format.xml  { head :ok }
#     end
#   end


end