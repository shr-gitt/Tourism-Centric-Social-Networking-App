using AspNetCore.Identity.MongoDbCore.Models;
using MongoDB.Bson;
using MongoDbGenericRepository.Attributes;

namespace Backend.Models
{
    [CollectionName("TouristUsers")]
    public class ApplicationUser : MongoIdentityUser<ObjectId>
    {
        public string Name { get; set; } = string.Empty;
        public string Image {get;set;} = string.Empty;
    }
}