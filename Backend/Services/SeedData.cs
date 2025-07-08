using Backend.Models;
using Backend.Services.userPostService;
using MongoDB.Bson;

namespace Backend.Services;

public static class SeedData
{
    public static async Task InitializeAsync(IServiceProvider serviceProvider)
    {
        var postService = serviceProvider.GetRequiredService<PostServices>();
        var createService = serviceProvider.GetRequiredService<CreatePost>();

        var existingPosts = await postService.GetAsync();
        if (existingPosts.Any())
            return;

        var posts = new List<Post>
        {
            new Post
            {
                UserId ="686b8bc91d177681dc98f1b7",
                Title = "Post1",
                Location = "Kathmandu",
                Content = "This is a test post.",
                Created = DateTime.UtcNow
            },
            new Post
            {
                UserId = "686b8bc91d177681dc98f1b7",
                Title = "Post2",
                Location = "Pokhara",
                Content = "This is another test post.",
                Created = DateTime.UtcNow
            },
            new Post
            {
                UserId = "686b8cbb066e4019760b0583",
                Title = "Post3",
                Location = "Lalitpur",
                Content = "And another post.",
                Created = DateTime.UtcNow
            }
        };

        foreach (var post in posts)
        {
            await createService.CreateAsync(post);
        }
    }
}