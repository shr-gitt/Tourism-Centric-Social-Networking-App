using AspNetCore.Identity.MongoDbCore.Models;
using MongoDbGenericRepository.Attributes;

namespace Backend.Models
{
    [CollectionName("TouristUsers")]
    public class ApplicationUser : MongoIdentityUser<Guid>
    {
        public string Name { get; set; } = string.Empty;
        public string Image {get;set;} = string.Empty;
    }
}