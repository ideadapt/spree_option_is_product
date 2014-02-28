class ProductKit
  base_price: 0
  constructor: () ->
    @set_base_price parseFloat($('#base_price').val(), 10)
    @update_cart_options()
    @update_cart_total() if $("#specs-list").is "*"
    #listens for changes and updates order total
    $('.option_type_select').change (event) =>
      @update_related_fields(event.target)
      @update_cart_total()
    $('.product_option_quantities').change (event) =>
      @update_cart_total()

  #Set the base price
  set_base_price: (price)->
    @base_price = price

  #Always gets the initial base price for a kit
  get_base_price: () ->
    return @base_price

  #Update the option fields on sidebar
  update_cart_options: ->
    selects = $('select.option_type_select');
    @update_related_fields(el) for el in selects

  update_related_fields: (el) ->
    el = $(el)
    [oid, selected_option] = [el.attr('id'), el.find(":selected")]
    [price, qty] = [parseFloat(selected_option.data('price'), 10), parseFloat(selected_option.data('qty'), 10)]
    [price_display_element, qty_field] = [$("##{oid}_price_display"), $("##{oid}_quantity")]

    if isNaN(price)
      price = 0
      price_display_element.text '--'
    else
      price_display_element.text "$#{price}"

    $("##{oid}_price").val(price)

    if isNaN(qty)
      qty_field.attr('readonly', 'readonly').val(0)
    else
      qty_field.attr 'min', qty
      qty_field.removeAttr('readonly').val(qty)

    $("##{oid}").val(el.val())

  #Update Order total
  update_cart_total: () ->
    current_total = @get_base_price()
    $('.product_option_prices').each (index, element) =>
      item_multiply = parseInt($(element).siblings('.product_option_quantities').val(), 10)
      current_total += (parseFloat($(element).val(), 10) * item_multiply)
    $('#product-price span.price').text "$" + ( current_total.toFixed(2) )

jQuery ->
  $(document).ready ->
    new ProductKit()
    $('.option_type_select').select2(minimumResultsForSearch: -1, width: '65%')

Spree.ready ($) ->
  reset_children_quantity = ->
    parent_rows = $('tbody#line_items tr.master-item')
    parent_rows.each (i, parent_row) ->
      parent_row = $(parent_row)
      value = parent_row.find('input.line_item_quantity').val()
      if value == '0'
        slave_rows = parent_row.nextUntil('tr.master-item', 'tr.slave-item').get()
        $(slave_rows).each (i, row) ->
          $(row).find('input.line_item_quantity').val 0

  if ($ 'form#update-cart').is('*')
    $('form#update-cart a.delete').off 'click' # turn off default handler
    ($ 'form#update-cart a.delete').show().one 'click', ->
      tr = ($ this).parents('.line-item').first()
      tr.find('input.line_item_quantity').val 0
      ($ this).parents('form').first().submit()
      false

    ($ 'form#update-cart').on 'submit', ->
      reset_children_quantity()
