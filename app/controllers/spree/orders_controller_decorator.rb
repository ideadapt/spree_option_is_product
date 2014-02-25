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
          current_order.contents.add(ov.variant,(v["quantity"].to_i * parent.quantity),current_currency, nil, (price || ov.variant.price), parent.id)
        end
      end
    end
  end

  def update_children
    unless current_order.blank? || current_order.line_items.blank?
      current_order.line_items.where("parent_id is not null").each do |l|
        parent_product = l.parent.product
        min_qty = parent_product.min_quantity_for_part(l.variant_id) * l.parent.quantity
        if l.quantity < min_qty
          flash[:error] = Spree.t(:quantities_were_readjusted)
          l.quantity = min_qty
          l.save
        end
      end
    end
  end
end
