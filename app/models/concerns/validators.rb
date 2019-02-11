module Validators
  class URIValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if options[:https]
        uri = URI(value)
        unless uri.scheme == 'https'
          unless options[:https][:allow_on_localhost] && uri.hostname == 'localhost'
            record.errors[attribute] << (options[:message] || 'uri must use https scheme')
          end
        end
      end
      if options[:deny_localhost]
        unless URI(value).hostname != 'localhost'
          record.errors[attribute] << (options[:message] || 'use of localhost as hostname is denied')
        end
      end
    end
  end
end
