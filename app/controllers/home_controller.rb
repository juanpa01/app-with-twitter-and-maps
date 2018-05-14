class HomeController < ApplicationController
  
  before_action :create_client

  def index

  client = SODA::Client.new({:domain => "www.datos.gov.co", :app_token => "F82AtyM4MKYkhVZTbTUYMKpPl"})

  @results_cundinamarca = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'CUNDINAMARCA'"})
  @results_antioquia = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'ANTIOQUIA'"})
  @results_valle_cauca = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'VALLE'"})
  @results_atlantico = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'ATLÁNTICO'"})
  @results_bolivar = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'BOLÍVAR'"})
  @results_norte_santander = client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'NORTE DE SANTANDER'"})
  @results_risaralda =client.get("xxxy-rt5e", {"$limit" =>1000, "$where" => "departamento = 'RISARALDA'"})

  @data_cundinamarca = 0.0
  @data_antioquia = 0.0
  @data_valle_cauca = 0.0
  @data_atlantico = 0.0
  @data_bolivar = 0.0
  @data_norte_santander = 0.0
  @data_risaralda = 0.0

  for i in (0...1000) do
    @data_cundinamarca += @results_cundinamarca[i][:cantidad].to_i
    @data_antioquia += @results_antioquia[i][:cantidad].to_i
    @data_valle_cauca += @results_valle_cauca[i][:cantidad].to_i
    @data_atlantico += @results_atlantico[i][:cantidad].to_i
    @data_bolivar += @results_bolivar[i][:cantidad].to_i
    @data_norte_santander += @results_norte_santander[i][:cantidad].to_i
    @data_risaralda += @results_risaralda[i][:cantidad].to_i
  end

  @radar = Gchart.pie(
    :size => '600x400',
    :title => 'Cantidad en gramos en los 7 principales departamentos de Colombia',
    :labels => ['CUNDINAMARCA ', 'ANTIOQUIA', 'VALLE', 'ATLÁNTICO', 'BOLÍVAR', 'NORTE DE SANTANDER', 'RISARALDA'],
    :custom => "chp=0.628",
    :data => [@data_cundinamarca, @data_antioquia, @data_valle_cauca, @data_atlantico, @data_bolivar, @data_norte_santander, @data_risaralda]
    )

  end

  def location_tweets
    batch_size = 10
    @twitter_handle = "juan_pablo_utp"

      @friends = @client.friends(@twitter_handle).take(batch_size)

    @names = []
    for i in (0...@friends.count)
      @name = @friends[i][:screen_name]
      @tweet = @client.user_timeline(@name).take(1) 
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
        marker.infowindow location.name
      end
    end
  end

  def location_friends
    batch_size = 10
    @twitter_handle = "juan_pablo_utp"

    @friends = @client.friends(@twitter_handle).take(batch_size)
    @name = ""
    for i in (0...@friends.count)
      @name = @name + @friends[i][:name] + "  "
      location = Location.new(
        name: @name,
        latitude: @friends[i][:status][:place][:bounding_box][:coordinates][0][0][1],
        length: @friends[i][:status][:place][:bounding_box][:coordinates][0][0][0]
        )
      location.save!
    end

    @locations = Location.all
    @hash = Gmaps4rails.build_markers(@locations) do |location, marker|
      if location.latitude != nil  && location.length != nil
        marker.lat location.latitude
        marker.lng location.length
        marker.infowindow location.name
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
