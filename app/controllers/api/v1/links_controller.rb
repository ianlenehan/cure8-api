module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      url = params[:link][:url]
      link = Link.create(link_params)
      get_link_data(link)
      create_curations(params[:link][:numbers], link.id)
    end


    private
    def create_curations(numbers, link_id)
      numbers.each do |number|
        user = User.find_or_create_by(phone: number)
        Curation.create(user_id: user.id, link_id: link_id)
      end
    end

    def link_params
      params.require(:link).permit(:url, :url_type, :link_owner, :comment)
    end

    def get_link_data(link)
      page = MetaInspector.new(link.url)
      title = page.title
      image = page.images.best
      link.update(title: title, image: image)
    end
  end
end
