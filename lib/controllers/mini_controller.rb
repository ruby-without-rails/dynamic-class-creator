module Controller
  module MiniController
    class << self
      def extended(controller)
        controller.include Helpers::ApiHelper::ApiBuilder

        controller.get('/') {
          make_default_json_api(self) {
            {msg: 'Welcome To Dynamic Ruby Class Creator'}}
        }

        controller.options('/tables') {
          make_default_json_api(self) {
            {tables: App::ClassMap}}
        }

        controller.get('/table/:table_name') {|table_name|
          make_default_json_api(self) {
            mapped_class = App::ClassMap.detect {|map| map[:table_name] == table_name}
            raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

            the_class = class_from_string(mapped_class[:class_name])
            raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class

            object = the_class.all.map(&:values)
            {"#{mapped_class[:table_name]}": object}
          }
        }

        controller.get('/table/:table_name/:id') {|table_name, id|
          make_default_json_api(self) {
            mapped_class = App::ClassMap.detect {|map| map[:table_name] == table_name}
            raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

            the_class = class_from_string(mapped_class[:class_name])
            raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class

            object = the_class.obter_por_id(id)&.values
            {"#{mapped_class[:table_name]}": object}.to_json
          }
        }

        controller.post('/table/:table_name') {|table_name|
          mapped_class = App::ClassMap.detect {|map| map[:table_name] == table_name}
          raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

          the_class = class_from_string(mapped_class[:class_name])
          raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class


        }

      end
    end
  end
end