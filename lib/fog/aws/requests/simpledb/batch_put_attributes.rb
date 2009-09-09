unless Fog.mocking?

  module Fog
    module AWS
      class SimpleDB

        # Put items attributes into a SimpleDB domain
        #
        # ==== Parameters
        # * domain_name<~String> - Name of domain. Must be between 3 and 255 of the
        #   following characters: a-z, A-Z, 0-9, '_', '-' and '.'.
        # * items<~Hash> - Keys are the items names and may use any UTF-8
        #   characters valid in xml.  Control characters and sequences not allowed
        #   in xml are not valid.  Can be up to 1024 bytes long.  Values are the
        #   attributes to add to the given item and may use any UTF-8 characters
        #   valid in xml. Control characters and sequences not allowed in xml are
        #   not valid.  Each name and value can be up to 1024 bytes long.
        #
        # ==== Returns
        # * response<~Fog::AWS::Response>:
        #   * body<~Hash>:
        #     * 'BoxUsage'
        #     * 'RequestId'
        def batch_put_attributes(domain_name, items, replace_attributes = Hash.new([]))
          request({
            'Action' => 'BatchPutAttributes',
            'DomainName' => domain_name
          }.merge!(encode_batch_attributes(items, replace_attributes)), Fog::Parsers::AWS::SimpleDB::Basic.new(@nil_string))
        end

      end
    end
  end

else

  module Fog
    module AWS
      class SimpleDB

        def batch_put_attributes(domain_name, items, replace_attributes = Hash.new([]))
          response = Fog::Response.new
          if Fog::AWS::SimpleDB.data[:domains][domain_name]
            for item_name, attributes in items do
              for key, value in attributes do
                Fog::AWS::SimpleDB.data[:domains][domain_name][item_name] ||= {}
                if replace_attributes[item_name] && replace_attributes[item_name].include?(key)
                  Fog::AWS::SimpleDB.data[:domains][domain_name][item_name][key.to_s] = []
                else
                  Fog::AWS::SimpleDB.data[:domains][domain_name][item_name][key.to_s] ||= []
                end
                Fog::AWS::SimpleDB.data[:domains][domain_name][item_name][key.to_s] << value.to_s
              end
            end
            response.status = 200
            response.body = {
              'BoxUsage'  => Fog::AWS::Mock.box_usage,
              'RequestId' => Fog::AWS::Mock.request_id
            }
          else
            response.status = 400
            raise(Fog::Errors.status_error(200, 400, response))
          end
          response
        end

      end
    end
  end

end
