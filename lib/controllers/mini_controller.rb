module Controller
  module MiniController
    class << self
      def extended(controller)
        controller.include Helpers::ApiHelper::ApiBuilder

        controller.get('/') {
          file_path = File.join(settings.public_folder, 'index.html')
          if File.exist?(file_path) && File.readable?(file_path)
            send_file file_path
          else
            'File not Found!'
          end
        }

        controller.namespace('/api') { |c|
          c.get('') {
            make_default_json_api(self) {
              {msg: 'Welcome To Dynamic Ruby Class Creator Apis'}
            }
          }

          c.get('/tables') {
            make_default_json_api(self) {
              {database: DB.opts[:database], schema: App::ClassMap.first[:schema], tables: App::ClassMap}
            }
          }

          c.get('/table/:table_name') {|table_name|
            make_default_json_api(self, {}, table_name) {|mapped_class, the_class|

              {"#{mapped_class[:table_name]}": the_class.all.map(&:values)}
            }
          }

          c.get('/columns/:table_name') {|table_name|
            make_default_json_api(self, {}, table_name) {|mapped_class, _the_class|

              {"#{mapped_class[:table_name]}": mapped_class[:columns_n_types]}
            }
          }

          c.get('/table/:table_name/:id') {|table_name, id|
            make_default_json_api(self, {}, table_name) {|mapped_class, the_class|

              {"#{mapped_class[:table_name]}": the_class.obter_por_id(id)&.values}
            }
          }

          c.post('/table/:table_name') {|table_name|
            make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, the_class|

              {status: 201, response: the_class.create(params)&.values}
            }
          }

          c.put('/table/:table_name/:id') {|table_name, id|
            make_default_json_api(self, request.body.read&.delete("\n"), table_name) {|params, _status_code, _mapped_class, the_class|

              object = the_class[id]
              raise ModelException.new "Object not found with id: #{id}" unless object

              {status: _status_code, response: object.update(params)&.values}
            }
          }
        }
      end
    end
  end
end