using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class Whislist2
    {
        public Guid WishlistId {get; set;}
        public Guid UserId {get; set;}
        public DateTime? CreatedAt {get; set;}
        public DateTime? UpdatedAt {get; set;}
    }
}