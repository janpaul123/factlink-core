require_relative '../../util/mixpanel'

module Interactors
  module Users
    class Delete
      include Pavlov::Interactor
      include Util::CanCan
      include Util::Mixpanel

      attribute :user_id, String
      attribute :current_user_password, String
      attribute :pavlov_options

      def authorized?
        can? :destroy, user
      end

      private

      def user
        @user ||= User.find user_id
      end

      def validate
        validate_hexadecimal_string :user_id, user_id
        raise Pavlov::ValidationError unless password_valid
      end

      def password_valid
        pavlov_options[:current_user].valid_password? current_user_password
      end

      def execute
        command :'users/mark_as_deleted', user: user
        command :'users/anonymize_user_model', user_id: user_id
        track_user_delete
      end

      def track_user_delete
        mp_track "User: deleted",
          user_id: user.id
      end
    end
  end
end