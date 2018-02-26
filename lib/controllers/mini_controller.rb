module Controllers
  module MiniController
    class << self
      def included(controller)

        controller.namespace('/api') {|c|
          c.get('') {
            make_default_json_api(self) {
              {msg: 'Welcome To Dynamic Ruby Class Creator Apis'}
            }
          }

          c.namespace('/tables') {|c|
            c.get('') {
              make_default_json_api(self) {
                {database: App::DATABASE.opts[:database], schema: App::ClassMap.first[:schema], tables: App::ClassMap}
              }
            }

            c.get('/:table_name') {|table_name|
              make_default_json_api(self, {}, table_name) {|mapped_class, klass|

                {"#{mapped_class[:table_name]}": klass.all.map(&:values)}
              }
            }

            c.get('/:table_name/:id') {|table_name, id|
              make_default_json_api(self, {}, table_name) {|mapped_class, klass|

                {"#{mapped_class[:table_name]}": klass.find_by_id(id)&.values}
              }
            }


            c.delete('/:table_name/:id') {|table_name, id|
              make_default_json_api(self, {}, table_name) {|_mapped_class, klass|

                klass[id].destroy

                {msg: "#{klass.name} with id: #{id} was success removed."}
              }
            }

            c.post('/:table_name') {|table_name|
              make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, klass|

                {status: 201, response: klass.create(params)&.values}
              }
            }

            c.put('/:table_name/:id') {|table_name, id|
              make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, klass|

                object = klass[id]
                raise ModelException.new "#{table_name} not found with id: #{id}" unless object

                {status: _status_code, response: object.update(params)&.values}
              }
            }
          }

          controller.namespace('/columns') {|c|
            c.get('/:table_name') {|table_name|
              make_default_json_api(self, {}, table_name) {|mapped_class, _klass|

                {"#{mapped_class[:table_name]}": mapped_class[:columns_n_types]}
              }
            }
          }
        }
      end
    end
  end
end