using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class WishlistItem
    {
        public Guid IdWishlistItem { get; set; }
        public Guid IdWishlist { get; set; }
        public Guid? CourseId { get; set; }
        public DateTime? AddedAt { get; set; }
    }
}
