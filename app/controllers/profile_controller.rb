class ProfileController < ApplicationController
	def index

	end

	def show
		@user = User.find(params[:id])
	end
end