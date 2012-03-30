require 'test_helper'

class WorkshopsControllerTest < ActionController::TestCase
  test "should get number_of_casuals" do
    get :number_of_casuals
    assert_response :success
  end

end
