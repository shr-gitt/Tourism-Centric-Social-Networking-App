using Backend.Data;
using Backend.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Driver;

namespace Backend.Services;

public class ReportServices
{
    private readonly IMongoCollection<Report> _reportCollection;
    private readonly IMongoCollection<Post> _postsCollection;

    public ReportServices(ReportContext reportContext, PostsContext postsContext)
    {
        _reportCollection = reportContext.Reports;
        _postsCollection = postsContext.Posts;
    }
    
    public async Task<List<Report>> GetAsync() =>
        await _reportCollection.Find(_ => true).ToListAsync();

    public async Task<Report?> GetByIdAsync(string id) =>
        await _reportCollection.Find(p => p.ReportId == id).FirstOrDefaultAsync();

    public async Task<bool> CreateAsync(Report report)
    {
        if (report == null) 
            throw new ArgumentNullException(nameof(report));

        var postExists = await _postsCollection.Find(p => p.PostId == report.PostId).AnyAsync();
        if (!postExists)
        {
            throw new InvalidOperationException($"Post with id {report.PostId} does not exist.");
        }
        await _reportCollection.InsertOneAsync(report);
        return true;
    }

    public async Task<bool> DeleteAsync(string reportId)
    {
        var result = await _reportCollection.DeleteOneAsync(p => p.ReportId == reportId);
        return result.DeletedCount > 0;
    }

}