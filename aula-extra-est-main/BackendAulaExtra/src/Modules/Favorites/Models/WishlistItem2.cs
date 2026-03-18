using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class WishlistItem2
    {
        public Guid WishlistItemId {get; set;}
        public Guid WishlistId {get; set;}
        public Guid? CourseId {get; set;}
        public DateTime? Added {get; set;}
    }
}