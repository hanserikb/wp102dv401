class SearchesController < ApplicationController
  before_filter :authenticate_user!
  autocomplete :map, :name, full: :true
  def autocomplete

    # bygger ihop en array med taggarna man sökt på, splittat på kommatecken
    @terms = params[:term].gsub(" ","").split(",")

    # Hämtar kartorna som matchar taggarna och tar bort dubletter
    @maps_from_tag_search = Tag.find_all_by_word(@terms, :include => [:maps]).collect(&:maps).flatten.uniq

    # Sorterar kartorna efter hur många taggar som träffar
    @sorted_maps_from_tag_search =  @maps_from_tag_search.sort_by{|map| -map.tag_match_count(@terms)}

    #Bygger ihop en hash som sedan renderas ut till json
    @hash = []
    @sorted_maps_from_tag_search.each do |map|
      @hash << {
        name: map.name, 
        tag_list: map.tag_list, 
        href: profile_map_url(map.user.slug, map.slug)
      }
    end

    render json: @hash
  end

  def search
    @result_maps = Map.search_for(params[:term])
    @result_users = User.search_for(params[:term])
    @result_count = @result_maps.size + @result_users.size
  end

  def result
    @result_maps = Tag.find_by_word(params[:query]).maps
    @result_count = @result_maps.size

  end
end
