## Dispatches pagination
def pagination_href(page, index_number, num_of_indices)
  if page.class != Fixnum || page == 1
    special_page_handler(page, index_number, num_of_indices)
  elsif page <= num_of_indices
    page_less_than_indices_total(page, index_number)
  elsif page > num_of_indices
    page_greater_than_indices_total(index_number, num_of_indices)
  end
end

## Handles "pagination", "next", and page-button-link 1
def special_page_handler(page, index_number, num_of_indices)
  if page == 1
    page_one_link(index_number)
  elsif page == 'previous'
    handle_previous_pagination(index_number, num_of_indices)
  elsif page == 'next'
    handle_next_pagination(index_number, num_of_indices)
  end
end

## Handles page-button-link 1 depending on type of index
def page_one_link(index_number)
  index_number == 1 ? 'index.html' : '../index.html'
end

## Handles "next" button-link depending on type of index
def handle_next_pagination(index_number, num_of_indices)
  if index_number == num_of_indices
    "../page#{num_of_indices}/index.html"
  else
    pagination_href((index_number + 1), index_number, num_of_indices)
  end
end

## Handles "previous" button-link depending on type of index
def handle_previous_pagination(index_number, num_of_indices)
  if index_number == 1
    'index.html'
  else
    pagination_href((index_number - 1), index_number, num_of_indices)
  end
end

## Handles a page button-link greater than total number of indices
def page_greater_than_indices_total(index_number, num_of_indices)
  if index_number == 1
    "page#{num_of_indices}/index.html"
  else
    "../page#{num_of_indices}/index.html"
  end
end

## Handles page button-links less than total number of indices
def page_less_than_indices_total(page, index_number)
  index_number == 1 ? "page#{page}/index.html" : "../page#{page}/index.html"
end

## Makes pagination list item active if it matches the current
## page number.
def pagination_list_item_class(index_number, page)
  index_number == page ? 'page-item active' : 'page-item'
end

## Supplies sr span if it is current page
def sr_span(index_number, page)
  index_number == page ? '<span class="sr-only">(current)</span>' : ''
end
