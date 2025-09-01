using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using Backend.Data;

namespace Backend.Services
{
    public class PostServices
    {
        private readonly IMongoCollection<Post> _postsCollection;
        private readonly IMongoCollection<Feedback> _feedbacksCollection;

        public PostServices(PostsContext postsContext, FeedbacksContext feedbacksContext)
        {
            _postsCollection = postsContext.Posts;
            _feedbacksCollection = feedbacksContext.Feedbacks;
        }

        public async Task<List<Post>> GetAsync() =>
            await _postsCollection.Find(_ => true).ToListAsync();

        public async Task<Post?> GetByIdAsync(string id) =>
            await _postsCollection.Find(p => p.PostId == id).FirstOrDefaultAsync();
       
        public async Task<List<Post>> GetByUserIdAsync(string userId)
        {
            return await _postsCollection.Find(p => p.UserId == userId).ToListAsync();
        }
        
        public async Task<(List<Post> posts, long totalCount)> GetPostsAsync(int page, int pageSize)
        {
            var skip = (page - 1) * pageSize;

            var totalCount = await _postsCollection.CountDocumentsAsync(FilterDefinition<Post>.Empty);

            var posts = await _postsCollection
                .Find(FilterDefinition<Post>.Empty)
                .SortByDescending(p => p.Created)
                .Skip(skip)
                .Limit(pageSize)
                .ToListAsync();

            return (posts, totalCount);
        }
        
        public async Task CreateAsync(Post post) => 
            await _postsCollection.InsertOneAsync(post);
        
        
    
        public async Task DeleteAsync(string id, Post post)=>
            await _postsCollection.DeleteOneAsync(p => p.PostId == post.PostId);
        
        
        public async Task EditAsync(string id,Post post)=>
            await _postsCollection.ReplaceOneAsync(p => p.PostId == post.PostId, post);


        public async Task SaveInputAsync(Post post)
        {
            await _postsCollection.InsertOneAsync(post);
        }
        
        public async Task UpdateAsync(string postId)
        {
            var likeCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && f.Like == true));
            var dislikeCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && f.Like == false));
            var commentCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && !string.IsNullOrEmpty(f.Comment)));

            var update = Builders<Post>.Update.Set(p => p.Feedback, new FeedbackSummary
            {
                likeCount = likeCount,
                dislikeCount = dislikeCount,
                commentCount = commentCount
            });

            await _postsCollection.UpdateOneAsync(p => p.PostId == postId, update);
        }
    
    }
}