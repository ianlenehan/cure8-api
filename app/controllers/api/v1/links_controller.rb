module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      url = params[:link][:url]
      user_phone = params[:user][:phone]

      owner = User.find_by(phone: user_phone)
      link = Link.create(
        url: params[:link][:url],
        url_type: params[:link][:url_type],
        comment: params[:link][:comment],
        link_owner: owner.id
      )

      get_link_data(link)
      create_curations(params[:link][:numbers], link.id)
      render json: { links: owner.links, status: 200 }
    end

    def get_links
      user = User.find(params[:user_id])
      if user.links.any?
        render json: { links: user.links, status: 200 }
      else
        render json: { status: 204 }
      end
    end

    def archive
      curation = Curation.find(params[:curation][:id])
      user = User.find(curation.user_id)
      if curation.update(status: 'archived')
        render json: { links: user.links, status: 200 }
      end
    end

    private
    def create_curations(numbers, link_id)
      numbers.each do |number|
        user = User.find_or_create_by(phone: number)
        Curation.create(user_id: user.id, link_id: link_id)
      end
    end

    def get_link_data(link)
      page = MetaInspector.new(link.url)
      title = page.title
      image = page.images.best
      link.update(title: title, image: image)
    end
  end
end
