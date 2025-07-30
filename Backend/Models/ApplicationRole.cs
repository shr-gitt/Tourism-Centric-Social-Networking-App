using AspNetCore.Identity.MongoDbCore.Models;
using MongoDB.Bson;
using MongoDbGenericRepository.Attributes;

namespace Backend.Models
{
    [CollectionName("TouristUsersRole")]
    public class ApplicationRole : MongoIdentityRole<ObjectId>
    {
        public static class RoleNames
        {
            public const string Admin = "Admin";
            public const string User = "User";
            public const string Guest = "Guest";
            public const string LoggedIn = "LoggedIn";
        }
    }
}