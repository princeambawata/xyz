class HomeController < ApplicationController
  def index
  	@post = Post.new
  	@posts = Post.all.order(created_at: :desc)
  end


  def create_post_remote
      @post = current_user.posts.create(post_params)
  		respond_to do |format|
      format.js{
          
      }
    end
  end

  def post_params
    params.require(:post).permit(:content , :image)
  end


  def like_remote
    @post_id = params[:post_id]
    like = current_user.likes.where(post_id: @post_id).first
    if like
      like.destroy
    else
      current_user.likes.create(post_id: @post_id)
    end
    respond_to do |format|
      format.js
    end 
  end

  def comment_remote
    @post = Post.find(params[:post_id])
    @comments = @post.comments.all.order(created_at: :desc)
    respond_to do |format|               
    format.js
    end  
  end

  def create_comment_remote

    puts params[:text_field]
    @comment = current_user.comments.create(post_id: params[:post_id] , content: params[:content])
    @post_id = params[:post_id]
     respond_to do |format|               
    format.js
    end  

  end

  def follow_remote
   @followee_id = params[:followee_id]
   follow = FollowMapping.where(follower_id: current_user.id , followee_id: @followee_id)
   if follow
     follow.destroy
   else
     FollowMapping.create(follower_id: current_user.id , followee_id: @followee_id)
   end
    respond_to do |format|
      format.js
    end 
  end
  
  def create_friend_remote
    @friendship = current_user.friendships.build(friend_id: params[:friend_id])
    if @friendship.save
        FollowMapping.create(follower_id: current_user.id , followee_id: params[:friend_id])
        flash[:notice] = "Friend requested."
    else
        flash[:error] = "Unable to request friendship."
    end
    respond_to do |format|
      format.js
    end 
  end


  def update_friend_remote
    @friendship = Friendship.find_by(id: params[:id])
    @friendship.update(status: "accepted")
      if @friendship.save
        flash[:notice] = "Successfully confirmed friend!"
      else
        flash[:notice] = "Sorry! Could not confirm friend!"
      end
      respond_to do |format|
      format.js
      end       
  end

  def destroy_friend_remote
    @friendship = Friendship.find_by(id: params[:id])
    @friendship.destroy
    flash[:notice] = "Removed friendship."
    respond_to do |format|
    format.js
    end     
  end 

end
