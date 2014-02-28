Spree::OrdersController.class_eval do
  append_after_filter :add_children, :only => :populate
  append_after_filter :update_children, :only => :update

  private

  def add_children
    unless params["product_options"].blank?
      unless params["variants"].blank?
        parent = current_order.find_line_item_by_variant(Spree::Variant.find(params["variants"].first[0]))
        return if parent.nil?
        params["product_options"].each do |k,v|
          next unless v && v.key?("selected") && v["selected"].present?
          ov = Spree::OptionValue.find(v["selected"])
          if !!spree_current_user && !!spree_current_user.user_group && !! spree_current_user.user_group.name.match(/^Distributor.*/)
            price = ov.distributor_price
          else
            price = ov.special_price
          end
          # Spree increments the quantity of existing line items when
          # populating the order if adding the same product.
          # Here we force the creation of new LineItems so we don't
          # merge product's options with existing items in the order
          # by passing the parent_id indicating that it's an option.
          #
          # Create children items only with the amount needed in the kit
          # then, if they want more than what's needed, put those into a new line item
          # and unlink from parent (parent = nil)
          quantity_needed = parent.quantity_needed_for_part ov.variant_id
          current_order.contents.add(ov.variant, quantity_needed, current_currency, nil, (price || ov.variant.price), parent.id)
          if v["quantity"].to_i > quantity_needed
            left = v["quantity"].to_i - quantity_needed
            # For extra parts use the regular variant price
            current_order.contents.add(ov.variant, left, current_currency, nil, ov.variant.price, nil) if ov.variant.available?
          end
        end
      end
    end
  end

  def update_children
    unless current_order.blank? || current_order.line_items.blank?
      current_order.line_items.where("parent_id is not null").each do |l|
        quantity = nil
        l.parent.variant.product.product_options.each { |i| i.option_values.each { |o| quantity = o.quantity if o.variant_id == l.variant_id } }
        l.quantity = l.parent.quantity * (quantity || 1)
        l.save
      end
    end
  end
end
