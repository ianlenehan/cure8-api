module Mutations
  class ArchiveCuration < Mutations::BaseMutation

    description "Archives a curation"
    argument :id, String, required: true
    argument :tags, [String], required: false
    argument :rating, String, required: false

    field :curations, [Types::CurationType], null: false
    field :errors, [String], null: true

    def resolve(id:, tags:, rating:)
      if (archive_curation(id, rating, tags))
        { curations: current_user.curations, errors: [] }
      else
        { errors: ["There was a problem archiving the curation"] }
      end
    end

    private

    def archive_curation(id, rating, tags)
      curation = Curation.find(id)
      curation.update(status: 'archived', rating: rating)

      tags.each do |tag|
        tag_record = Tag.find_or_create_by(name: tag)
        curation.tags << tag_record unless curation.tags.include?(tag_record)
      end
    end

    def current_user
      context[:current_user]
    end
    
  end
end