require 'bitbucket_pr_commnet/version'
require 'bitbucket_pr_commnet/error'
require 'bitbucket_pr_commnet/bitbucket'

module BitbucketPrCommnet
  def self.exec(client_id:, client_secret:, content:, repo_username:, repo_slug:, branch:)
    bitbucket = Bitbucket.new(client_id, client_secret, repo_username, repo_slug)
    pullreq_list = bitbucket.get_pullreq_list

    pullreq = pullreq_list.find{|data| data[:source][:branch][:name] == branch}
    raise NotFoundError, 'pull request not found' unless pullreq

    user = bitbucket.get_user
    comment_list = bitbucket.get_pullreq_comment_list(pullreq[:id])
    comment = comment_list.find {|data| data[:user][:username] == user[:username]}

    bitbucket.send_pullreq_comment(pullreq[:id], content, comment)
  end
end
