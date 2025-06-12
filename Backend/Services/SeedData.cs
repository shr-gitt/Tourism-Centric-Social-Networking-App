using Backend.Models;
using Microsoft.Extensions.DependencyInjection;

namespace Backend.Services;

public static class SeedData
{
    public static async Task InitializeAsync(IServiceProvider serviceProvider)
    {
        var postService = serviceProvider.GetRequiredService<PostServices>();

        var existingPosts = await postService.GetAsync();
        if (existingPosts.Any())
        {
            return;
        }

        var posts = new List<Post>
        {
            new Post
            {
                Title = "Post1",
                Location = "Kathmandu",
                Content = "This is a test post.",
                Created = DateTime.UtcNow
            },
            new Post
            {
                Title = "Post2",
                Location = "Pokhara",
                Content = "This is another test post.",
                Created = DateTime.UtcNow
            },
            new Post
            {
                Title = "Post3",
                Location = "Lalitpur",
                Content = "And another post.",
                Created = DateTime.UtcNow
            }
        };

        foreach (var post in posts)
        {
            await postService.CreateAsync(post);
        }
    }
}