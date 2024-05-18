require "test_helper"

class ShowingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get showings_index_url
    assert_response :success
  end
end
