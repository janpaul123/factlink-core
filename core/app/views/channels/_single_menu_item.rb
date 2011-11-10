module Channels
  class SingleMenuItem < Mustache::Railstache

    def self.for_channel_and_view(channel,view)
      smi = new()
      smi.view = view
      smi[:channel] = channel
      return smi
    end

    def link
      get_facts_for_channel_path(self[:channel].created_by.user.username, self[:channel].id)
    end
  
    def title
      self[:channel].title
    end
  
    def nr_of_facts
      self[:channel].unread_count
    end
  
    def new_facts
      (self[:channel].unread_count != 0) && self[:channel].created_by.user == current_user
    end

    def id
      self[:channel].id
    end
  
    def created_by_id
      self[:channel].created_by_id
    end
  
    def to_hash
      return {
                 :id => id,
               :link => link,
              :title => title,
          :new_facts => new_facts,
        :nr_of_facts => nr_of_facts,
      :created_by_id => created_by_id,
      }
    end
  end
  
end
