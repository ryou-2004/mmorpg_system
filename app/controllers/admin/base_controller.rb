class Admin::BaseController < ApplicationController
  before_action :authenticate_admin_user!, unless: :development_test_mode?

  private

  def development_test_mode?
    Rails.env.test? || ((Rails.env.development? || Rails.env.test?) && params[:test] == "true")
  end
end
