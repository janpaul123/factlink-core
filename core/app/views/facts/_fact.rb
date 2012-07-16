module Facts
  class Fact < Mustache::Railstache
    include BaseViews::FactBase

    def init
      self[:timestamp] ||= 0
    end

    def no_evidence_message
      if user_signed_in?
        "Perhaps you know something that supports or weakens this fact?"
      else
        "There are no Factlinks supporting or weakening this Factlink at the moment."
      end
    end

    def delete_from_channel_link
      remove_from_channel_path
    end

    def deletable_from_channel?
      user_signed_in? and self[:channel] and self[:channel].editable? and self[:channel].created_by == current_graph_user
    end

    def remove_from_channel_path
      if self[:channel] and current_user
        fast_remove_fact_from_channel_path(current_user.username, self[:channel].id, self[:fact].id)
      end
    end

    def i_am_owner
      (self[:fact].created_by == current_graph_user)
    end

    def my_authority
      auth = Authority.on(self[:fact], for: current_graph_user)
      return false if auth.to_f == 0.0

      (auth.to_s.to_f + 1.0).to_s
    end

    def ajax_loader_image
      image_tag("ajax-loader.gif")
    end

    def evidence_search_path
      evidence_search_fact_path(self[:fact].id)
    end

    def prefilled_search_value
      params[:s] ? 'value="#{params[:s]}"' : ""
    end

    def modal?
      if self[:modal] != nil
        self[:modal]
      else
        false
      end
    end

    def fact_bubble
      Facts::FactBubble.for(fact: self[:fact], view: self.view).to_hash
    end

    def url
      friendly_fact_path(self[:fact])
    end

    def post_action
      if self[:fact].created_by == self[:channel].created_by #current_user
        'Posted'
      else
        'Reposted'
      end
    end

    def friendly_time
      time_ago_in_words(Time.at(self[:timestamp]/1000)) if self[:channel]
    end

    expose_to_hash :timestamp
  end
end
