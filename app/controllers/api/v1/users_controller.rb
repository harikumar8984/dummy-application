class Api::V1::UsersController < ApplicationController
  respond_to :json

  def index
    render :json => { 'test' => 'kkk'}
  end
end