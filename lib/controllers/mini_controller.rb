module Controllers
  module MiniController
    class << self
      def included(controller)

        controller.namespace('/api') {|c|
          c.get('') {
            make_default_json_api(instance: self) {
              {msg: 'Welcome To Dynamic Ruby Class Creator Apis'}
            }
          }

          # <host>/api/tables
          # Show tables
          c.namespace('/tables') {|c|
            c.get('') {
              make_default_json_api(instance: self) {
                {database: App::DATASOURCE.opts[:database], schema: App::ClassMap.first[:schema], tables: App::ClassMap}
              }
            }

            # <host>/api/tables/<table_name>
            # Return rows for table
            c.get('/:table_name') {|table_name|
              make_default_json_api(instance: self, payload: nil, table_name: table_name) {|mapped_class, klass|

                {"#{mapped_class[:table_name]}": klass.all.map(&:values)}
              }
            }

            # <host>/api/tables/<table_name>/<id>
            # Return a row in current table
            c.get('/:table_name/:id') {|table_name, id|
              make_default_json_api(instance: self, payload: nil, table_name: table_name) {|mapped_class, klass|

                {"#{mapped_class[:table_name]}": klass.find_by_id(id)&.values}
              }
            }


            # <host>/api/tables/<table_name>/<id>
            # Delete a row in current table
            c.delete('/:table_name/:id') {|table_name, id|
              make_default_json_api(instance: self, payload: nil, table_name: table_name) {|_mapped_class, klass|

                klass[id].destroy

                {msg: "#{klass.name} with id: #{id} was success removed."}
              }
            }

            # <host>/api/tables/<table_name>
            # Persist values in current table
            c.post('/:table_name') {|table_name|
              make_default_json_api(instance: self, payload: request.body.read, table_name: table_name) {|params, _status_code, _mapped_class, klass|

                {status: _status_code, response: klass.create(params)&.values}
              }
            }

            # <host>/api/tables/<table_name>/<id>
            # Update values in current table
            c.put('/:table_name/:id') {|table_name, id|
              make_default_json_api(instance: self, payload: request.body.read, table_name: table_name) {|params, _status_code, _mapped_class, klass|

                object = klass[id]
                raise ModelException.new "#{table_name} not found with id: #{id}" unless object

                {status: _status_code, response: object.update(params)&.values}
              }
            }
          }


          controller.namespace('/columns') {|c|
            # <host>/api/columns/<table_name>
            # Show possible columns in a current table
            c.get('/:table_name') {|table_name|
              make_default_json_api(instance: self, payload: nil, table_name: table_name) {|mapped_class, _klass|

                {"#{mapped_class[:table_name]}": mapped_class[:columns_n_types]}
              }
            }
          }
        }
      end
    end
  end
end