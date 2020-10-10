module Paginations
  class Paginate
    PERPAGE = 5
    attr_reader :page
                :objects

    def initialize(page, objects ={})
      @page = page
      @objects = objects
    end

    def succeed?
      !out_of_range?
    end

    def paginate
      @objects.page(@page.to_i).per(PERPAGE)
    end

    def out_of_range?
      @objects.page(@page.to_i).per(PERPAGE).out_of_range?
    end

    def response
      {
        response: paginate,
        current_page:  paginate.current_page,
        next_page:  paginate.next_page,
        prev_page:  paginate.prev_page,
        total_pages:  paginate.total_pages,
        total_count:  paginate.total_count
      }
    end
  end
end
