using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class Favorite2
    {
        public Guid FavoriteId {get; set;}
        public Guid UserId {get; set;}
        public DateTime? CreatedAt {get; set;}
        public DateTime? UpdatedAt {get; set;}
    }



}