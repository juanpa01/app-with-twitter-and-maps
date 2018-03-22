class HomeController < ApplicationController
  
  before_action :create_client

  def index
  	batch_size = 10
    @twitter_handle = "juan_pablo_utp"

    #@friends = @client.friends("juan_pablo_utp").take(batch_size)

    #@tweets = @client.user_timeline(@twitter_handle).take(batch_size)    
   	@friends = @client.friends(@twitter_handle).take(batch_size)
    #@followers = @client.followers(@twitter_handle).take(batch_size)

    @names = []
    for i in (0...@friends.count)
      @name = @friends[i][:screen_name]
      @names.push(@name)
    end
    @tweets = []
    for i in (0...@names.count)
      @tweet = @client.user_timeline(@names[i]).take(1) 
      @tweets.concat(@tweet)
      location = Location.new(
        name: @tweet[0][:user][:name],
        latitude: @tweet[0][:geo][:coordinates][0],
        length: @tweet[0][:geo][:coordinates][1]
        )
      location.save!
    end
    @locations = Location.all
    @hash = Gmaps4rails.build_markers(@locations) do |location, marker|
      if location.latitude != nil  && location.length != nil
        marker.lat location.latitude
        marker.lng location.length
      end
    end
  end

  private
  def create_client
      Location.destroy_all
      @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_api_key
      config.consumer_secret     = Rails.application.secrets.twitter_api_secret
      config.access_token        = current_user.token
      config.access_token_secret = current_user.secret
    end
  end
end
