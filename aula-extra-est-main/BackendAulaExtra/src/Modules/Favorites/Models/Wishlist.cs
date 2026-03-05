using System;

namespace ConfidantPostgreSQL.Modules.Favorites.Models
{
    public class Wishlist
    {
        public Guid IdWishlist { get; set; }
        public Guid IdUser { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
