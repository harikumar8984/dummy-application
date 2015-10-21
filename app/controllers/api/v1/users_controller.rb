class Api::V1::UsersController < ApplicationController
  respond_to :json

  def welcome_content_structure
    #Under the assumption for welcome content the course id will be one
    course_content_structure(1)
  end

end