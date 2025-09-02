using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data;

public class ReportContext
{
    private readonly IMongoDatabase _database;

    public ReportContext(IOptions<MongoDbSettings> settings, IMongoClient client)
    {
        _database = client.GetDatabase(settings.Value.DatabaseName);
    }

    public IMongoCollection<Report> Reports =>
        _database.GetCollection<Report>("PostReports");
}