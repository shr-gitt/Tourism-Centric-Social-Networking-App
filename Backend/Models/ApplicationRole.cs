using AspNetCore.Identity.MongoDbCore.Models;
using MongoDbGenericRepository.Attributes;

namespace Backend.Models
{
    [CollectionName("TouristUsersRole")]
    public class ApplicationRole : MongoIdentityRole<Guid>
    {

    }
}