require 'integration_helper'

describe "Compare screens", type: :request do

  it "should render the frontpage as expected", :screenshot  do
    visit "/?show_sign_in=true"
    assume_unchanged_screenshot "homepage"
  end

end
