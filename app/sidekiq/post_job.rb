class PostJob
  include Sidekiq::Job

  def perform(id)
    post = Post.find(id)
    puts "*" * 20
    puts "perform #{Time.current}"
    puts "get the #{post.inspect}"
    puts "*" * 20
  end
end
