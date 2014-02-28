Spree::Order.class_eval do

  has_many :line_items, -> { order('COALESCE(spree_line_items.parent_id, spree_line_items.id), spree_line_items.parent_id IS NOT NULL, spree_line_items.id') }, dependent: :destroy

  def find_line_item_by_variant(variant)
    line_items.detect { |line_item| (line_item.variant_id == variant.id) && line_item.parent.blank? && line_item.children.blank? }
  end

  def group_order?
    user.present? && user.user_group.present?
  end
end
