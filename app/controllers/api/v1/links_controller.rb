module Api::V1
  class LinksController < ApplicationController

    # POST /v1/links/create
    def create_link
      user = User.find(params[:user][:id])
      link = find_or_create_link(user, params[:link])
      save_to_my_links = params[:link][:save_to_my_links]

      create_curations([params[:link][:contact]], link.id)
      if save_to_my_links
        Curation.create(user_id: user.id, link_id: link.id)
      end

      render json: { links: user.links, status: 200 }
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
      if curation.update(status: 'archived', rating: params[:curation][:rating])
        render json: { links: user.links, status: 200 }
      end
    end

    private
    def create_curations(group_ids, link_id)
      group_ids.each do |group_id|
        Group.find(group_id).members.each do |member|
          contact = Group.find(member)
          Curation.create(user_id: contact.members.first, link_id: link_id)
        end
      end
    end

    def find_or_create_link(owner, link_params)
      link = Link.find_by(link_owner: owner.id, url: link_params[:url])
      return link if link

      newLink = Link.create(
        url: params[:link][:url],
        comment: params[:link][:comment],
        link_owner: owner.id
      )
      get_link_data(newLink)
    end

    def get_link_data(link)
      page = MetaInspector.new(link.url)
      title = page.title
      image = page.images.best
      link.update(title: title, image: image)
      link
    end
  end
end
