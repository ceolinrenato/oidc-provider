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

  class FrontChannelURIValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      frontchannel_logout_uri = URI(value)
      redirect_uris = record.redirect_uris.map { |redirect_uri| URI(redirect_uri.uri) }
      valid = redirect_uris.any? do |redirect_uri|
        redirect_uri.hostname == frontchannel_logout_uri.hostname && redirect_uri.port == frontchannel_logout_uri.port && redirect_uri.scheme == frontchannel_logout_uri.scheme
      end
      record.errors[attribute] << (options[:message] || 'the domain, port and scheme of this URI must be the same as that of a registered Redirection URI.') unless valid
    end
  end
end
