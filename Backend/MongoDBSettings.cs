using Backend;

namespace Backend
{
    public class MongoDbSettings
    {
        public string ConnectionString { get; set; }
        public string DatabaseName { get; set; }
        public string TouristPostsCollectionName { get; set; }
    } 
}
