module Alchemy
  class PictureSerializer < ActiveModel::Serializer
    self.root = false

    attributes :id,
      :name,
      :image_file_name,
      :image_file_width,
      :image_file_height,
      :image_file_size,
      :tag_list,
      :created_at,
      :updated_at

  end
end
