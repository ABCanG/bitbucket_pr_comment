require 'net/https'
require 'json'
require 'base64'
require 'cgi'

module BitbucketPrCommnet
  class Bitbucket
    def initialize(key, secret, repo_username, repo_slug)
      bearer_token = "#{key}:#{secret}"
      encoded_bearer_token = Base64.strict_encode64(bearer_token)
      @auth = "Basic #{encoded_bearer_token}"
      @repo_username = repo_username
      @repo_slug = repo_slug
      authorize
    end

    def get_user
      request_bitbucket('get', '/user', '2.0')
    end

    def get_pullreq_list
      list = []
      page = 1
      loop do
        json = request_bitbucket('get', pullreq_path, '2.0', state: 'OPEN', pagelen: 50, page: page)
        list.concat(json[:values])
        page += 1
        break if json[:next].nil?
      end
      list
    end

    def get_pullreq_comment_list(pullreq_id)
      list = []
      page = 1
      loop do
        json = request_bitbucket('get', pullreq_path + "/#{pullreq_id}/comments", '2.0', pagelen: 50, page: page)
        list.concat(json[:values])
        page += 1
        break if json[:next].nil?
      end
      list
    end

    def send_pullreq_comment(pullreq_id, content, comment = nil)
      method = comment ? 'put' : 'post'
      path = pullreq_path + "/#{pullreq_id}/comments"
      path += "/#{comment[:id]}" if comment
      request_bitbucket(method, path, '1.0', content: content)
    end

    private

    def base_uri(version)
      "https://api.bitbucket.org/#{version}"
    end

    def pullreq_path
      "/repositories/#{@repo_username}/#{@repo_slug}/pullrequests"
    end

    def http_request(method, uri, query_hash = {})
      uri = URI.parse(uri) if uri.is_a? String
      method = method.to_s.strip.downcase
      query_string = (query_hash || {}).map{|k, v|
        CGI.escape(k.to_s) + '=' + CGI.escape(v.to_s)
      }.join('&')
      header = { 'Authorization' => @auth }

      args =
        if method == 'post'
          [Net::HTTP::Post.new(uri.path, header), query_string]
        elsif method == 'put'
          [Net::HTTP::Put.new(uri.path, header), query_string]
        else
          [Net::HTTP::Get.new(uri.path + (query_string.empty? ? '' : "?#{query_string}"), header)]
        end

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      https.start do |http|
        http.request(*args)
      end
    end

    def request_json(method, path, params = {})
      res = http_request(method, path, params)
      case res
      when Net::HTTPSuccess
        JSON.parse(res.body, symbolize_names: true)
      else
        res.value
      end
    end

    def request_bitbucket(method, path, version, params = {})
      request_json(method, base_uri(version) + path, params)
    end

    def authorize
      path = 'https://bitbucket.org/site/oauth2/access_token'
      json = request_json('post', path, grant_type: 'client_credentials')
      @auth = "Bearer #{json[:access_token]}"

    rescue Net::HTTPExceptions
      raise AuthorizedError, 'authorization failed'
    end
  end
end
