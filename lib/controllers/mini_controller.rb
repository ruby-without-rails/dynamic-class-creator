module Controller
  module MiniController
    class << self
      def included(controller)

        controller.namespace('/api') { |c|
          c.get('') {
            make_default_json_api(self) {
              {msg: 'Welcome To Dynamic Ruby Class Creator Apis'}
            }
          }

          c.get('/tables') {
            make_default_json_api(self) {
              {database: DATABASE.opts[:database], schema: App::ClassMap.first[:schema], tables: App::ClassMap}
            }
          }

          c.get('/table/:table_name') {|table_name|
            make_default_json_api(self, {}, table_name) {|mapped_class, klass|

              {"#{mapped_class[:table_name]}": klass.all.map(&:values)}
            }
          }

          c.get('/columns/:table_name') {|table_name|
            make_default_json_api(self, {}, table_name) {|mapped_class, _klass|

              {"#{mapped_class[:table_name]}": mapped_class[:columns_n_types]}
            }
          }

          c.get('/table/:table_name/:id') {|table_name, id|
            make_default_json_api(self, {}, table_name) {|mapped_class, klass|

              {"#{mapped_class[:table_name]}": klass.find_by_id(id)&.values}
            }
          }

          c.delete('/table/:table_name/:id') {|table_name, id|
            make_default_json_api(self, {}, table_name) {|_mapped_class, klass|

              klass[id].destroy

              {msg: "object with id: #{id} was success removed"}
            }
          }

          c.post('/table/:table_name') {|table_name|
            make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, klass|

              {status: 201, response: klass.create(params)&.values}
            }
          }

          c.put('/table/:table_name/:id') {|table_name, id|
            make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, klass|

              object = klass[id]
              raise ModelException.new "Object not found with id: #{id}" unless object

              {status: _status_code, response: object.update(params)&.values}
            }
          }
        }
      end
    end
  end
end