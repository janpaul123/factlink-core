class Ability
  class AdminArea;end
  class FactlinkWebapp;end

  include CanCan::Ability

  def user
    @user
  end

  def initialize(user=nil)
    @user=user

    # Anonymous user
    can :read, Job, :show => true
    can :check, Blacklist

    # Registered user
    if user

      if user.agrees_tos
        can :access, FactlinkWebapp
        define_channel_abilities
        define_fact_abilities
        define_fact_relation_abilities
        define_user_abilities
        define_user_activities_abilities
        define_topic_abilities
      else
        cannot :manage, :all
        can :sign_tos, user
        can :read, user
      end

      can :read_tos, user

      define_feature_toggles
    end
  end

  def define_channel_abilities
    if user
      can :index, Channel
      can :read, Channel
      can :manage, Channel do |ch|
        ch.created_by == user.graph_user
      end
    end
  end

  def define_fact_abilities
    can :index, Fact
    can :read, Fact
    can :get_evidence, Fact
    if user
      can :opinionate, Fact
      can :add_evidence, Fact
      can :manage, Fact do |f|
        f.created_by == user.graph_user
      end
    end
  end

  def define_fact_relation_abilities
    if user
      can :opinionate, FactRelation
    end
  end

  def define_user_abilities
    if user
      can :update, user
      can :read, user

      if user.admin?
        can :access, AdminArea
        can :manage, User
        can :manage, Job
        cannot :sign_tos, User
      end
    end
  end

  def define_user_activities_abilities
    if user
      can :index, Activity
      can :mark_activities_as_read, User do |u|
        u.id == user.id
      end
      can :see_activities, User do |u|
        u.id == user.id
      end
    end
  end
  
  def define_topic_abilities
    can :show, Topic
  end

  def define_feature_toggles
    if user.admin?
       can :see_feature_version_number, FactlinkWebapp
    end
    can :see_feature_beginners_hints, FactlinkWebapp if (user.sign_in_count || 0) < 10
    
    # enable as soon as we have related users only for channels, and this gives
    # a list of users sorted by authority for the topic of the channel
    #can :see_feature_authority_for_related_users, FactlinkWebapp
  end

end