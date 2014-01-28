Deface::Override.new(
  :virtual_path => "spree/orders/_line_item",
  :name         => "remove_remove_button",
  :surround     => "erb[loud]:contains('icons/delete.png')",
  :text         => "<% unless line_item.parent_id %> <%= render_original %> <% end %>")
