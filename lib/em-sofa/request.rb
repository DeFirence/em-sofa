module EventMachine
  module Sofa
    module TVRage
      class Request
        include ::EventMachine::Deferrable

        Timeout  = 15

        def self.fibered(methd, *args)
          f = Fiber.current
          methd.call(*args) do |show|
            f.resume(:success, show)
          end.errback do |error|
            f.resume(:error, error)
          end
          status, result = Fiber.yield
          raise result if status == :error
          result
        end

        def initialize(host, path, callback_block, query, &block)
          callback {|info| callback_block.call(info) }
          @parse_element, @return_element = query.delete(:parse_element) || nil, query.delete(:return_element) || nil
          http = ::EventMachine::HttpRequest.new("http://#{host + path}").get :query => query, :timeout => Timeout
          http.callback {
            xml = Crack::XML.parse(http.response) rescue nil
            next fail Show::NotFound.new(xml ? http.response : nil) if not xml or xml == {}
            next succeed (@parse_element ? xml[@parse_element] : xml)[@return_element] if @return_element
            raise ArgumentError.new("No return_element or block given") unless block
            block.call(self, @parse_element ? xml[@parse_element] : xml)
          }
          http.errback { fail TVRage::HttpError.new(http.error == '' ? 'request timed out' : http.error) }
          self
        rescue RuntimeError => ex
          fail ex
        end
      end
    end
  end
end